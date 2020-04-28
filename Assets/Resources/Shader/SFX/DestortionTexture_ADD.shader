Shader "Custom/SFX/DestortionTexture_Add"
{
	Properties
	{
		_Color ("MainColor", COLOR) = (1.0,1.0,1.0,1.0)
		_MainTex ("Texture", 2D) = "white" {}
		_Mask_Tex ("Destortion Texture",2D) = "black"{}
		_DisInt("Intensity",range(0.0,0.5)) = 0.2
		_USpeed("Mask_USpeed",range(0.0,1.0)) = 0.3
		_VSpeed("Mask_VSpeed",range(0.0,1.0)) = 0.0
	}
	SubShader
	{
		Tags{ "Queue" = "Transparent" "IgnoreProjector" = "True" "RenderType" = "Transparent" }
		Blend One One
		Cull Off ZWrite Off Fog{ Mode Off }

		Pass
		{
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			
			#include "UnityCG.cginc"

			struct appdata
			{
				float4 vertex : POSITION;
				float2 uv : TEXCOORD0;
				float4 color : COLOR;
			};

			struct v2f
			{
				float2 uv : TEXCOORD0;
				float2 uv2 : TEXCOORD1;
				float4 vertex : SV_POSITION;
				float4 color : COLOR;
			};

			float4 _Color;
			sampler2D _MainTex;
			float4 _MainTex_ST;
			sampler2D _Mask_Tex;
			float4 _Mask_Tex_ST;
			fixed _DisInt;
			fixed _USpeed;
			fixed _VSpeed;
			
			v2f vert (appdata v)
			{
				v2f o;
				o.vertex = UnityObjectToClipPos(v.vertex);
				o.uv = TRANSFORM_TEX(v.uv, _MainTex);
				o.uv2 = TRANSFORM_TEX(v.uv, _Mask_Tex);
				o.color = v.color;
				return o;
			}
			
			fixed4 frag (v2f i) : SV_Target
			{
				// sample the texture
				fixed4 distortion = tex2D(_Mask_Tex, i.uv2 + 3.0 * fixed2(_USpeed, _VSpeed) * _Time.y);
				fixed4 col = tex2D(_MainTex, i.uv + _DisInt * distortion.xy) * _Color;
				col.rgb *=10.0 * col.a * _Color.a * i.color.rgb * i.color.a;
				return col;
			}
			ENDCG
		}
	}
}
