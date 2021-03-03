#include lumi:shadow_config

/*******************************************************
 *  lumi:shaders/context/global/shadow.glsl            *
 *******************************************************
 *  Copyright (c) 2021 spiralhalo                      *
 *  Released WITHOUT WARRANTY under the terms of the   *
 *  GNU Lesser General Public License version 3 as     *
 *  published by the Free Software Foundation, Inc.    *
 *******************************************************/

#if defined(SHADOW_MAP_PRESENT)

const mat3 wKernel = mat3(
    0.07, 0.13, 0.07,
    0.13, 0.20, 0.13,
    0.07, 0.13, 0.07
);

vec3 shadowDist(int cascade, vec4 shadowViewPos)
{
    vec4 c = frx_shadowCenter(cascade);
    return abs((c.xyz - shadowViewPos.xyz) / c.w);
}

float calcShadowFactor(vec4 shadowViewPos) {
    vec3 d3 = shadowDist(3, shadowViewPos);
    vec3 d2 = shadowDist(2, shadowViewPos);
    vec3 d1 = shadowDist(1, shadowViewPos);
    int cascade = 0;
    float bias = 0.002; // biases are brute forced. receiver plane bias? what's that? (jk)
    if (d3.x < 1.0 && d3.y < 1.0 && d3.z < 1.0) {
        cascade = 3;
        #ifdef SHADOW_BOX_FILTERING
            bias = 0.00006;
        #else
            bias = 0.0;
        #endif
    } else if (d2.x < 1.0 && d2.y < 1.0 && d2.z < 1.0) {
        cascade = 2;
        #ifdef SHADOW_BOX_FILTERING
            bias = 0.00008;
        #else
            bias = 0.0;
        #endif
    } else if (d1.x < 1.0 && d1.y < 1.0 && d1.z < 1.0) {
        cascade = 1;
        #ifdef SHADOW_BOX_FILTERING
            bias = 0.0002;
        #else
            bias = 0.0;
        #endif
    }

    vec4 shadowCoords = frx_shadowProjectionMatrix(cascade) * shadowViewPos;
    shadowCoords.xyz = shadowCoords.xyz * 0.5 + 0.5; // Transform from screen coordinates to texture coordinates

    #ifdef SHADOW_BOX_FILTERING
        float inc = 1.0 / SHADOW_MAP_SIZE;
        vec2 shadowTexCoord;
        float shadowFactor = 0.0;
        vec2 offset;
        float w;
        for(int i = 0; i < 3; i++)
        {
            for(int j = 0; j < 3; j++)
            {
                offset.x = -inc + inc * j;
                offset.y = -inc + inc * i;
                w = wKernel[i][j];
                shadowFactor += w * shadow2DArray(frxs_shadowMap, vec4(shadowCoords.xy + offset, float(cascade), shadowCoords.z - bias)).r;
                // shadowFactor += (shadowCoords.xy != clamp(shadowCoords.xy, 0.0, 1.0))
                //               ? 1.0
                //               : shadow2DArray(frxs_shadowMap, vec4(shadowCoords.xy + offset, float(cascade), shadowCoords.z - bias)).r;
            }
        }
    #else
        float shadowFactor = shadow2DArray(frxs_shadowMap, vec4(shadowCoords.xy, float(cascade), shadowCoords.z - bias)).r;
    #endif
    
    return shadowFactor;
}
#endif
