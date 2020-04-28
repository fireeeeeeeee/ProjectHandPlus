Shader "Custom/SFX/Dissolution"
{
	Properties
	{
		_MainColor("Main Color",COLOR) = (1.0,1.0,1.0,1.0)
		_MainTex("Main Texture", 2D) = "white" {}
		_Mask("Mask Texture", 2D) = "white" {}
		_MaskScale("Mask Scale", range(0.1,10.0)) = 1.0
		_Color("Edge Color",COLOR) = (1.0,0.0,0.0,1.0)
		_BlendThreshold("Edge Width", range(0.001,0.2)) = 0.05
		_Hardness("Hardness",range(0.0,1.0)) = 0
		_DissolutionValue("DissolutionValue",range(0.4,1.0)) = 0.4
		[Toggle] _Dir("Dissolution Dir?", Float) = 0
	}
		SubShader
		{
			Tags { "RenderType" = "Transparent" "Queue" = "Transparent"}
			LOD 100

			Blend SrcAlpha OneMinusSrcAlpha
			Cull Off
			ZWrite Off
			Fog{ Mode Off }

			Pass
			{
				CGPROGRAM
				#pragma vertex vert
				#pragma fragment frag			
				#include "UnityCG.cginc"
				#pragma shader_feature _DIR_ON

				struct appdata
				{
					float4 vertex : POSITION;
					float2 uv : TEXCOORD0;
					#if _DIR_ON
						float2 uv2 : TEXCOORD1;
					#endif
				};

				struct v2f
				{
					float2 uv : TEXCOORD0;
					float2 uv2 : TEXCOORD1;
					float4 vertex : SV_POSITION;
					#if _DIR_ON
						float dissolutionDir : TEXCOORD2;
					#endif
				};

				sampler2D _MainTex;
				float4 _MainTex_ST;
				sampler2D _Mask;
				float4 _Mask_ST;
				fixed _BlendThreshold, _Hardness, _MaskScale;
				fixed _DissolutionValue;
				fixed4 _Color, _MainColor;


				v2f vert(appdata v)
				{
					v2f o;
					o.vertex = UnityObjectToClipPos(v.vertex);
					o.uv = TRANSFORM_TEX(v.uv, _MainTex);
					o.uv2 = TRANSFORM_TEX(v.uv, _Mask);
					#if _DIR_ON
						o.dissolutionDir = v.uv2.x;
					#endif
					return o;
				}

				fixed4 frag(v2f i) : SV_Target
				{
					// sample the texture
					fixed4 col = _MainColor * tex2D(_MainTex, i.uv);
					fixed4 mask = tex2D(_Mask, i.uv2);
					#if _DIR_ON
						mask *= i.dissolutionDir;
					#endif
					fixed blend = saturate(_MaskScale * mask.r + 1.0 - 2.0 * _DissolutionValue);//_MaskScale * mask.r调节mask图颜色范围
					fixed BlendThreshold = step(_BlendThreshold,blend);//标记边缘
					col.rgb = lerp(_Color.rgb, col.rgb, BlendThreshold);
					col.a *= lerp(blend * _Color.a / _BlendThreshold , 1.0 , BlendThreshold);//blend * _Color.a / _BlendThreshold 边缘过度范围标定为0~1
					col.a = saturate(col.a + _Hardness * ceil(col.a * blend)); //调节边缘硬度
					//clip(col.a - 0.01);
					return col;
				}
				ENDCG
			}
		}
}
