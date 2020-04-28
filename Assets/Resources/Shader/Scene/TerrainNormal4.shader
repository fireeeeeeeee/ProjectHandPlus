Shader "Custom/Scene/TerrainNormal4"
{
	Properties
	{
        _Control("Control (RGBA)", 2D) = "red" {}
        //_Control_Ex("Control_Ex (RGBA)", 2D) = "black" {}
        _LightMap("LightMap", 2D) = "white" {}
        _Splat1("Layer 1 (R)", 2D) = "black" {}
        _Normal1("Noraml 1",2D) = "bump" {}
        _Specular1("Specular 1",2D)= "black" {}
        [HDR]_Intensity1("_Intensity1",Color)=(1.0,1.0,1.0,1.0)
        _Splat2("Layer 2 (G)", 2D) = "black" {}
        _Normal2("Noraml 2",2D) = "bump" {}
        _Specular2("Specular 2",2D)= "black" {}
        [HDR]_Intensity2("_Intensity2",Color)=(1.0,1.0,1.0,1.0)
        _Splat3("Layer 3 (B)", 2D) = "black" {}
        _Normal3("Noraml 3",2D) = "bump" {}
        _Specular3("Specular 3",2D)= "black" {}
        [HDR]_Intensity3("_Intensity3",Color)=(1.0,1.0,1.0,1.0)
        _Splat4("Layer 4 (A)", 2D) = "black" {}
        _Normal4("Noraml 4",2D) = "bump" {}
        _Specular4("Specular 4",2D)= "black" {}
        [HDR]_Intensity4("_Intensity4",Color)=(1.0,1.0,1.0,1.0)
        // _Splat5("Layer 5 (R)", 2D) = "black" {}
        // _Normal5("Noraml 5",2D) = "bump" {}
        // _Specular5("Specular 5",2D)= "black" {}
        // [HDR]_Intensity5("_Intensity5",Color)=(1.0,1.0,1.0,1.0)
        // _Splat6("Layer 6 (G)", 2D) = "black" {}
        // _Normal6("Noraml 6",2D) = "bump" {}
        // _Specular6("Specular 6",2D)= "black" {}
        // [HDR]_Intensity6("_Intensity6",Color)=(1.0,1.0,1.0,1.0)
        // _Splat7("Layer 7 (B)", 2D) = "black" {}
        // _Normal7("Noraml 7",2D) = "bump" {}
        // _Specular7("Specular 7",2D)= "black" {}
        // [HDR]_Intensity7("_Intensity7",Color)=(1.0,1.0,1.0,1.0)
        // _Splat8("Layer 8 (A)", 2D) = "black" {}
        // _Normal8("Noraml 8",2D) = "bump" {}
        // _Specular8("Specular 8",2D)= "black" {}
        // [HDR]_Intensity8("_Intensity8",Color)=(1.0,1.0,1.0,1.0)

        [HDR]_Specular ("高光颜色",COLOR) = (0.2,0.2,0.2,0.5)
        [HDR]_Diffuse("_Diffuse",COLOR)=(1,1,1,1)
        //[HDR]_LMCO("LMCO",COLOR)=(1,1,1,1)
        _SCO("高光范围",Float)=64
        //_Atten("衰减指数",Float)=1
	}
	SubShader
	{
		Tags{ "Queue" = "Geometry-99" "RenderType" = "Opaque" "LightMode" = "ForwardBase"}
		//Tags{ "Queue" = "Geometry" "RenderType" = "Opaque"}

        Pass
        {
            CGPROGRAM

            #pragma vertex vertT
            #pragma fragment fragT
            #pragma multi_compile_fog
            #pragma multi_compile __ CUSTOM_SHADOW_ON 
            #define USE_NORMAL
            //#pragma target 3.5
            // #if defined (USE_NORMAL)
            //     #pragma target 3.5
            // #else
                #pragma target 3.0
            // #endif
            

            float4 _Control_ST;
            float4 _Control_Ex_ST;
            float4 _Splat1_ST;
            float4 _Splat2_ST;
            float4 _Splat3_ST;
            float4 _Splat4_ST;
            float4 _Splat5_ST;
            float4 _Splat6_ST;
            float4 _Splat7_ST;
            float4 _Splat8_ST;

            sampler2D _Control;
            sampler2D _Control_Ex;
            UNITY_DECLARE_TEX2D(_Splat1);
            UNITY_DECLARE_TEX2D_NOSAMPLER(_Splat2);
            UNITY_DECLARE_TEX2D_NOSAMPLER(_Splat3);
            UNITY_DECLARE_TEX2D_NOSAMPLER(_Splat4);
            // UNITY_DECLARE_TEX2D_NOSAMPLER(_Splat5);
            // UNITY_DECLARE_TEX2D_NOSAMPLER(_Splat6);
            // UNITY_DECLARE_TEX2D_NOSAMPLER(_Splat7);
            // UNITY_DECLARE_TEX2D_NOSAMPLER(_Splat8);
            // sampler2D _Splat1;
            // sampler2D _Splat2;
            // sampler2D _Splat3;
            // sampler2D _Splat4;
            // sampler2D _Splat5;
            // sampler2D _Splat6;
            // sampler2D _Splat7;
            // sampler2D _Splat8;

            #if defined(USE_NORMAL)
                UNITY_DECLARE_TEX2D(_Normal1);
                UNITY_DECLARE_TEX2D_NOSAMPLER(_Normal2);
                UNITY_DECLARE_TEX2D_NOSAMPLER(_Normal3);
                UNITY_DECLARE_TEX2D_NOSAMPLER(_Normal4);
                // UNITY_DECLARE_TEX2D_NOSAMPLER(_Normal5);
                // UNITY_DECLARE_TEX2D_NOSAMPLER(_Normal6);
                // UNITY_DECLARE_TEX2D_NOSAMPLER(_Normal7);
                // UNITY_DECLARE_TEX2D_NOSAMPLER(_Normal8);

                UNITY_DECLARE_TEX2D(_Specular1);
                UNITY_DECLARE_TEX2D_NOSAMPLER(_Specular2);
                UNITY_DECLARE_TEX2D_NOSAMPLER(_Specular3);
                UNITY_DECLARE_TEX2D_NOSAMPLER(_Specular4);
                // UNITY_DECLARE_TEX2D_NOSAMPLER(_Specular5);
                // UNITY_DECLARE_TEX2D_NOSAMPLER(_Specular6);
                // UNITY_DECLARE_TEX2D_NOSAMPLER(_Specular7);
                // UNITY_DECLARE_TEX2D_NOSAMPLER(_Specular8);

                float4 _Normal1_ST;
                float4 _Normal2_ST;
                float4 _Normal3_ST;
                float4 _Normal4_ST;
                float4 _Normal5_ST;
                float4 _Normal6_ST;
                float4 _Normal7_ST;
                float4 _Normal8_ST;

                float4 _Intensity1;
                float4 _Intensity2;
                float4 _Intensity3;
                float4 _Intensity4;
                float4 _Intensity5;
                float4 _Intensity6;
                float4 _Intensity7;
                float4 _Intensity8;

                fixed4 _Specular;
                float4 _Diffuse;
                float4 _LMCO;
                float _SCO;
                float _Atten;
            #endif

            sampler2D _LightMap;
            float4 _LightMap_ST;

            #include "UnityCG.cginc"
            //#include "../Include/CommonUtil.cginc"
            #include "Lighting.cginc"
            struct appterrain
            {
                float4 vertex : POSITION;
                float2 texcoord : TEXCOORD0;
                float3 normal : NORMAL;
                float4 tangent : TANGENT;
            };

            struct v2fTerrain
            {
                float4 vertex : SV_POSITION;
                half2 tc_Control : TEXCOORD0;
                half2 uv2 : TEXCOORD1;
                half4 uv_Splat1 : TEXCOORD2;
                half4 uv_Splat2 : TEXCOORD3;
                half4 uv_Splat3 : TEXCOORD4;
                half4 uv_Splat4 : TEXCOORD5;

                #if defined(USE_NORMAL)
                    float3 TBN[3] : TEXCOORD9;
                    float3 tangent : TEXCOORD13;
                    float3 bitangent : TEXCOORD14;
                    float3 normal : TEXCOORD12;
                #endif
                
                float4 worldPos : TEXCOORD8;
                UNITY_FOG_COORDS(6)
            #ifdef CUSTOM_SHADOW_ON
                float3 _WorldPosViewZ : TEXCOORD7;
            #endif
            };

            // common
            float4x4 custom_World2Shadow;
            sampler2D _CustomShadowMapTexture;
            float shadowScale;
            float _windSpeed;


            v2fTerrain vertT(appterrain v)
            {
                v2fTerrain o = (v2fTerrain)0;
                //o.vertex =  mul(UNITY_MATRIX_MVP, v.vertex);
                o.vertex= UnityObjectToClipPos(v.vertex);
                o.worldPos= mul(unity_ObjectToWorld,v.vertex);

                o.tc_Control.xy = TRANSFORM_TEX(v.texcoord, _Control);
                o.uv_Splat1.xy = TRANSFORM_TEX(v.texcoord, _Splat1);
                o.uv_Splat2.xy = TRANSFORM_TEX(v.texcoord, _Splat2);
                o.uv_Splat3.xy = TRANSFORM_TEX(v.texcoord, _Splat3);
                o.uv_Splat4.xy = TRANSFORM_TEX(v.texcoord, _Splat4);
                // o.uv_Splat1.zw = TRANSFORM_TEX(v.texcoord, _Splat5);
                // o.uv_Splat2.zw = TRANSFORM_TEX(v.texcoord, _Splat6);
                // o.uv_Splat3.zw = TRANSFORM_TEX(v.texcoord, _Splat7);
                // o.uv_Splat4.zw = TRANSFORM_TEX(v.texcoord, _Splat8);

                o.uv2.xy = TRANSFORM_TEX(v.texcoord, _LightMap);

                #if defined(USE_NORMAL)
                    float4 tangentT;
                    tangentT.xyz=cross(v.normal,float3(0,0,1));
                    tangentT.w=-1;


                    float3 normal=UnityObjectToWorldNormal(v.normal);
                    
                    float3 tangent=UnityObjectToWorldDir(tangentT.xyz);
                    half3x3 TBN=CreateTangentToWorldPerVertex(normal,tangent,tangentT.w);
                    o.TBN[0]=TBN[0];
                    o.TBN[1]=TBN[1];
                    o.TBN[2]=TBN[2];
                #endif

            #ifdef CUSTOM_SHADOW_ON
                o._WorldPosViewZ.xyz = mul(unity_ObjectToWorld,float4(v.vertex.xyz, 1.0)).xyz;
            #endif

                UNITY_TRANSFER_FOG(o, o.vertex);
                return o;
            }

            fixed4 fragT(v2fTerrain i) :SV_Target
            {
                //return fixed4(i.normal,1.0);
                half weight;
                fixed4 mixedDiffuse = fixed4(0,0,0,0);

                half4 splat_control_1 = tex2D(_Control, i.tc_Control.xy);
                // half4 splat_control_2 = tex2D(_Control_Ex, i.tc_Control.xy);
                weight = dot(splat_control_1, half4(1, 1, 1, 1));
                // weight += dot(splat_control_2, half4(1, 1, 1, 1));

                // splat_control_1 /= (weight + 1e-3f);
                // splat_control_2 /= (weight + 1e-3f);
                //float sepcCO=tex2D(_Splat1, i.uv_Splat1.xy).a;
                //sepcCO = 3 * pow(sepcCO,2);
                #if defined(USE_NORMAL)
                    // float4 splat1=tex2D(_Splat1, i.uv_Splat1.xy);
                    // float4 splat2=tex2D(_Splat2, i.uv_Splat2.xy);
                    // float4 splat3=tex2D(_Splat3, i.uv_Splat3.xy);
                    // float4 splat4=tex2D(_Splat4, i.uv_Splat4.xy);
                    // float4 splat5=tex2D(_Splat5, i.uv_Splat1.zw);
                    // float4 splat6=tex2D(_Splat6, i.uv_Splat2.zw);
                    // float4 splat7=tex2D(_Splat7, i.uv_Splat3.zw);
                    // float4 splat8=tex2D(_Splat8, i.uv_Splat4.zw);

                    float4 splat1=UNITY_SAMPLE_TEX2D(_Splat1, i.uv_Splat1.xy);
                    float4 splat2=UNITY_SAMPLE_TEX2D_SAMPLER(_Splat2, _Splat1,i.uv_Splat2.xy);
                    float4 splat3=UNITY_SAMPLE_TEX2D_SAMPLER(_Splat3, _Splat1,i.uv_Splat3.xy);
                    float4 splat4=UNITY_SAMPLE_TEX2D_SAMPLER(_Splat4, _Splat1,i.uv_Splat4.xy);
                    // float4 splat5=UNITY_SAMPLE_TEX2D_SAMPLER(_Splat5,_Splat1, i.uv_Splat1.zw);
                    // float4 splat6=UNITY_SAMPLE_TEX2D_SAMPLER(_Splat6, _Splat1,i.uv_Splat2.zw);
                    // float4 splat7=UNITY_SAMPLE_TEX2D_SAMPLER(_Splat7, _Splat1,i.uv_Splat3.zw);
                    // float4 splat8=UNITY_SAMPLE_TEX2D_SAMPLER(_Splat8, _Splat1,i.uv_Splat4.zw);

                    mixedDiffuse += splat_control_1.r * splat1*_Intensity1;                
                    mixedDiffuse += splat_control_1.g * splat2*_Intensity2;
                    mixedDiffuse += splat_control_1.b * splat3*_Intensity3;
                    mixedDiffuse += splat_control_1.a * splat4*_Intensity4;
                    // mixedDiffuse += splat_control_2.r * splat5*_Intensity5;
                    // mixedDiffuse += splat_control_2.g * splat6*_Intensity6;
                    // mixedDiffuse += splat_control_2.b * splat7*_Intensity7;
                    // mixedDiffuse += splat_control_2.a * splat8*_Intensity8;
                #else
                    mixedDiffuse += splat_control_1.r * tex2D(_Splat1, i.uv_Splat1.xy);                
                    mixedDiffuse += splat_control_1.g * tex2D(_Splat2, i.uv_Splat2.xy);
                    mixedDiffuse += splat_control_1.b * tex2D(_Splat3, i.uv_Splat3.xy);
                    mixedDiffuse += splat_control_1.a * tex2D(_Splat4, i.uv_Splat4.xy);
                    // mixedDiffuse += splat_control_2.r * tex2D(_Splat5, i.uv_Splat1.zw);
                    // mixedDiffuse += splat_control_2.g * tex2D(_Splat6, i.uv_Splat2.zw);
                    // mixedDiffuse += splat_control_2.b * tex2D(_Splat7, i.uv_Splat3.zw);
                    // mixedDiffuse += splat_control_2.a * tex2D(_Splat8, i.uv_Splat4.zw);
                #endif


                #if defined(USE_NORMAL)
                    float4 normalTex1=UNITY_SAMPLE_TEX2D(_Normal1,i.uv_Splat1.xy); //tex2D(_Normal1,i.uv_Splat1.xy);
                    float4 normalTex2=UNITY_SAMPLE_TEX2D_SAMPLER(_Normal2,_Normal1,i.uv_Splat2.xy);// tex2D(_Normal2,i.uv_Splat2.xy);
                    float4 normalTex3=UNITY_SAMPLE_TEX2D_SAMPLER(_Normal3,_Normal1,i.uv_Splat3.xy);//tex2D(_Normal3,i.uv_Splat3.xy);
                    float4 normalTex4=UNITY_SAMPLE_TEX2D_SAMPLER(_Normal4,_Normal1,i.uv_Splat4.xy);//tex2D(_Normal4,i.uv_Splat4.xy);

                    // float4 normalTex5=UNITY_SAMPLE_TEX2D_SAMPLER(_Normal5,_Normal1,i.uv_Splat1.zw);//tex2D(_Normal5,i.uv_Splat1.zw);
                    // float4 normalTex6=UNITY_SAMPLE_TEX2D_SAMPLER(_Normal6,_Normal1,i.uv_Splat2.zw);//tex2D(_Normal6,i.uv_Splat2.zw);
                    // float4 normalTex7=UNITY_SAMPLE_TEX2D_SAMPLER(_Normal7,_Normal1,i.uv_Splat3.zw);//tex2D(_Normal7,i.uv_Splat3.zw); 
                    // float4 normalTex8=UNITY_SAMPLE_TEX2D_SAMPLER(_Normal8,_Normal1,i.uv_Splat4.zw);//tex2D(_Normal8,i.uv_Splat4.zw);

                    float4 normalTex=normalTex1*splat_control_1.r+normalTex2*splat_control_1.g+normalTex3*splat_control_1.b+normalTex4*splat_control_1.a;
                    //+normalTex5*splat_control_2.r+normalTex6*splat_control_2.g+normalTex7*splat_control_2.b+normalTex8*splat_control_2.a;

                    float3 normal=UnpackNormal(normalTex);
                    
                    // float3 normalAxis=normalize(i.TBN[2]);
                    // float3 tangentAxis=i.TBN[0];
                    // tangentAxis =normalize(tangentAxis-normalAxis*dot(tangentAxis,normalAxis));
                    // float3 newB=cross(normalAxis,tangentAxis);
                    // float3 binormalAxis=i.TBN[1];
                    // binormalAxis=newB*sign(dot(newB,binormalAxis));
                    //normal=float3(dot(i.TBN[0],normal),dot(i.TBN[1],normal),dot(i.TBN[2],normal)); //mul(i.TBN,normal);
                    normal=i.TBN[0]*normal.x+i.TBN[1]*normal.y+i.TBN[2]*normal.z;
                    //normal=tangentAxis*normal.x+binormalAxis*normal.y+normalAxis*normal.z;
                    normal=normalize(normal);
                    //return fixed4(i.TBN[2],1.0);

                    // float sepcCO=normalTex1.a+normalTex2.a+normalTex3.a+normalTex4.a
                    // +normalTex5.a+normalTex6.a+normalTex7.a+normalTex8.a;
                    //return splat2.a;
                    //float sepcCO=splat1.a+splat2.a+splat3.a+splat4.a+splat5.a+splat6.a+splat7.a+splat8.a;
                    //return sepcCO;

                    half3 worldViewDir = normalize(UnityWorldSpaceViewDir(i.worldPos));
                    float3 worldLightDir = normalize(UnityWorldSpaceLightDir(i.worldPos));
                    half3 halfDir = normalize(worldLightDir + worldViewDir);

                    
                    // float dist=distance(i.worldPos,_WorldSpaceCameraPos);
                    // float atten=1/(dist*dist);
                    // atten*=_Atten;


                    float3 diff= saturate(dot(worldLightDir,normal))*_Diffuse.xyz;

                    float4 specTex1=UNITY_SAMPLE_TEX2D(_Specular1,i.uv_Splat1.xy); //tex2D(_Normal1,i.uv_Splat1.xy);
                    float4 specTex2=UNITY_SAMPLE_TEX2D_SAMPLER(_Specular2,_Specular1,i.uv_Splat2.xy);// tex2D(_Normal2,i.uv_Splat2.xy);
                    float4 specTex3=UNITY_SAMPLE_TEX2D_SAMPLER(_Specular3,_Specular1,i.uv_Splat3.xy);//tex2D(_Normal3,i.uv_Splat3.xy);
                    float4 specTex4=UNITY_SAMPLE_TEX2D_SAMPLER(_Specular4,_Specular1,i.uv_Splat4.xy);//tex2D(_Normal4,i.uv_Splat4.xy);

                    // float4 specTex5=UNITY_SAMPLE_TEX2D_SAMPLER(_Specular5,_Specular1,i.uv_Splat1.zw);//tex2D(_Normal5,i.uv_Splat1.zw);
                    // float4 specTex6=UNITY_SAMPLE_TEX2D_SAMPLER(_Specular6,_Specular1,i.uv_Splat2.zw);//tex2D(_Normal6,i.uv_Splat2.zw);
                    // float4 specTex7=UNITY_SAMPLE_TEX2D_SAMPLER(_Specular7,_Specular1,i.uv_Splat3.zw);//tex2D(_Normal7,i.uv_Splat3.zw); 
                    // float4 specTex8=UNITY_SAMPLE_TEX2D_SAMPLER(_Specular8,_Specular1,i.uv_Splat4.zw);//tex2D(_Normal8,i.uv_Splat4.zw);
                    
                    //return specTex1;
                    float4 specTex=splat_control_1.r*specTex1+splat_control_1.g*specTex2+splat_control_1.b*specTex3+splat_control_1.a*specTex4;
                    //+splat_control_2.r*specTex5+splat_control_2.g*specTex6+splat_control_2.b*specTex7+splat_control_2.a*specTex8;
                    //return specTex;
                    // float planeDot=dot(halfDir,float3(0,1,0));
                    // planeDot=1-planeDot;
                    //return fixed4(halfDir,1.0);
                    //return sepcCO;
                    half specular = pow(saturate(dot(normal, halfDir)),_SCO );//*sepcCO;
                    //specular*=atten;

                #endif

                fixed4 final = fixed4(mixedDiffuse.rgb, weight);
                #if defined(USE_NORMAL)
                    //final.rgb*=_LMCO;
                    //final.rgb*= 1+specular  * _Specular.rgb;
                    //return specular;
                    final.rgb *= diff*DecodeLightmap(tex2D(_LightMap, i.uv2.xy)).rgb;
                    final.rgb+=specular  * _Specular.rgb*specTex;
                #else
                    final.rgb *= DecodeLightmap(tex2D(_LightMap, i.uv2.xy)).rgb;
                #endif
                


                
            #ifdef CUSTOM_SHADOW_ON
                float4 shadow = mul(custom_World2Shadow, float4(i._WorldPosViewZ.xyz, 1));
                float2 coord = float2(shadow.xy / shadow.w);
                float depth = 1 - step(SAMPLE_DEPTH_TEXTURE(_CustomShadowMapTexture, coord.xy + float2(0.15, 0.0)), 0.99)*(final.r+ final.g+ final.b)*shadowScale;
                final.rgb *= depth;
            #endif
                UNITY_APPLY_FOG(i.fogCoord, final);
                return final;
            }
            ENDCG
        }
	}
	fallback "Diffuse"
}
