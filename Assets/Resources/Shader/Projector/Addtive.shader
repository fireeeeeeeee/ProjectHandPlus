Shader "Custom/Projector/Additive" 
{
	Properties 
	{
		_TintColor ("Tint Color", Color) = (0.5,0.5,0.5,0.5)
		_MainTex ("Particle Texture", 2D) = "white" {}
	}
	SubShader
	{
		Tags{ "Queue" = "Transparent" "IgnoreProjector" = "True" "RenderType" = "Transparent" }
		Blend SrcAlpha OneMinusSrcAlpha
		ColorMask RGB
		Cull Off ZWrite Off Fog{ Mode Off }
		Pass
		{

			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag

			#include "UnityCG.cginc"
			struct appdata_t 
			{
				float4 vertex : POSITION;
				fixed4 color : COLOR;
				float2 texcoord : TEXCOORD0;
			};

			struct v2f 
			{
				half4 vertex : SV_POSITION;
				fixed4 color : COLOR;
				half2 texcoord : TEXCOORD0;
				float4 projTexCoord : TEXCOORD1;
			};

			float4x4 unity_Projector;
	
			sampler2D _MainTex;
			fixed4 _TintColor;
			half4 _MainTex_ST;

			v2f vert(appdata_t v)
			{
				v2f o;
				o.vertex = UnityObjectToClipPos(v.vertex);
				o.color = v.color;
				o.projTexCoord= mul(unity_Projector, v.vertex);
				//o.texcoord = TRANSFORM_TEX(uvShadow,_MainTex);
				return o;
			}

			float Inside(float4 a,float2 x){
				float2 le=step(a.xy,x);
				float2 gr=step(x,a.zw);
				return le.x*le.y*gr.x*gr.y;
			}

			fixed4 frag(v2f i) : SV_Target
			{
				float2 uv=i.projTexCoord.xy/i.projTexCoord.w;
				uv=TRANSFORM_TEX(uv,_MainTex);
				float inside=Inside(float4(0,0,1,1),uv);
				float4 mainTex=tex2D(_MainTex, uv);
				float4 col;
				col.rgb=2.0f * i.color*_TintColor * mainTex.rgb;
				col.a=inside*mainTex.a;
				return col;
			}
			ENDCG
		}
	}
}
