// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "Custom/Scene/CustomTerrainDiffuse8" 
{
    Properties
    {
        _Control("Control (RGBA)", 2D) = "red" {}
        _Control_Ex("Control (RGBA)", 2D) = "black" {}
        _LightMap("LightMap", 2D) = "white" {}
        _Splat1("Layer 1 (R)", 2D) = "black" {}
        _Splat2("Layer 2 (G)", 2D) = "black" {}
        _Splat3("Layer 3 (B)", 2D) = "black" {}
        _Splat4("Layer 4 (A)", 2D) = "black" {}
        _Splat5("Layer 5 (R)", 2D) = "black" {}
        _Splat6("Layer 6 (G)", 2D) = "black" {}
        _Splat7("Layer 7 (B)", 2D) = "black" {}
        _Splat8("Layer 8 (A)", 2D) = "black" {}
    }

    SubShader
    {
        Tags{ "Queue" = "Geometry-99" "RenderType" = "Opaque" "LightMode" = "Always"}
        Pass
        {
            CGPROGRAM

            #pragma vertex vertT
            #pragma fragment fragT
            #pragma multi_compile_fog
            #pragma multi_compile __ CUSTOM_SHADOW_ON 
            #pragma target 3.0

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
            sampler2D _Splat1;
            sampler2D _Splat2;
            sampler2D _Splat3;
            sampler2D _Splat4;
            sampler2D _Splat5;
            sampler2D _Splat6;
            sampler2D _Splat7;
            sampler2D _Splat8;

            sampler2D _LightMap;
            float4 _LightMap_ST;

            #include "UnityCG.cginc"
            struct appterrain
            {
                float4 vertex : POSITION;
                float2 texcoord : TEXCOORD0;
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
                UNITY_FOG_COORDS(6)
            #ifdef CUSTOM_SHADOW_ON
                float3 _WorldPosViewZ : TEXCOORD7;
            #endif
            };

            // common
            sampler2D _MainTex;
            float4x4 custom_World2Shadow;
            sampler2D _CustomShadowMapTexture;
            float shadowScale;
            float _windSpeed;


            v2fTerrain vertT(appterrain v)
            {
                v2fTerrain o = (v2fTerrain)0;
                o.vertex = UnityObjectToClipPos(v.vertex);
                
                o.tc_Control.xy = TRANSFORM_TEX(v.texcoord, _Control);
                o.uv_Splat1.xy = TRANSFORM_TEX(v.texcoord, _Splat1);
                o.uv_Splat2.xy = TRANSFORM_TEX(v.texcoord, _Splat2);
                o.uv_Splat3.xy = TRANSFORM_TEX(v.texcoord, _Splat3);
                o.uv_Splat4.xy = TRANSFORM_TEX(v.texcoord, _Splat4);
                o.uv_Splat1.zw = TRANSFORM_TEX(v.texcoord, _Splat5);
                o.uv_Splat2.zw = TRANSFORM_TEX(v.texcoord, _Splat6);
                o.uv_Splat3.zw = TRANSFORM_TEX(v.texcoord, _Splat7);
                o.uv_Splat4.zw = TRANSFORM_TEX(v.texcoord, _Splat8);

                o.uv2.xy = TRANSFORM_TEX(v.texcoord, _LightMap);

            #ifdef CUSTOM_SHADOW_ON
                o._WorldPosViewZ.xyz = mul(unity_ObjectToWorld,float4(v.vertex.xyz, 1.0)).xyz;
            #endif

                UNITY_TRANSFER_FOG(o, o.vertex);
                return o;
            }

            fixed4 fragT(v2fTerrain i) :SV_Target
            {
                half weight;
                fixed4 mixedDiffuse = fixed4(0,0,0,0);

                half4 splat_control_1 = tex2D(_Control, i.tc_Control.xy);
                half4 splat_control_2 = tex2D(_Control_Ex, i.tc_Control.xy);
                weight = dot(splat_control_1, half4(1, 1, 1, 1));
                weight += dot(splat_control_2, half4(1, 1, 1, 1));

                // splat_control_1 /= (weight + 1e-3f);
                // splat_control_2 /= (weight + 1e-3f);

                mixedDiffuse += splat_control_1.r * tex2D(_Splat1, i.uv_Splat1.xy);
                mixedDiffuse += splat_control_1.g * tex2D(_Splat2, i.uv_Splat2.xy);
                mixedDiffuse += splat_control_1.b * tex2D(_Splat3, i.uv_Splat3.xy);
                mixedDiffuse += splat_control_1.a * tex2D(_Splat4, i.uv_Splat4.xy);
                mixedDiffuse += splat_control_2.r * tex2D(_Splat5, i.uv_Splat1.zw);
                mixedDiffuse += splat_control_2.g * tex2D(_Splat6, i.uv_Splat2.zw);
                mixedDiffuse += splat_control_2.b * tex2D(_Splat7, i.uv_Splat3.zw);
                mixedDiffuse += splat_control_2.a * tex2D(_Splat8, i.uv_Splat4.zw);

                fixed4 final = fixed4(mixedDiffuse.rgb, weight);
                final.rgb *= DecodeLightmap(tex2D(_LightMap, i.uv2.xy)).rgb;
                
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

    SubShader
    {
        Tags{ "Queue" = "Geometry-99" "RenderType" = "Opaque" "LightMode" = "Always"}
        Pass
        {
            CGPROGRAM

            #pragma vertex vertT
            #pragma fragment fragT
            #pragma multi_compile_fog
            #pragma multi_compile __ CUSTOM_SHADOW_ON 
            #pragma target 2.0

            float4 _Control_ST;
            float4 _Splat1_ST;
            float4 _Splat2_ST;
            float4 _Splat3_ST;
            float4 _Splat4_ST;

            sampler2D _Control;
            sampler2D _Splat1;
            sampler2D _Splat2;
            sampler2D _Splat3;
            sampler2D _Splat4;

            sampler2D _LightMap;
            float4 _LightMap_ST;

            #include "UnityCG.cginc"
            struct appterrain
            {
                float4 vertex : POSITION;
                float2 texcoord : TEXCOORD0;
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
                UNITY_FOG_COORDS(6)
            #ifdef CUSTOM_SHADOW_ON
                float3 _WorldPosViewZ : TEXCOORD7;
            #endif
            };

            // common
            sampler2D _MainTex;
            float4x4 custom_World2Shadow;
            sampler2D _CustomShadowMapTexture;
            float shadowScale;
            float _windSpeed;


            v2fTerrain vertT(appterrain v)
            {
                v2fTerrain o = (v2fTerrain)0;
                //v.texcoord = v.vertex.xz * float2(0.005,-0.005);
                //v.texcoord = mul(UNITY_MATRIX_M, v.vertex).xz * float2(0.005,0.005);
                o.vertex = UnityObjectToClipPos(v.vertex);
                
                o.tc_Control.xy = TRANSFORM_TEX(v.texcoord, _Control);
                o.uv_Splat1.xy = TRANSFORM_TEX(v.texcoord, _Splat1);
                o.uv_Splat2.xy = TRANSFORM_TEX(v.texcoord, _Splat2);
                o.uv_Splat3.xy = TRANSFORM_TEX(v.texcoord, _Splat3);
                o.uv_Splat4.xy = TRANSFORM_TEX(v.texcoord, _Splat4);

                o.uv2.xy = TRANSFORM_TEX(v.texcoord, _LightMap);

            #ifdef CUSTOM_SHADOW_ON
                o._WorldPosViewZ.xyz = mul(unity_ObjectToWorld,float4(v.vertex.xyz, 1.0)).xyz;
            #endif

                UNITY_TRANSFER_FOG(o, o.vertex);
                return o;
            }

            fixed4 fragT(v2fTerrain i) :SV_Target
            {
                half weight;
                fixed4 mixedDiffuse = fixed4(0,0,0,0);

                half4 splat_control_1 = tex2D(_Control, i.tc_Control.xy);

                mixedDiffuse += splat_control_1.r * tex2D(_Splat1, i.uv_Splat1.xy);
                mixedDiffuse += splat_control_1.g * tex2D(_Splat2, i.uv_Splat2.xy);
                mixedDiffuse += splat_control_1.b * tex2D(_Splat3, i.uv_Splat3.xy);
                mixedDiffuse += splat_control_1.a * tex2D(_Splat4, i.uv_Splat4.xy);

                fixed4 final = fixed4(mixedDiffuse.rgb, 1);
                final.rgb *= DecodeLightmap(tex2D(_LightMap, i.uv2.xy)).rgb;
                
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

        Pass
        {
            Blend One One
            //ZTest LEqual
            //ZTest Less
            CGPROGRAM

            #pragma vertex vertT
            #pragma fragment fragT
            #pragma multi_compile_fog
            #pragma multi_compile __ CUSTOM_SHADOW_ON 
            #pragma target 2.0


            float4 _Control_Ex_ST;
            float4 _Splat5_ST;
            float4 _Splat6_ST;
            float4 _Splat7_ST;
            float4 _Splat8_ST;


            sampler2D _Control_Ex;
            sampler2D _Splat5;
            sampler2D _Splat6;
            sampler2D _Splat7;
            sampler2D _Splat8;

            sampler2D _LightMap;
            float4 _LightMap_ST;

            #include "UnityCG.cginc"
            struct appterrain
            {
                float4 vertex : POSITION;
                float2 texcoord : TEXCOORD0;
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
                UNITY_FOG_COORDS(6)
            #ifdef CUSTOM_SHADOW_ON
                float3 _WorldPosViewZ : TEXCOORD7;
            #endif
            };

            // common
            sampler2D _MainTex;
            float4x4 custom_World2Shadow;
            sampler2D _CustomShadowMapTexture;
            float shadowScale;
            float _windSpeed;


            v2fTerrain vertT(appterrain v)
            {
                v2fTerrain o = (v2fTerrain)0;
                o.vertex = UnityObjectToClipPos(v.vertex);
                
                o.tc_Control.xy = TRANSFORM_TEX(v.texcoord, _Control_Ex);
                o.uv_Splat1.zw = TRANSFORM_TEX(v.texcoord, _Splat5);
                o.uv_Splat2.zw = TRANSFORM_TEX(v.texcoord, _Splat6);
                o.uv_Splat3.zw = TRANSFORM_TEX(v.texcoord, _Splat7);
                o.uv_Splat4.zw = TRANSFORM_TEX(v.texcoord, _Splat8);

                o.uv2.xy = TRANSFORM_TEX(v.texcoord, _LightMap);

            #ifdef CUSTOM_SHADOW_ON
                o._WorldPosViewZ.xyz = mul(unity_ObjectToWorld,float4(v.vertex.xyz, 1.0)).xyz;
            #endif

                UNITY_TRANSFER_FOG(o, o.vertex);
                return o;
            }

            fixed4 fragT(v2fTerrain i) :SV_Target
            {
                half weight;
                fixed4 mixedDiffuse = fixed4(0,0,0,0);

                half4 splat_control_2 = tex2D(_Control_Ex, i.tc_Control.xy);
                half weight2 = dot(splat_control_2, half4(1, 1, 1, 1));
                // clip(weight2 == 0.0f ? -1 : 1);

                mixedDiffuse += splat_control_2.r * tex2D(_Splat5, i.uv_Splat1.zw);
                mixedDiffuse += splat_control_2.g * tex2D(_Splat6, i.uv_Splat2.zw);
                mixedDiffuse += splat_control_2.b * tex2D(_Splat7, i.uv_Splat3.zw);
                mixedDiffuse += splat_control_2.a * tex2D(_Splat8, i.uv_Splat4.zw);

                fixed4 final = fixed4(mixedDiffuse.rgb, 1);
                final.rgb *= DecodeLightmap(tex2D(_LightMap, i.uv2.xy)).rgb;
                
            #ifdef CUSTOM_SHADOW_ON
                float4 shadow = mul(custom_World2Shadow, float4(i._WorldPosViewZ.xyz, 1));
                float2 coord = float2(shadow.xy / shadow.w);
                float depth = 1 - step(SAMPLE_DEPTH_TEXTURE(_CustomShadowMapTexture, coord.xy + float2(0.15, 0.0)), 0.99)*(final.r+ final.g+ final.b)*shadowScale;
                final.rgb *= depth;
            #endif
                UNITY_APPLY_FOG_COLOR(i.fogCoord, final, fixed4(0,0,0,0));
                return final;
            }
            ENDCG
        }
    }
}
