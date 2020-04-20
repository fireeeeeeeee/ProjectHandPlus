//Scene cutout lightmap
Shader "Custom/Scene/Grass" 
{
	Properties 
	{
		//[HideInInspector]_Color("Main Color",Color)=(1,1,1,1)
		_MainTex ("Base (RGB) ", 2D) = "white" {}
		_Mask ("Mask (R)", 2D) = "white" {}
		_PannerPara("X-位移距离 Y-速度 Z-UV缩放 W-晃动间隔",vector)=(1,1,1,1)
		[HDR]_Color("亮度",Color)= (1,1,1,1)
		_LMExp("烘焙指数",Range(0,10))=2
		//_Intensity("亮度",Vector)=(1,1,1,1)
	}

	SubShader 
	{  
		Tags { "Queue"="AlphaTest" "IgnoreProjector"="True" "RenderType"="TransparentCutout"  }	  
		LOD 100        
		Pass 
		{
            //Tags { "LightMode" = "ForwardBase" }
			Tags { "LightMode" = "Vertex" }
			Cull Off
			CGPROGRAM
			//define
			#define CUTOUT
			#define MASKTEX
			#define SHLIGHTON
			#define DEFAULTBASECOLOR
			#define ORIGINAL_LIGHT
            //#define LM
            //#pragma target 3.5
            #pragma multi_compile_instancing
			#pragma multi_compile_fog
            //#pragma multi_compile_fwdbase nolightmap nodirlightmap nodynlightmap novertexlight
			// //head
			//#include "../Include/CommonHead_Include.cginc"
			//vertex&fragment
			#pragma vertex vert
			#pragma fragment frag
			// //include
			//#include "../Include/CommonBasic_Include.cginc"
            #include "../Include/GrassInclude.cginc"
			ENDCG 
		}

		Pass 
		{
			//Pc
			Tags { "LightMode" = "VertexLMRGBM" }
			Cull Off
			CGPROGRAM
			
			#pragma vertex vert
			#pragma fragment frag
			#pragma multi_compile_fog
            //#pragma target 3.5
            #pragma multi_compile_instancing
			#define CUTOUT
			#define MASKTEX
			#define LM
			// #include "../Include/SceneHead_Include.cginc"
			// #include "../Include/Scene_Include.cginc"
            #include "../Include/GrassInclude.cginc"
			ENDCG
		}

		Pass 
		{  
			//Moblie
			Tags { "LightMode" = "VertexLM" }
			Cull Off
			CGPROGRAM
			
			#pragma vertex vert
			#pragma fragment frag
			#pragma multi_compile_fog 
            //#pragma target 3.5
            #pragma multi_compile_instancing
			#define CUTOUT
			#define MASKTEX
			#define LM
			// #include "../Include/SceneHead_Include.cginc"
			// #include "../Include/Scene_Include.cginc"	
            #include "../Include/GrassInclude.cginc"		
			ENDCG
		}
		
		UsePass "Custom/Common/META"
		UsePass "Custom/Common/CASTSHADOWCUTOUT"
	} 
	FallBack Off
}