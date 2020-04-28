#ifndef GLOBALINCLUDE
#define GLOBALINCLUDE
#include "UnityCG.cginc"

float3 LambertianBRDF(float3 r,float3 wo,float3 wi)
{
    return r*UNITY_INV_PI;
}

float3 LightingTransport(float3 brdf,float3 irradiance)
{
    return brdf*irradiance;
}

float3 Irradiance(float3 light,float3 dir,float3 insectionNormal)
{
    float cosTheta=dot(dir,insectionNormal);
    return light*max(0,cosTheta);
}

#endif