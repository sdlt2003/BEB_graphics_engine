#version 120

uniform mat4 modelToCameraMatrix;
uniform mat4 cameraToClipMatrix;
uniform mat4 modelToWorldMatrix;
uniform mat4 modelToClipMatrix;

uniform int active_lights_n; // Number of active lights (< MG_MAX_LIGHT)
uniform vec3 scene_ambient;  // rgb

uniform struct light_t {
	vec4 position;    // Camera space
	vec3 diffuse;     // rgb
	vec3 specular;    // rgb
	vec3 attenuation; // (constant, lineal, quadratic)
	vec3 spotDir;     // Camera space
	float cosCutOff;  // cutOff cosine (zero if not spotlight)
	float exponent;   // spotlight exponent (zero if not spotlight)
} theLights[4];       // MG_MAX_LIGHTS

uniform struct material_t {
	vec3  diffuse;    // rgb
	vec3  specular;   // rgb
	float alpha;
	float shininess;
} theMaterial;

attribute vec3 v_position; // Model space
attribute vec3 v_normal;   // Model space
attribute vec2 v_texCoord;

varying vec4 f_color;
varying vec2 f_texCoord;

// Calculates the Lambertian shading factor between a surface normal and a light vector
float lambert (in vec3 n, in vec3 l){
	return max(0, dot(n,l));
}

// Calculates the diffuse component of the lighting equation
vec3 diffusion (in vec3 m_diff, in vec3 s_diff){
	return m_diff * s_diff;
}

// Calculates the specular component of the lighting equation
vec3 speculation(in vec3 m_spec, in vec3 s_spec, in vec3 v_pos, in vec3 l_pos, in float shininess, in vec3 n, in vec3 v) {
    vec3 l = l_pos - v_pos;
	vec3 r = 2 * dot(n,l) * n - l;									
    float spec_intensity = pow(max(dot(r,v), 0.0), shininess); 
    return spec_intensity * m_spec * s_spec; 
}

// Calculates the total lighting contribution from a directional light
vec3 dir_light(in vec3 m_diff, in vec3 s_diff, in vec3 m_spec, in vec3 s_spec, in vec3 v_position, in vec3 position, in float shininess, in vec3 n, in vec3 v){

	vec3 i_diff = diffusion(m_diff, s_diff);
	vec3 i_spec = speculation(m_spec, s_spec, v_position, position, shininess, n, v);

	vec3 l_v = normalize(v_position - position);
	float lam = lambert(n, l_v);

	return lam * (i_diff + i_spec);
}
/* 
// Calculates the total lighting contribution from a local light
void local_light(in vec3 attenuation, in vec3 m_diff, in vec3 s_diff, in vec3 m_spec, in vec3 s_spec, in vec3 v_position, in vec3 position, in float shininess, in vec n, in vec4 v, out vec4 i_total) {

	vec3 i_diff = diffusion(m_diff, s_diff);
	vec3 i_spec = speculation(m_spec, s_spec, v_position, position, shininess, n, v);

	vec3 l_v = normalize(v_position - position);
	float lam = lambert(n, l_v);

	float att_intensit = 1 / (attenuation[0] + attenuation[1] * norm + attenuation[2] * pow(norm,2));
																	
	i_total = att_intensit + lam * (i_diff + i_spec);			
}

// calculates the total lighting contribution from a spotlight light
void spotlight_light(in vec3 attenuation, in vec3 m_diff, in vec3 s_diff, in vec3 spotDir, in vec3 m_spec, in vec3 s_spec, in vec3 v_position, in vec3 position, in float shininess, in vec3 n, in vec3 v, out vec3 i_total) {

	vec3 i_diff = diffusion(m_diff, s_diff);
	vec3 i_spec = speculation(m_spec, s_spec, shininess, l, n, v);

	vec3 l_v = normalize(l_pos - v_pos);
	
	float c_spot = lambert(-l_v, s_dir);							
	float lam = lambert(n, l_v);

	i_total = pow(c_spot,exponent) * lam * (i_diff + i_spec);
} */

void main() {	

	vec4 cam_pos = modelToCameraMatrix * vec4(v_position, 1);
	vec4 cam_normal = normalize(modelToCameraMatrix * vec4(v_normal, 0));

	vec4 v = normalize(-cam_pos);
	if ( theLights[0].position.w == 0 ) {
		f_color.xyz = dir_light(theMaterial.diffuse, theLights[0].diffuse, theMaterial.specular, theLights[0].specular, cam_pos.xyz, theLights[0].position.xyz, theMaterial.shininess, cam_normal.xyz, v.xyz);
		
	} else {
		//sadhbas
	}

	gl_Position = modelToClipMatrix * vec4(v_position, 1);

}

