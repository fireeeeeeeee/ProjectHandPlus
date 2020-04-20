Shader "Custom/Scene/SnowCutout" 
{
    Properties 
    {
        _MainTex ("Base (RGB) ", 2D) = "black" {}
        _SnowTex("Snow Tex",2D)="white" {}
        //_Noise("Noise",2D)="black" {}
        //_NoiseCoefficient("Noise Coefficient",Range(0,1))=0.4
        _SnowIndensity("_SnowIndensity",range(0,4))=1
        _DirectLightFactor("DirectLightFactor",Range(0,4))=1
        _LMFactor("LMFactor",Range(0,4))=1
        //_height("Snow Thin",float)=1
        _Mask ("Mask (R)", 2D) = "white" {}
    }
    SubShader
    {
        LOD 300
        Tags{"RenderType"="TransparentCutout" "Queue"="AlphaTest"}
        Pass
        {
            Tags{"LightMode"="ForwardBase" }
            Cull BACK
            ZWrite On
            ZTest LEqual
            Blend Off

            CGPROGRAM

            #include "UnityCG.cginc"
            #include "Lighting.cginc"
            #include "../Include/Global.cginc"

            #pragma vertex vertex
            #pragma fragment fragment
            #pragma target 3.5
            #pragma enable_d3d11_debug_symbols

            sampler2D _MainTex;
            float4 _MainTex_ST;
            //sampler2D _Noise;
            //float4 _Noise_ST;
            float _NoiseCoefficient;
            float _SnowIndensity;
            float _height;
            sampler2D _SnowTex;
            float _DirectLightFactor;
            float _LMFactor;
            sampler2D _Mask;
            float4 _Mask_ST;


            struct AppData
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
                float2 uv2 : TEXCOORD1;
                float3 normal : NORMAL;
                float4 tangent : TANGENT;
                
            };

            struct V2F
            {
                float4 vertex : SV_POSITION;
                float2 uv : TEXCOORD0;
                float2 uv2 : TEXCOORD2;
                float2 uvMask : TEXCOORD1;
                //float3 TBN[3] :TEXCOORD3;
                float3 normal : NORMAL;
                float4 worldPos :TEXCOORD6;
            };

            float Inclination(float3 insectionNormal,float noise)
            {
                float3 up=float3(0,1,0);
                float cosTheta=dot(up,insectionNormal);
                return max(0,cosTheta+noise);
            }

            float SnowAmount(float exposure,float inclination)
            {
                return exposure*inclination;
            }

            V2F vertex(AppData appData)
            {
                V2F o;

                float3 normal=UnityObjectToWorldNormal(appData.normal);
                o.normal=normal;

                // float inclination=Inclination(normal,0);
                // float exposure=1;
                // float snowAmount=SnowAmount(exposure,inclination);


                o.vertex=UnityObjectToClipPos(appData.vertex);
                o.uv=TRANSFORM_TEX(appData.uv,_MainTex);
                o.uvMask=TRANSFORM_TEX(appData.uv,_Mask);

                float4 tangentWorld;
                tangentWorld.xyz=UnityObjectToWorldDir(appData.tangent.xyz);
                tangentWorld.w=appData.tangent.w;
                o.uv2.xy = appData.uv2.xy * unity_LightmapST.xy + unity_LightmapST.zw;
                o.worldPos=mul(unity_ObjectToWorld,appData.vertex);
                return o;
            }

            float3 GetWorldNormal(sampler2D normalSampler,float2 uv,float3 T,float3 B,float3 N)
            {
                float4 normalTex=tex2D(normalSampler,uv);
                float3 normal=UnpackNormal(normalTex);
                
                normal=T*normal.x+B*normal.y+N*normal.z;
                normal=normalize(normal);
                return normal;
            }

            float4 fragment(V2F i) : SV_Target
            {
                float mask=tex2D(_Mask,i.uvMask).r;
                clip(mask-0.5);
                //float noise=tex2D(_Noise,i.worldPos.xz*_Noise_ST.xy)*0.3;
                float3 normal=normalize(i.normal);

                float inclination=Inclination(normal,0);
                float exposure=1;
                float snowAmount=SnowAmount(exposure,inclination);
                snowAmount= saturate(_SnowIndensity*snowAmount);
                
                
                float3 lambertianBRDF=tex2D(_MainTex,i.uv);
                float3 irradiance=Irradiance(_LightColor0.rgb,_WorldSpaceLightPos0.xyz,normal);
                float3 directLighting=LightingTransport(lambertianBRDF,irradiance);
                float3 staticIndirectIrradiance=DecodeLightmap(UNITY_SAMPLE_TEX2D(unity_Lightmap, i.uv2.xy)).rgb;
                float3 staticIndirect=LightingTransport(lambertianBRDF,staticIndirectIrradiance);
                float3 radiance=directLighting+staticIndirect;

                float3 dExposure= float3(ddx(exposure),0.3,ddy(exposure));
                //float3 normalNoise=_NoiseCoefficient*float3(noise,noise,noise);
                float3 snowNormal=normal;//+normalNoise-dExposure;
                snowNormal=normalize(snowNormal);
                


                lambertianBRDF=tex2D(_SnowTex,i.uv);//snow
                irradiance=Irradiance(_LightColor0.rgb,_WorldSpaceLightPos0.xyz,snowNormal);
                directLighting=LightingTransport(lambertianBRDF,irradiance);
                
                staticIndirect=LightingTransport(lambertianBRDF,staticIndirectIrradiance);
                
                float3 snowColor=directLighting*_DirectLightFactor+staticIndirect*_LMFactor;


                float4 color;
                //Real-time Rendering of Accumulated Snow  
                //https://pdfs.semanticscholar.org/c861/42269edcadcdf90b55d5933fcabb1405e1cb.pdf
                color.rgb=lerp(radiance,snowColor,snowAmount);
                color.a =1;
                return color;
            }
            ENDCG
        }
    }
    // SubShader
    // {
    //     //to do 无位移的雪
    // }

    Fallback off
}