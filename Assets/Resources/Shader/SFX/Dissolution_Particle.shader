Shader "Custom/SFX/Dissolution_Particle" {
	Properties
	{
		_MainTex("Main Texture", 2D) = "white" {}
		_MainMoveU("MainMoveSpeedU",range(-2.0,2.0)) = 0
		_MainMoveV("MainMoveSpeedV",range(-2.0,2.0)) = 0
		_Mask("Mask Texture", 2D) = "white" {}
		_Color("Edge Color",COLOR) = (1.0,0.0,0.0,0.5)
		_BlendThreshold("Edge Width", range(0.001,0.4)) = 0.05
		_Hardness("Hardness",range(0.01,1.0)) = 0.01
		_DistortionInt("DistortionInt",range(-0.5,0.5)) = 0.0
		_MoveSpeedU("MaskMoveSpeedU",range(-2.0,2.0)) = 0.5
		_MoveSpeedV("MaskMoveSpeedV",range(-2.0,2.0)) = 0
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
					float4 color: COLOR;
				};

				struct v2f
				{
					float2 uv : TEXCOORD0;
					float2 uv2 : TEXCOORD1;
					float4 vertex : SV_POSITION;
					#if _DIR_ON
					float dissolutionDir : TEXCOORD2;
					#endif
					float4 color: COLOR;
				};

				sampler2D _MainTex;
				float4 _MainTex_ST;
				sampler2D _Mask;
				float4 _Mask_ST;
				fixed _BlendThreshold, _Hardness, _DistortionInt, _MainMoveU, _MainMoveV, _MoveSpeedU, _MoveSpeedV;
				fixed4 _Color;


				v2f vert(appdata v)
				{
					v2f o;
					o.vertex = UnityObjectToClipPos(v.vertex);
					o.uv = TRANSFORM_TEX(v.uv, _MainTex) + _Time.y * float2(_MainMoveU, _MainMoveV);
					o.uv2 = TRANSFORM_TEX(v.uv, _Mask) + _Time.y * float2(_MoveSpeedU, _MoveSpeedV);
					#if _DIR_ON
					o.dissolutionDir = v.uv2.x;
					#endif
					o.color = v.color;
					return o;
				}

				fixed4 frag(v2f i) : SV_Target
				{
					// sample the texture
					//maskÍ¼G¿ØÖÆÈÜ½â£¬B¿ØÖÆÅ¤Çú
					fixed4 mask = tex2D(_Mask, i.uv2);
					fixed4 col = tex2D(_MainTex, i.uv + _DistortionInt * mask.b);
					col.rgb *= 2.0 * i.color.rgb;

					#if _DIR_ON
					mask *= i.dissolutionDir;
					#endif

					fixed blend = mask.g + 1.0 - 2.0 * lerp(1.0,-1.0,i.color.a);
					fixed BlendThreshold = step(_BlendThreshold,blend);
					col.rgb += lerp(_Color.rgb,0.0,BlendThreshold);
					col.a = lerp(2.0 * blend * _Color.a / _BlendThreshold , 1.0 , BlendThreshold) * col.a;
					clip(col.a - _Hardness);
					return col;
				}
				ENDCG
			}
		}
}
