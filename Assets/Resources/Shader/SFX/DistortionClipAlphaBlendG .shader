Shader "Custom/SFX/DistortionClipAlphaBlendG" {
    Properties {
        _Main_Color ("Main_Color", Color) = (1,1,1,1)
        _Main_Tex ("Main_Tex", 2D) = "white" {}
        _Main_QD ("Main_QD", Range(0, 5)) = 1
        _Main_Attentuation ("Main_Attentuation", Range(-1, 0)) = 0
        _Main_U_Speed ("Main_U_Speed", Float ) = 0
        _Main_V_Speed ("Main_V_Speed", Float ) = 0
        _Noise ("Noise", 2D) = "white" {}
        _Noise_QD ("Noise_QD", Range(0, 1)) = 0.2
        _Noise_U_Speed ("Noise_U_Speed", Float ) = 0
        _Noise_V_Speed ("Noise_V_Speed", Float ) = 0
        _Mask ("Mask", 2D) = "white" {}
        _Mask_QD ("Mask_QD", Range(0, 1)) = 1
        [MaterialToggle] _Opacity_Self ("Opacity_Self", Float ) = 0
    }
    SubShader {
        Tags {
            "IgnoreProjector"="True"
            "Queue"="Transparent"
            "RenderType"="Transparent"
        }
        Pass {
            Name "FORWARD"
            Tags {
                "LightMode"="ForwardBase"
            }
            Blend SrcAlpha OneMinusSrcAlpha
            Cull Off
            ZWrite Off
            
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #define UNITY_PASS_FORWARDBASE
            #include "UnityCG.cginc"
            #pragma multi_compile_fwdbase
            #pragma only_renderers d3d9 d3d11 glcore gles gles3 metal d3d11_9x 
            #pragma target 3.0
            uniform float4 _Main_Color;
            uniform sampler2D _Main_Tex; uniform float4 _Main_Tex_ST;
            uniform float _Main_QD;
            uniform float _Main_Attentuation;
            uniform float _Main_U_Speed;
            uniform float _Main_V_Speed;
            uniform sampler2D _Noise; uniform float4 _Noise_ST;
            uniform float _Noise_QD;
            uniform float _Noise_U_Speed;
            uniform float _Noise_V_Speed;
            uniform sampler2D _Mask; uniform float4 _Mask_ST;
            uniform float _Mask_QD;
            uniform fixed _Opacity_Self;
            struct VertexInput {
                float4 vertex : POSITION;
                float2 texcoord0 : TEXCOORD0;
                float4 vertexColor : COLOR;
            };
            struct VertexOutput {
                float4 pos : SV_POSITION;
                float2 uv0 : TEXCOORD0;
                float4 vertexColor : COLOR;
            };
            VertexOutput vert (VertexInput v) {
                VertexOutput o = (VertexOutput)0;
                o.uv0 = v.texcoord0;
                o.vertexColor = v.vertexColor;
                o.pos = UnityObjectToClipPos( v.vertex );
                return o;
            }
            float4 frag(VertexOutput i, float facing : VFACE) : COLOR {
                float4 time = _Time;
                float2 noiseUV = float2(((_Noise_U_Speed*time.g)+i.uv0.r),(i.uv0.g+(time.g*_Noise_V_Speed)));
                float4 noiseTex = tex2D(_Noise,TRANSFORM_TEX(noiseUV, _Noise));
                float2 maskUV = ((noiseTex.r*_Noise_QD)+i.uv0);
                float4 maskTex = tex2D(_Mask,TRANSFORM_TEX(maskUV, _Mask));
                clip((maskTex.g*_Mask_QD) - 0.5);

                float2 mainUV = float2(((_Main_U_Speed*time.g)+i.uv0.r),(i.uv0.g+(time.g*_Main_V_Speed)));
                float4 mainTex = tex2D(_Main_Tex,TRANSFORM_TEX(mainUV, _Main_Tex));
                float3 emissive = (_Main_Color.rgb*saturate(((mainTex.rgb+_Main_Attentuation)*_Main_QD))*i.vertexColor.rgb);
                float3 finalColor = emissive;
                return fixed4(finalColor,(i.vertexColor.a*lerp( saturate(((mainTex.r+_Main_Attentuation)*_Main_QD)), saturate(((mainTex.a+_Main_Attentuation)*_Main_QD)), _Opacity_Self )*_Main_Color.a));
            }
            ENDCG
        }
    }
    FallBack "Diffuse"
}
