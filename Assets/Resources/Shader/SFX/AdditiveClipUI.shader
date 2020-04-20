// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "Custom/SFX/AdditiveClipUI" 
{
	Properties
	{
		_MainTex("Particle Texture", 2D) = "white" {}
		_ClipRange0("ClipRange", Vector) = (-1, -1, 1.0, 1.0)
		_ClipArgs0("ClipArgs", Vector) = (1.0, 1.0, 0.0, 1.0)
	}
	SubShader
	{
		Tags{ "Queue" = "Transparent" "IgnoreProjector" = "True" "RenderType" = "Transparent" }
		Blend SrcAlpha One
		Cull Off ZWrite Off Fog{ Mode Off }
		Pass
		{
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			#pragma enable_d3d11_debug_symbols

			#include "UnityCG.cginc"
			#include "../NGUI/UI_Include.cginc"
			struct appdata_t 
			{
				float4 vertex : POSITION;
				fixed4 color : COLOR;
				half2 texcoord : TEXCOORD0;
			};

			struct v2f 
			{
				half4 vertex : SV_POSITION;
				fixed4 color : COLOR;
				half2 texcoord : TEXCOORD0;
				half2 pos : TEXCOORD1;
			};
			sampler2D _MainTex;
			float4 _MainTex_ST;
			float4x4 _PanelModelInverse;
			//half4 _ClipRange0;

			v2f vert(appdata_t v)
			{
				v2f o;
				o.vertex = UnityObjectToClipPos(v.vertex);
				o.color = v.color;
				o.texcoord = TRANSFORM_TEX(v.texcoord,_MainTex);
				float4 p=mul(_PanelModelInverse,mul(unity_ObjectToWorld,v.vertex));
				o.pos.xy = Clip1(p);
				return o;
			}

			fixed4 frag(v2f i) : SV_Target
			{
				fixed4 color = i.color*tex2D(_MainTex, i.texcoord);

				color=UI1Clip(color,i.pos);
				return color;
			}
			ENDCG
		}
	}
}