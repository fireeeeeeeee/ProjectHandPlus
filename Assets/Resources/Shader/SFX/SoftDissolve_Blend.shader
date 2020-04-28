Shader "Custom/SFX/SoftDissolve_Blend" {
    Properties {
        _Color ("Color", Color) = (1,1,1,1)
        _Base ("Base", 2D) = "bump" {}
        _BaseIntensity("BaseIntensity",Range(0,5))=1
        _DissolveSoftness ("DissolveSoftness", Range(0, 1)) = 1
        _Dissolve ("Dissolve", 2D) = "white" {}
        _Dissolve_Edge ("Dissolve_Edge", Range(0, 5)) = 0
        _Mask ("Mask", 2D) = "white" {}
        [MaterialToggle] _Mask_OR_ParticleAlpha ("Mask_OR_ParticleAlpha", Float ) = 0
        _Base_U_Speed ("Base_U_Speed", Float ) = 0
        _Base_V_Speed ("Base_V_Speed", Float ) = 0
        _Dissolve_U_Speed ("Dissolve_U_Speed", Float ) = 0
        _Dissolve_V_Speed ("Dissolve_V_Speed", Float ) = 0
        [HideInInspector]_Cutoff ("Alpha cutoff", Range(0,1)) = 0.5
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
            uniform float4 _Color;
            uniform sampler2D _Base; uniform float4 _Base_ST;
            uniform float _DissolveSoftness;
            uniform sampler2D _Dissolve; uniform float4 _Dissolve_ST;
            uniform float _Dissolve_Edge;
            uniform sampler2D _Mask; uniform float4 _Mask_ST;
            uniform fixed _Mask_OR_ParticleAlpha;
            uniform float _Base_U_Speed;
            uniform float _Base_V_Speed;
            uniform float _Dissolve_U_Speed;
            uniform float _Dissolve_V_Speed;
            float _BaseIntensity;
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
                float4 node_5175 = _Time;
                float4 node_4971 = _Time;
                float2 node_4977 = (float2((i.uv0.r+(_Base_U_Speed*node_4971.g)),(i.uv0.g+(node_4971.g*_Base_V_Speed)))+node_5175.g*float2(0,0));
                float4 _Base_var = tex2D(_Base,TRANSFORM_TEX(node_4977, _Base));
                _Base_var*=_BaseIntensity;
                float3 emissive = (i.vertexColor.rgb*_Color.rgb*_Base_var.rgb);
                float3 finalColor = emissive;
                float4 node_5628 = _Time;
                float2 node_31 = (float2((i.uv0.r+(_Dissolve_U_Speed*node_5628.g)),((node_5628.g*_Dissolve_V_Speed)+i.uv0.g))+node_5175.g*float2(0,0));
                float4 _Dissolve_var = tex2D(_Dissolve,TRANSFORM_TEX(node_31, _Dissolve));
                float4 _Mask_var = tex2D(_Mask,TRANSFORM_TEX(i.uv0, _Mask));
                float node_3635 = 0.0;
                float node_6488 = 1.0;
                float node_5811 = (_DissolveSoftness*(-1.0));
                float node_6418 = (node_5811 + ( ((lerp( i.vertexColor.a, (i.vertexColor.a*_Mask_var.g), _Mask_OR_ParticleAlpha )*_Dissolve_Edge) - node_3635) * (node_6488 - node_5811) ) / (node_6488 - node_3635));
                return fixed4(finalColor,saturate(((1.0*_Base_var.b)*((_Dissolve_var.r-node_6418)/((node_6418+_DissolveSoftness)-node_6418)))));
            }
            ENDCG
        }
    }
    FallBack "Diffuse"
    CustomEditor "ShaderForgeMaterialInspector"
}
