// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "Custom/Projector/ColorSector" 
{
	Properties 
	{
		_Color("Tint Color", Color) = (1,1,1,1)
		_Args("x:Falloff y:Amplify",Vector) = (1,1,0,0)
		_ShadowTex("Cookie", 2D) = "gray" {}
		_Angle("Angle",Range(-1,1)) = -1
		_Inner("InnerRadius",Range(0,0.5)) = 0
		_EdgeWidth("EdgeWidth",Range(0,0.05)) = 0
		_EdgeColor("EdgeColor",Color) = (1,1,1,1)
		
		[Enum(UnityEngine.Rendering.BlendMode)] _SrcBlend ("Src Blend Mode", Float) = 1
        [Enum(UnityEngine.Rendering.BlendMode)] _DstBlend ("Dst Blend Mode", Float) = 1
	}

	Subshader 
	{
		Tags{ "Queue" = "Transparent" "IgnoreProjector" = "True" "RenderType" = "Transparent" }
		Pass
		{
			Blend[_SrcBlend][_DstBlend]
			Cull Off ZWrite Off Fog{ Mode Off }
			ColorMask RGB
			
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			#include "UnityCG.cginc"

			struct v2f 
			{
				float4 uvShadow : TEXCOORD0;
				float4 pos : SV_POSITION;
			};

			float4x4 unity_Projector;

			v2f vert(float4 vertex : POSITION)
			{
				v2f o;
				o.pos = UnityObjectToClipPos(vertex);
				o.uvShadow = mul(unity_Projector, vertex);
				return o;
			}

			sampler2D _ShadowTex;
			fixed4 _Color;
			half4 _Args;
			float _Angle;
			float _Inner;
			float _EdgeWidth;
			fixed4 _EdgeColor;

			fixed4 frag(v2f i) : SV_Target
			{
				float x = i.uvShadow.x;
				float y = i.uvShadow.y;
				float2 uvoffset = normalize(float2(x - 0.5,y - 0.5)); 
				float angle = dot(uvoffset,float2(0,1));
				float edgeAlpha = smoothstep(_Angle,_Angle + _EdgeWidth,angle);
				//edgeAlpha = step((abs(_Angle) + _EdgeWidth),1.0) * edgeAlpha;
				clip(angle -_Angle);
				clip(length(float2(x - 0.5,y - 0.5))  - _Inner);
				
				// Apply alpha mask
				fixed4 texCookie = tex2Dproj(_ShadowTex, UNITY_PROJ_COORD(i.uvShadow));
				fixed4 outColor = _Color * texCookie.rgba;
				fixed4 edgeColor = fixed4(_EdgeColor.xyz,1)*(1- edgeAlpha) + edgeAlpha*texCookie.rgba;
				// Attenuation
				float depth = i.uvShadow.z; // [-1 (near), 1 (far)]
				fixed4 finalColor =  outColor * clamp(1.0 - abs(depth) + _Args.x, 0.0, 1.0)*_Args.y;
				float check = step(_Angle + _EdgeWidth,angle);
				fixed4 withEdge = (check * finalColor  + (1- check) * edgeColor);
				half mask = sign(0.5-length(float2(x - 0.5,y - 0.5)));
				return withEdge * mask;
			}
			ENDCG
		}
	}
}
