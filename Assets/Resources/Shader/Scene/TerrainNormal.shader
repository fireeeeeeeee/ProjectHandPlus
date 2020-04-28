Shader "Custom/Scene/TerrainNormal"
{
	Properties
	{
		_Control("Control (RGBA)", 2D) = "red" {}
		_Splat0("Layer 0 (R)", 2D) = "black" {}
		_Normal0("Normal 0 (R)", 2D) = "bump" {}
		_Splat1("Layer 1 (G)", 2D) = "black" {}
		_Splat2("Layer 2 (B)", 2D) = "black" {}
		_Splat3("Layer 3 (A)", 2D) = "black" {}	
		_Tiling ("Tiling 0/1/2/3", Vector) = (30.0,30.0,30.0,30.0)
		_Specular ("SpecularColor",COLOR) = (0.2,0.2,0.2,0.5)
		[Toggle] _Preview ("Preview?", Float) = 1
		//_CustomShadowMapTexture("shadow", 2D) = "white" {}
		//_LightMap_ST("LightMap Scale Offset", Vector) = (1,1,1,1)
	}
	SubShader
	{
		Tags{"LightMode"="ForwardBase" "Queue" = "Geometry+460" "RenderType" = "Opaque"}
		//Tags{ "Queue" = "Geometry" "RenderType" = "Opaque"}

		Pass
		{
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			#include "UnityCG.cginc"
			#include "Lighting.cginc"
			// make fog work
			#pragma multi_compile_fog
			#pragma shader_feature _PREVIEW_ON
			//#pragma target 3.0
			
			#include "UnityCG.cginc"

			struct appdata
			{
				float4 vertex : POSITION;
				float2 uv : TEXCOORD0;
				float3 normal : NORMAL;
				//float4 tangent : TANGENT;
				half2 uv2 : TEXCOORD1;
			};

			struct v2f
			{
				float2 uv : TEXCOORD0;
				UNITY_FOG_COORDS(1)
				float4 vertex : SV_POSITION;
				float3 worldPos : TEXCOORD2;
                half3 tspace0 : TEXCOORD3;
                half3 tspace1 : TEXCOORD4;
                half3 tspace2 : TEXCOORD5;
				half2 uvlm : TEXCOORD6;
			};

			sampler2D _Control;
			float4 _Control_ST;
			sampler2D _Splat0;
			float4 _Splat0_ST;
			sampler2D _Normal0;
			sampler2D _Splat1;
			float4 _Splat1_ST;
			sampler2D _Splat2;
			float4 _Splat2_ST;
			sampler2D _Splat3;
			float4 _Splat3_ST;
			fixed4 _Tiling; 
			fixed4 _Specular;
			
			float4x4 custom_World2Shadow;
			sampler2D _CustomShadowMapTexture;
			float shadowScale;

			
			v2f vert (appdata v)
			{
				v2f o;
				UNITY_INITIALIZE_OUTPUT(v2f,o);	
				o.vertex = UnityObjectToClipPos(v.vertex);
				o.uv = TRANSFORM_TEX(v.uv, _Control);

				o.worldPos = mul(unity_ObjectToWorld, v.vertex).xyz;
				half3 wNormal = UnityObjectToWorldNormal(v.normal);                

				//Computer Terrain Tangent
				float4 tangent = (1,0,0,-1);
				tangent.xyz = cross(v.normal, float3(0,0,1));
				tangent.w = -1;

				//half3 wTangent = UnityObjectToWorldDir(v.tangent.xyz);
				//half tangentSign = v.tangent.w * unity_WorldTransformParams.w;
				half3 wTangent = UnityObjectToWorldDir(tangent.xyz);
                half tangentSign = tangent.w * unity_WorldTransformParams.w;
				half3 wBitangent = cross(wNormal, wTangent) * tangentSign;
				o.tspace0 = half3(wTangent.x, wBitangent.x, wNormal.x);
                o.tspace1 = half3(wTangent.y, wBitangent.y, wNormal.y);
                o.tspace2 = half3(wTangent.z, wBitangent.z, wNormal.z);

				//#ifdef INPUTLIGHTMAP
					//o.uvlm.xy = v.uv.xy * _LightMap_ST.xy + _LightMap_ST.zw;
				//#else
					o.uvlm.xy = v.uv2.xy * unity_LightmapST.xy + unity_LightmapST.zw;
				//#endif

				UNITY_TRANSFER_FOG(o,o.vertex);
				return o;
			}
			
			fixed4 frag (v2f i) : SV_Target
			{
				// sample the texture
				fixed4 mask = tex2D(_Control, i.uv);
				fixed3 col0 = tex2D(_Splat0, i.uv * _Tiling.x).rgb;
				fixed3 col1 = tex2D(_Splat1, i.uv * _Tiling.y).rgb;
				fixed3 col2 = tex2D(_Splat2, i.uv * _Tiling.z).rgb;
				fixed3 col3 = tex2D(_Splat3, i.uv * _Tiling.w).rgb;
				fixed4 col = (1.0,1.0,1.0,1.0);
				col.rgb = col0 * mask.r + col1 * mask.g + col2 * mask.b + col3 * mask.a;

				half4 normaltex = tex2D(_Normal0, i.uv * _Tiling.x);
				half3 tnormal = UnpackNormal(normalize(lerp(fixed4(0.5,0.5,1.0,1.0) , normaltex, mask.r)));
				half3 worldNormal;
                worldNormal.x = dot(i.tspace0, tnormal);
                worldNormal.y = dot(i.tspace1, tnormal);
                worldNormal.z = dot(i.tspace2, tnormal);

				half3 worldViewDir = normalize(UnityWorldSpaceViewDir(i.worldPos));
				float3 worldLightDir = normalize(UnityWorldSpaceLightDir(i.worldPos));
				half3 halfDir = normalize(worldLightDir + worldViewDir);
				half specular = pow(saturate(dot(worldNormal, halfDir)),100.0 * _Specular.a * normaltex.b) * normaltex.b;

				col.rgb += specular  * _Specular.rgb;

				//#ifdef INPUTLIGHTMAP
					//col.rgb *= DecodeLightmap(tex2D(_TerrainLightMap, i.uvlm.xy)).rgb;
				//#else
					col.rgb *= DecodeLightmap(UNITY_SAMPLE_TEX2D(unity_Lightmap, i.uvlm.xy)).rgb;
				//#endif

				float4 shadow = mul(custom_World2Shadow, float4(i.worldPos.xyz, 1));
				float2 coord = float2(shadow.xy / shadow.w);
				float depth = 1 - step(SAMPLE_DEPTH_TEXTURE(_CustomShadowMapTexture, coord.xy + float2(0.15, 0.0)), 0.99)*(col.r+ col.g+ col.b)*shadowScale;

				#if _PREVIEW_ON
                	col.rgb *= depth;
                #endif				
				
				// apply fog
				UNITY_APPLY_FOG(i.fogCoord, col);
				return col;
			}
			ENDCG
		}
	}
	fallback "Diffuse"
}
