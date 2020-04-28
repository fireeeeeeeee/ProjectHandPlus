#ifndef GRASSINCLUDE
// Upgrade NOTE: excluded shader from DX11 because it uses wrong array syntax (type[size] name)
#pragma exclude_renderers d3d11
#define GRASSINCLUDE

#include "UnityCG.cginc"
#include "Lighting.cginc"

struct appdata
{
	float4 vertex : POSITION;
	float2 uv : TEXCOORD0;
    uint   id  : SV_VertexID;
    //非Instance模式使用 UV2
    half2 uv2 : TEXCOORD1;
    fixed4 color : COLOR;

    UNITY_VERTEX_INPUT_INSTANCE_ID
};

struct v2f
{
	float4 vertex : SV_POSITION;
	half2 uv : TEXCOORD0;
	half2 uv2 : TEXCOORD1;
	UNITY_FOG_COORDS(2)
	float4 worldPos : TEXCOORD3;
	fixed4 color : COLOR;
    float2 ShadowUV : TEXCOORD4;
    UNITY_VERTEX_INPUT_INSTANCE_ID 
};

sampler2D _MainTex;
sampler2D _Mask;
int _vertexNum;
uniform float4x4  TopCameraMatrix;
float4 _PannerPara;
float4 _Color;
float _LMExp;
//float4 _Intensity;


#define VERTEXNUM 500

//Caution:请不要为Instance添加LM支持
//5.6和2018实现不一样
//5.6使用cbuffer传参数
//详见UnityInstancing.cginc
// UNITY_INSTANCING_CBUFFER_START(Props)
//     UNITY_DEFINE_INSTANCED_PROP(float4[VERTEXNUM], _UV2)
// UNITY_INSTANCING_CBUFFER_END(Props)

// #if defined(INSTANCING_ON)
//     //uv2数组太大，不能放进cbuffer
        
//     uniform float4 _UV2[UNITY_INSTANCED_ARRAY_SIZE*VERTEXNUM];
// #endif

//_UV2数组太大不能放进uniform 数组，只能用ComputeBuffer

//
// StructuredBuffer<float4x4> _modelMatrix;
// struct LMUV{
//     float4 uvs[VERTEXNUM];
// };
// StructuredBuffer<float4> _test;
// StructuredBuffer<LMUV> _lmuv;
v2f vert(appdata v,uint instanceID : SV_InstanceID){
    v2f o = (v2f)0;

    UNITY_SETUP_INSTANCE_ID(v);
    UNITY_TRANSFER_INSTANCE_ID(v, o);
    // #if defined(INSTANCING_ON)
    //     #if defined(INSTANCING_INDIRECT)
    //         float4 worldPos=mul(_modelMatrix[instanceID],v.vertex);
    //         o.vertex=mul(UNITY_MATRIX_VP,worldPos);
    //     #else
    //         o.vertex=UnityObjectToClipPos(v.vertex);
    //     #endif
    // #else
    o.worldPos= mul(unity_ObjectToWorld,float4(v.vertex.xyz, 1.0));
    float4 WP = o.worldPos;
    float M_x = sin((_Time.y*_PannerPara.y*_PannerPara.w + length(WP.xyz))/max(_PannerPara.w,0.1))*fmod(v.uv.y*_PannerPara.z,1)*0.1*_PannerPara.x;
    float M_z = sin((_Time.y*_PannerPara.y*0.75*_PannerPara.w + length(WP.xyz))/max(_PannerPara.w,0.1))*fmod(v.uv.y*_PannerPara.z,1)*0.1*_PannerPara.x;
    o.vertex = mul(UNITY_MATRIX_VP, WP + float4(M_x,0,M_z, 0));
    //o.vertex=UnityObjectToClipPos(v.vertex);

    // #endif
    	
            // float4 worldPos=mul(_modelMatrix[instanceID],v.vertex);
            // o.vertex=mul(UNITY_MATRIX_VP,worldPos);
    o.uv=v.uv;
    #ifdef LM
        // #if defined(INSTANCING_ON)
        //      float2 uv2=_lmuv[unity_InstanceID].uvs[v.id].xy;
        //      o.uv2.xy = uv2 * unity_LightmapST.xy + unity_LightmapST.zw;
        // #else
             o.uv2.xy = v.uv2 * unity_LightmapST.xy + unity_LightmapST.zw;
        // #endif
        
    #endif

    #if defined(INSTANCING_ON)
        
        float4 tUV = mul(TopCameraMatrix, o.worldPos);
        o.ShadowUV = tUV.xy / tUV.w * 0.5f + 0.5f;
        #if UNITY_UV_STARTS_AT_TOP
		    o.ShadowUV = half2(o.ShadowUV.x, 1 - o.ShadowUV.y);
        #endif
    #endif

    // #if defined(CUSTOM_SHADOW_ON)
	//     o.worldPos = mul(unity_ObjectToWorld,float4(v.vertex.xyz, 1.0));
    // #endif

    UNITY_TRANSFER_FOG(o, o.vertex);
	return o;
}
uniform sampler2D _LMMap;
fixed4 frag(v2f i) : SV_Target{
    UNITY_SETUP_INSTANCE_ID(i)
    
    #ifdef MASKTEX
	    fixed4 mask = tex2D(_Mask, i.uv);
    #else
        fixed4 mask = fixed4(1,1,1,1);
    #endif

    #ifdef CUTOUT
        clip(mask.r - 0.5);
    #endif
   
    fixed4 col = tex2D(_MainTex, i.uv);

    // #ifdef LM	
    //     col.rgb *= DecodeLightmap(UNITY_SAMPLE_TEX2D(unity_Lightmap, i.uv2.xy)).rgb;
    // #else
    // #endif

    #if defined(INSTANCING_ON)
        half4 lmColor=tex2D(_LMMap, i.ShadowUV);
        float3 ambient=col.rgb*_Color;
        float3 gi=col.rgb*pow(lmColor.g, _LMExp);
        //col.rgb=ambient+gi;
        col.rgb=col.rgb*_Color*pow(lmColor.g, _LMExp);
    #endif

	UNITY_APPLY_FOG(i.fogCoord, col);

	return col;
}
#endif