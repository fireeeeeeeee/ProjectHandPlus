//如果主相机渲染原物件，则原物件一并进行扭曲。
Shader "Hidden/PPDistortion"
{
	Properties
	{
		_MainTex ("Texture", 2D) = "white" {}
		_MaskTex ("MaskTex", 2D) = "black" {}
		_Intensity("Intensity",float) = 0.0		
	}
	SubShader
	{
		Pass
		{
			Tags { "RenderType"="Transparent" "Queue" = "Transparent"}
			ZTest Always 
			ZWrite off 
			Cull off
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag			
			#include "UnityCG.cginc"

			struct appdata
			{
				float4 vertex : POSITION;
				float2 uv : TEXCOORD0;
			};

			struct v2f
			{
				float2 uv : TEXCOORD0;
				float2 uv2 : TEXCOORD1;
				float4 vertex : SV_POSITION;
			};

			sampler2D _MainTex;
			sampler2D _MaskTex;
			float _Intensity;
			
			v2f vert (appdata v)
			{	
				v2f o;	
				UNITY_INITIALIZE_OUTPUT(v2f,o);				
				o.vertex = UnityObjectToClipPos(v.vertex);
				o.uv = v.uv;
				return o;
			}
			
			fixed4 frag (v2f i) : SV_Target
			{
				// sample the texture
				fixed4 mask = tex2D(_MaskTex, i.uv);
				fixed dis = 0.3 * mask.r + 0.6 * mask.g + 0.1 * mask.b;
				fixed4 col = tex2D(_MainTex, i.uv + _Intensity * dis);
				return col;
				//return (mask.r + mask.g + mask.b);
			}
			ENDCG
		}
	}
	fallback off
}
