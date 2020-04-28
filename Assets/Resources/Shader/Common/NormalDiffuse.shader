Shader "Custom/RimLight/NormalDiffuse"
{
	Properties
	{
		_MainTex ("Diffuse", 2D) = "white" {}
		_NormalTex ("NormalMap", 2D) = "bump"{}
		_SpecularTex ("SpecularTex", 2D) = "black" {}
		//_CapTex ("CapTexture", 2D) = "black" {}
		[Toggle] _Local("Local Dir?", Float) = 0
		_LightColor ("LightColor", COLOR) = (0.5,0.5,0.5,0.5)
		_Horizontal ("Horizontal",range(0.0,1.0)) = 0
		_Vertical ("Vertical",range(0.0,1.0)) = 0
		_BackColor("BackColor",COLOR) = (0.3,0.3,0.3,1.0)
		_RimColor ("RimColor",color) = (0.35,0.35,0.35,1)
	}
	SubShader
	{
		Tags {"LightMode"="ForwardBase" "RenderType"="Opaque" "IgnoreProjector" = "True"}
		LOD 100

		Pass
		{
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			#include "UnityCG.cginc"
			#include "Lighting.cginc"
			#pragma shader_feature _LOCAL_ON
			// make fog work
			//#pragma multi_compile_fog
			
			#include "UnityCG.cginc"

			struct appdata
			{
				float4 vertex : POSITION;
				float2 uv : TEXCOORD0;
				float3 normal : NORMAL;
				float4 tangent : TANGENT;
			};

			struct v2f
			{
				float2 uv : TEXCOORD0;
				//UNITY_FOG_COORDS(1)
				float4 vertex : SV_POSITION;
				float3 worldPos : TEXCOORD1;
                half3 tspace0 : TEXCOORD2;
                half3 tspace1 : TEXCOORD3;
                half3 tspace2 : TEXCOORD4;
			};

			sampler2D _MainTex, _NormalTex, _SpecularTex;
			float4 _MainTex_ST, _LightColor, _BackColor, _RimColor;
			fixed _Horizontal, _Vertical;
			
			v2f vert (appdata v)
			{
				v2f o;
				o.vertex = UnityObjectToClipPos(v.vertex);
				o.uv = TRANSFORM_TEX(v.uv, _MainTex);
				//UNITY_TRANSFER_FOG(o,o.vertex);
				o.worldPos = mul(unity_ObjectToWorld, v.vertex).xyz;
				half3 wNormal = UnityObjectToWorldNormal(v.normal);
                half3 wTangent = UnityObjectToWorldDir(v.tangent.xyz);
                half tangentSign = v.tangent.w * unity_WorldTransformParams.w;
				half3 wBitangent = cross(wNormal, wTangent) * tangentSign;
				o.tspace0 = half3(wTangent.x, wBitangent.x, wNormal.x);
                o.tspace1 = half3(wTangent.y, wBitangent.y, wNormal.y);
                o.tspace2 = half3(wTangent.z, wBitangent.z, wNormal.z);
				return o;
			}
			
			fixed4 frag (v2f i) : SV_Target
			{
				// sample the texture
				fixed4 col = tex2D(_MainTex, i.uv);
				half3 tnormal = UnpackNormal(tex2D(_NormalTex, i.uv));

				half3 worldNormal;
                worldNormal.x = dot(i.tspace0, tnormal);
                worldNormal.y = dot(i.tspace1, tnormal);
                worldNormal.z = dot(i.tspace2, tnormal);

				half3 worldViewDir = normalize(UnityWorldSpaceViewDir(i.worldPos));
				half3 worldRefl = reflect(-worldViewDir, worldNormal);
				//自定义光照
				_Vertical *= 6.2831852;
				_Horizontal *= 6.2831852;
				half3 worldlight = half3(cos(_Vertical)*sin(_Horizontal), sin(_Vertical), cos(_Vertical)*cos(_Horizontal));
				#if _LOCAL_ON
					//worldlight = mul(unity_ObjectToWorld, half4(worldlight, 1.0)).xyz;
					worldlight = UnityObjectToWorldDir(worldlight);
				#endif				
							
				/*half2 capCoord;
				capCoord.x = dot(UNITY_MATRIX_IT_MV[0].xyz, worldNormal);
				capCoord.y = dot(UNITY_MATRIX_IT_MV[1].xyz, worldNormal);
				half2 capuv = capCoord * 0.5 + 0.5;
				fixed cap = tex2D(_MaskTex, capuv).b;
				fixed3 matel = pow(col,2.0) * (1.0 + cap);	*/

				//采Unity内置天空信息作为间接光照
				//half4 skyData = UNITY_SAMPLE_TEXCUBE(unity_SpecCube0, worldRefl);
				//half3 indirectSpecular = DecodeHDR(skyData, unity_SpecCube0_HDR);

				half rim = max(0.0, _RimColor.a - saturate(dot(worldViewDir, worldNormal)));
				half3 rimcolor = col * _RimColor.rgb * rim / (_RimColor.a + 0.001);
				
				fixed3 specularcolor = tex2D(_SpecularTex, i.uv).rgb * _LightColor.rgb * 2.0;
				fixed lum = 0.3 * specularcolor.r + 0.6 * specularcolor.g + 0.1 * specularcolor.b;
				fixed specular = pow(saturate(dot(worldRefl, worldlight)), 10.0 * _LightColor.a * lum);
				specularcolor *= specular;// *indirectSpecular;
				
				//float3 worldLightDir = normalize(UnityWorldSpaceLightDir(i.worldPos));

				//half3 halfDir = normalize(worldLightDir + worldViewDir);
				//half specular = pow(saturate(dot(worldNormal, halfDir)),30.0 * mask.r) * mask.r;
				//float3 reflectDir = normalize(reflect(-worldLightDir,worldNormal));
				//half specular = pow(saturate(dot(reflectDir, worldViewDir)),10.0) * mask.b;
				
				//fixed Diffuse = min(0.7 + saturate(dot(worldNormal,worldLightDir)),1.0) * _LightColor0.rgb;
				fixed3 diffuseColor = lerp(_BackColor.rgb, 2.0 * _LightColor.rgb, saturate(dot(worldNormal, worldlight)));
				
				col.rgb *= diffuseColor;
				col.rgb += specularcolor + rimcolor;

				// apply fog
				//UNITY_APPLY_FOG(i.fogCoord, col);
				return col;
			}
			ENDCG
		}
	}
}
