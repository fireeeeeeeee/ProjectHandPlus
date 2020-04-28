// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "Custom/SFX/AdditiveAlphaAttenuationClipUI" 
{
    Properties 
	{
        _Color ("Color", Color) = (1,1,1,1)
        _Texture ("Texture", 2D) = "white" {}
        _Strength ("Strength", Float ) = 1
        _Alpha_attenuation ("Alpha_attenuation", Range(-1, 0)) = 0
		_ClipRange0("ClipRange", Vector) = (-1, -1, 1.0, 1.0)
		_ClipArgs0("ClipArgs", Vector) = (1.0, 1.0, 0.0, 1.0)
    }
    SubShader 
	{
		Tags{ "Queue" = "Transparent" "IgnoreProjector" = "True" "RenderType" = "Transparent" }
		Blend SrcAlpha One
		Cull Off ZWrite Off Fog{ Mode Off }
        LOD 100
        Pass 
		{            
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #include "UnityCG.cginc"
            #include "../NGUI/UI_Include.cginc"
            struct VertexInput 
			{
                float4 vertex : POSITION;
                float2 texcoord0 : TEXCOORD0;
                float4 vertexColor : COLOR;
            };
            struct VertexOutput 
			{
                float2 pos : TEXCOORD1;
                float2 uv0 : TEXCOORD0;
                float3 vertexColor : COLOR;
                float4 vertex : SV_POSITION;
				//half2 screenPos: TEXCOORD1;
            };

			sampler2D _Texture;
			float4 _Texture_ST;
			float4 _Color;
			float _Strength;
			float _Alpha_attenuation;
			//half4 _ClipRange0;
            float4x4 _PanelModelInverse;

            VertexOutput vert (VertexInput v) 
			{
                VertexOutput o = (VertexOutput)0;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv0 = TRANSFORM_TEX(v.texcoord0, _Texture);
                o.vertexColor = v.vertexColor*_Color.rgb*v.vertexColor.a*_Color.a;
                float4 p=mul(_PanelModelInverse,mul(unity_ObjectToWorld,v.vertex));
				o.pos.xy = Clip1(p);
                return o;
            }

            float4 frag(VertexOutput i) : COLOR 
			{
                float4 _Texture_var = tex2D(_Texture,i.uv0);
				// half2 inside1 = step(_ClipRange0.xy, i.screenPos.xy);
				// half2 inside2 = step(i.screenPos.xy, _ClipRange0.zw);
				float4 col;
				col.rgb = _Texture_var.rgb*i.vertexColor.rgb*_Texture_var.a*_Strength + _Alpha_attenuation;
				//col.a = inside1.x * inside1.y * inside2.x * inside2.y;
                col.a=1;
                col=UI1Clip(col,i.pos);
				return col;				
            }
            ENDCG
        }
    }
}
