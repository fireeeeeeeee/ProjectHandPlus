#ifndef CHARACTER_ENTRY_INCLUDED
#define CHARACTER_ENTRY_INCLUDED

#include "UnityStandardConfig.cginc"
#include "UnityStandardCore.cginc"

half4 fragCharacter (VertexOutputForwardBase i)
{
    //5.6版本没有这个宏
    //UNITY_APPLY_DITHER_CROSSFADE(i.pos.xy);

    FRAGMENT_SETUP(s)

    UNITY_SETUP_INSTANCE_ID(i);
    UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX(i);

    UnityLight mainLight = MainLight ();
    UNITY_LIGHT_ATTENUATION(atten, i, s.posWorld);

    half occlusion = Occlusion(i.tex.xy);
    UnityGI gi = FragmentGI (s, occlusion, i.ambientOrLightmapUV, atten, mainLight);

    half4 c = UNITY_BRDF_PBS (s.diffColor, s.specColor, s.oneMinusReflectivity, s.smoothness, s.normalWorld, -s.eyeVec, gi.light, gi.indirect);
    c.rgb += Emission(i.tex.xy);

    //5.6版本没有这个宏
    //UNITY_EXTRACT_FOG_FROM_EYE_VEC(i);
    UNITY_APPLY_FOG(i.fogCoord, c.rgb);
    c=OutputForward (c, s.alpha);
    #ifdef UNITY_COLORSPACE_GAMMA
        c.rgb=LinearToGammaSpace(c.rgb);
    #endif

    return c;
}


VertexOutputForwardBase vertBase (VertexInput v) { return vertForwardBase(v); }
half4 fragBase (VertexOutputForwardBase i) : SV_Target { return fragCharacter(i); }

#endif 
