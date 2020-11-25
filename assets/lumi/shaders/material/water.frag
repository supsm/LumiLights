#include lumi:shaders/lib/noise.glsl
#include lumi:shaders/api/varying.glsl
#include frex:shaders/api/fragment.glsl

void frx_startFragment(inout frx_FragmentData fragData) {

    fragData.spriteColor.rgb *= fragData.spriteColor.rgb;
	vec3 worldPos = frx_modelOriginWorldPos() + frx_var0.xyz;

    if(fragData.vertexNormal.y > 0.01) {
		// water wavyness parameter
		float timeScale = 2; 		// speed
		float noiseScale = 2; 		// wavelength
		float noiseAmp = 0.03125 * noiseScale;// * timeScale; // amplitude

		// inferred parameter
		float renderTime = frx_renderSeconds() * 0.5 * timeScale;
		float microSample = 0.01 * noiseScale;

		// base noise
		float noise = l2_noise(worldPos, renderTime, noiseScale, noiseAmp);

		// normal recalculation
		vec3 noiseOrigin = vec3(0, noise, 0);
		vec3 noiseTangent = vec3(microSample, l2_noise(worldPos + vec3(microSample,0,0), renderTime, noiseScale, noiseAmp), 0) - noiseOrigin;
		vec3 noiseBitangent = vec3(0, l2_noise(worldPos + vec3(0,0,microSample), renderTime, noiseScale, noiseAmp), microSample) - noiseOrigin;

		// noisy normal
		vec3 noisyNormal = normalize(cross(noiseBitangent, noiseTangent));
        fragData.vertexNormal = noisyNormal;
	}
}
