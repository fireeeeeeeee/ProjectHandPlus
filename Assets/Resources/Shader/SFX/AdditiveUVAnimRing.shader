// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "Custom/SFX/AdditiveUVAnimRing"
{
	Properties 
	{
		_U_Time ("U_Time", Float ) = 1
		_V_Time ("V_Time", Float ) = 0
		_Min_Textures ("Min_Textures", 2D) = "white" {}
        _Intensity ("Intensity",range(0.0,3.0)) = 1.0
        _Angle("Angle",Range(0,359.9999))=180
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

            uniform half _U_Time;
            uniform half _V_Time;
            uniform sampler2D _Min_Textures; 
			uniform half4 _Min_Textures_ST;
            fixed _Intensity;
            float _Angle;

            struct VertexInput 
			{
                float4 vertex : POSITION;
                half2 texcoord0 : TEXCOORD0;
                fixed4 color : COLOR;
            };
            struct VertexOutput 
			{
                float4 pos : SV_POSITION;
                half2 uv0 : TEXCOORD0;
                fixed4 color : COLOR;
                float4 modelPos : TEXCOORD1;
            };

            VertexOutput vert (VertexInput v) 
			{
                VertexOutput o = (VertexOutput)0;
                o.uv0 = TRANSFORM_TEX(v.texcoord0, _Min_Textures);
				o.uv0 = o.uv0 + half2(_Time.y*_U_Time, _Time.y*_V_Time);
                o.modelPos=v.vertex;
                o.pos = UnityObjectToClipPos(v.vertex);
                o.color = v.color;
                return o;
            }
            fixed4 frag(VertexOutput i) : COLOR 
			{
                float rad=radians(_Angle);
                float2 threshold;
                threshold.x=cos(rad);
                threshold.y=sin(rad);

                float2 vertex=normalize(i.modelPos.xy) ;
                
                // 没有反三角函数。将极坐标转换成笛卡尔坐标比较
                // if y'>0 
                //     if x>x' && y>0
                //         a = 1
                //     else
                //         a=0
                //     end
                // else 
                //     if y>0 || x<x'
                //         a=1
                //     else 
                //         a=0
                //     end 
                // end 

                // 用step 替换 if else 。用乘法 替换 与操作。 用 saturate 和 加法 替换或操作
                // 用 step 和 插值方法替换最外层的 if else。


                float a= step(0,threshold.y)*step(threshold.x,vertex.x)*step(0,vertex.y)+(1-step(0,threshold.y))*saturate((step(0,vertex.y)+step(vertex.x,threshold.x))) ;
                a*=i.color.a;

                fixed4 color = tex2D(_Min_Textures,i.uv0);
                return fixed4((color.rgb*color.a) * i.color * _Intensity,a);
            }
            ENDCG
        }
    }
}
