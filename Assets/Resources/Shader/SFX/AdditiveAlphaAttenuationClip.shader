// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "Custom/SFX/AdditiveAlphaAttenuationClip" 
{
    Properties 
	{
        _Color ("Color", Color) = (1,1,1,1)
        _Texture ("Texture", 2D) = "white" {}
        _Strength ("Strength", Float ) = 1
        _Alpha_attenuation ("Alpha_attenuation", Range(-1, 0)) = 0
		_ClipRange0("ClipRange", Vector) = (-1, -1, 1.0, 1.0)
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
            #include "UnityCG.cginc"
            struct VertexInput 
			{
                float4 vertex : POSITION;
                half2 texcoord0 : TEXCOORD0;
                fixed4 vertexColor : COLOR;
            };
            struct VertexOutput 
			{
                float4 pos : SV_POSITION;
                half2 uv0 : TEXCOORD0;
                fixed3 vertexColor : COLOR;
				half2 screenPos: TEXCOORD1;
            };

			sampler2D _Texture;
			half4 _Texture_ST;
			fixed4 _Color;
			fixed _Strength;
			fixed _Alpha_attenuation;
			half4 _ClipRange0;

            VertexOutput vert (VertexInput v) 
			{
                VertexOutput o = (VertexOutput)0;
                o.uv0 = TRANSFORM_TEX(v.texcoord0, _Texture);
                o.vertexColor = v.vertexColor*_Color.rgb*v.vertexColor.a*_Color.a;
                o.pos = UnityObjectToClipPos(v.vertex );
				o.screenPos = o.pos.xy;
                return o;
            }

            fixed4 frag(VertexOutput i) : COLOR 
			{
                fixed4 _Texture_var = tex2D(_Texture,i.uv0);
				//float4 screenPos = ComputeScreenPos(i.pos);
				half2 inside1 = step(_ClipRange0.xy, i.screenPos.xy);
				half2 inside2 = step(i.screenPos.xy, _ClipRange0.zw);
				fixed4 col;
				col.rgb = _Texture_var.rgb*i.vertexColor.rgb*_Texture_var.a*_Strength + _Alpha_attenuation;
				col.a = inside1.x * inside1.y * inside2.x * inside2.y;
				return col;
				//return fixed4(_Texture_var.rgb*i.vertexColor.rgb*_Texture_var.a*_Strength + _Alpha_attenuation, 1);// inside1.x * inside1.y * inside2.x * inside2.y);
            }
            ENDCG
        }
    }
}
