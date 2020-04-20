Shader "Custom/Scene/Water"
{
	Properties
	{
		_MainTex ("Underwater", 2D) = "black" {}
		_WaterColor ("WaterColor",COLOR) = (1,1,1,1)
		_Noise ("NoiseTex", 2D) = "black" {}
	}
	SubShader
	{
		Tags { "RenderType" = "Opaque" "Queue" = "Geometry+460" "LightMode" = "ForwardBase"}
		LOD 100

		Pass
		{
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			// make fog work
			#pragma multi_compile_fog
			
			#include "UnityCG.cginc"

			struct appdata
			{
				float4 vertex : POSITION;
				float2 uv : TEXCOORD0;
				float3 normal : NORMAL;
			};

			struct v2f
			{
				float2 uv : TEXCOORD0;
				UNITY_FOG_COORDS(1)
				float4 vertex : SV_POSITION;
				float3 worldpos : TEXCOORD2;
				float3 worldnormal : TEXCOORD3;
				float4 noiseuv : TEXCOORD4;
			};

			sampler2D _MainTex, _Noise;
			float4 _MainTex_ST, _WaterColor;
			
			v2f vert (appdata v)
			{
				v2f o;
				UNITY_INITIALIZE_OUTPUT(v2f, o);
				o.vertex = UnityObjectToClipPos(v.vertex);
				o.uv = TRANSFORM_TEX(v.uv, _MainTex);
				o.worldpos = mul(unity_ObjectToWorld, v.vertex).xyz;
				o.worldnormal = UnityObjectToWorldNormal(v.normal);
				o.noiseuv.xy = 3.0 * v.uv + _Time.y * float2(0.05, 0.0);
				o.noiseuv.zw = 10.0 * v.uv - _Time.y * float2(0.15, 0.0);
				UNITY_TRANSFER_FOG(o,o.vertex);
				return o;
			}
			
			fixed4 frag (v2f i) : SV_Target
			{
				// sample the texture				
				float3 noise01 = tex2D(_Noise, i.noiseuv.xy).rgr;
				float3 noise02 = tex2D(_Noise, i.noiseuv.zw).grg;

				fixed4 col = tex2D(_MainTex, i.uv + 0.03 * (noise01.xy - noise02.xy));

				i.worldnormal.xyz = normalize(i.worldnormal.xyz + 0.05 * (noise01 - noise02));

				half3 worldViewDir = normalize(UnityWorldSpaceViewDir(i.worldpos));
				half3 worldRefl = reflect(-worldViewDir, i.worldnormal);

				half4 skyData = UNITY_SAMPLE_TEXCUBE(unity_SpecCube0, worldRefl);
				half3 indirectSpecular = DecodeHDR(skyData, unity_SpecCube0_HDR);

				half3 worldlight = normalize(UnityWorldSpaceLightDir(i.worldpos));
				half3 halfDir = normalize(worldlight + worldViewDir);
				half specular = pow(saturate(dot(halfDir, i.worldnormal)),100.0);

				half fresnel = max(0.4 - saturate(dot(worldViewDir, i.worldnormal)),0.0);

				half alpha = saturate(_WaterColor.a + fresnel);

				col.rgb = lerp(col.rgb, _WaterColor.rgb, alpha);
				col.rgb += 0.23 * alpha * indirectSpecular * (1.0 + fresnel);
				col.rgb += 0.03 * specular;
				// apply fog
				UNITY_APPLY_FOG(i.fogCoord, col);
				return col;
			}
			ENDCG
		}
	}
}
