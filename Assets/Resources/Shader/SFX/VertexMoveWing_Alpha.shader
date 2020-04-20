Shader "Custom/SFX/VertexMoveWing_Alpha"
{
	Properties
	{
		_MainTex ("Texture", 2D) = "black" {}
		_MaskTex ("MaskTex", 2D) = "black" {}		
		_FlowColor ("FlowColor",Color) = (0.0,0.0,0.0,0.5)
		_FlowParameter ("FlowInt,USpeed,VSpeed,DisInt",Vector) = (1.0,1.0,0.0,0.05)
		_SwingParameter ("Range,Segment,Speed",Vector) = (0.5,1.0,1.0,0.0)
	}
	SubShader
	{
		Tags { "RenderType"="Transparent" "Queue" = "Transparent"}
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

			struct appdata
			{
				float4 vertex : POSITION;
				float2 uv : TEXCOORD0;
				float2 uv2 : TEXCOORD1;
				float4 color : COLOR;
			};

			struct v2f
			{
				float2 uv : TEXCOORD0;
				float2 uv2 : TEXCOORD1;
				float4 vertex : SV_POSITION;
				float4 color : COLOR;
			};

			sampler2D _MainTex;
			float4 _MainTex_ST;
			sampler2D _MaskTex;
			float4 _MaskTex_ST;
			float4 _FlowColor;
			fixed4 _FlowParameter;
			fixed4 _SwingParameter;
			
			v2f vert (appdata v)
			{
				v2f o;
				v.vertex.y += 20.0 * _SwingParameter.x * v.uv2.x * sin(_SwingParameter.z * _Time.z + 6.0 * _SwingParameter.y * v.uv2.x + 4.0 * _SwingParameter.y * v.uv2.y);
				v.vertex.z += 20.0 * _SwingParameter.x * v.uv2.x * sin(_SwingParameter.z * _Time.z + 4.0 * _SwingParameter.y * v.uv2.x + 6.0 * _SwingParameter.y * v.uv2.y);
				o.vertex = UnityObjectToClipPos(v.vertex);
				o.uv = TRANSFORM_TEX(v.uv, _MainTex);
				o.uv2 = TRANSFORM_TEX(v.uv, _MaskTex) + _FlowParameter.yz * _Time.y;
				o.color = v.color;
				return o;
			}
			
			fixed4 frag (v2f i) : SV_Target
			{
				// sample the texture
				fixed alpha = tex2D(_MainTex, i.uv).a;
				fixed4 mask = tex2D(_MaskTex, i.uv2);
				fixed4 col = tex2D(_MainTex, i.uv + _FlowParameter.w * mask.g);
				col.rgb = lerp(col.rgb, _FlowColor.rgb * _FlowParameter.x, mask.r * _FlowColor.a) * i.color.rgb;
				col.a *= alpha * i.color.a;
				return col;
			}
			ENDCG
		}
	}
}
