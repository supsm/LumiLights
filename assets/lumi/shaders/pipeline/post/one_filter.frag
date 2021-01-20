#include lumi:shaders/pipeline/post/common.glsl
#include frex:shaders/lib/math.glsl
#include lumi:shaders/lib/util.glsl
#include lumi:shaders/lib/tile_noise.glsl

/*******************************************************
 *  lumi:shaders/pipeline/post/one_filter.frag         *
 *******************************************************
 *  Copyright (c) 2020-2021 spiralhalo                 *
 *  Released WITHOUT WARRANTY under the terms of the   *
 *  GNU Lesser General Public License version 3 as     *
 *  published by the Free Software Foundation, Inc.    *
 *******************************************************/

uniform sampler2D u_source;
uniform sampler2D u_depth;

vec2 inv_size = 1.0 / frxu_size;

const int size = 4;
void main()
{
    gl_FragData[0] = vec4(tile_denoise1_depth(v_texcoord, u_source, u_depth, inv_size, size), 0.0, 0.0, 1.0);
}