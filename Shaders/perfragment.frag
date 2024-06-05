#version 120

uniform int active_lights_n; // Number of active lights (< MG_MAX_LIGHT)
uniform vec3 scene_ambient; // Scene ambient light

uniform struct light_t {
	vec4 position;    // Camera space
	vec3 diffuse;     // rgb
	vec3 specular;    // rgb
	vec3 attenuation; // (constant, lineal, quadratic)
	vec3 spotDir;     // Camera space
	float cosCutOff;  // cutOff cosine
	float exponent;
} theLights[4];     // MG_MAX_LIGHTS

uniform struct material_t {
	vec3  diffuse;
	vec3  specular;
	float alpha;
	float shininess;
} theMaterial;

uniform sampler2D texture0;

varying vec3 f_position;      // camera space
varying vec3 f_viewDirection; // camera space
varying vec3 f_normal;        // camera space
varying vec2 f_texCoord;


// Calculates the Lambertian shading factor between a surface normal and a light vector
float lambert (in vec3 n, in vec3 l){
    return max(0.0, dot(n, l));
}

// Calculates the total lighting contribution from a directional light
vec3 calculateDirectionalLight(int i, vec3 lightDir, vec3 normal, vec3 viewDir) {
    vec3 i_diff = vec3(0.0); 
    vec3 i_spec = vec3(0.0); 

    float lam = lambert(normal, lightDir);
    if (lam > 0.0) {
        i_diff = theLights[i].diffuse * theMaterial.diffuse;

        vec3 reflectDir = reflect(lightDir, normal);
        float spec = pow(lambert(viewDir, reflectDir), theMaterial.shininess);
        i_spec = spec * theLights[i].specular * theMaterial.specular;
    }
    return (lam * (i_diff + i_spec));
}

// Calculates the total lighting contribution from a local light
vec3 calculateLocalLight(int i, vec3 l, vec3 vertPos, vec3 normal, vec3 viewDir) {
    vec3 i_diff = vec3(0.0);
    vec3 i_spec = vec3(0.0);

	// No attenuation factor here
    float NoL = lambert(normal, l);
    if (NoL > 0.0) {
        i_diff = theLights[i].diffuse * theMaterial.diffuse;

        vec3 reflectDir = reflect(-l, normal);
        float spec = pow(lambert(viewDir, reflectDir), theMaterial.shininess);
        i_spec = spec * theLights[i].specular * theMaterial.specular;
    }
    return (NoL * (i_diff + i_spec));
}

// Calculates the total lighting contribution from a spotlight light
vec3 calculateSpotLight(int i, vec3 l, vec3 normal, vec3 viewDir) {
    vec3 i_diff = vec3(0.0);
    vec3 i_spec = vec3(0.0);

    vec3 dir = normalize(theLights[i].spotDir);
    float cos = dot(dir, -l);
    float c_spot = 0.0;
	float NoL = 0.0;

    if (cos > theLights[i].cosCutOff) {
        if (cos > 0.0) {
            float NoL = lambert(normal, l);
            if (NoL > 0.0) {
                c_spot = pow(cos, theLights[i].exponent);
                i_diff = theMaterial.diffuse * theLights[i].diffuse;

                vec3 reflectDir = reflect(-l, normal);
                float spec = pow(lambert(viewDir, reflectDir), theMaterial.shininess);

                i_spec = spec * theMaterial.specular * theLights[i].specular;
            }
        }
    }
    return (c_spot * (i_diff + i_spec));
}


// no funciona el spotlight por alguna razón así que estoy simplificando el código
// todo lo posible para ver si me encuentro con el error

// estaba multiplicando el lambert donde no era (? bueno yo que se

void main() {  
    vec3 i_total = vec3(0.0);
	vec3 light_contrib = vec3(0.0);

    vec3 normal = normalize(f_normal);
    vec3 viewDir = normalize(f_viewDirection);

    for (int i = 0; i < active_lights_n; i++) {

        if (theLights[i].position.w == 0.0) { // directional light
			vec3 l = normalize(-theLights[i].position.xyz);
            light_contrib = calculateDirectionalLight(i, l, normal, viewDir);
        } else { 
            vec3 light_direction = normalize(theLights[i].position.xyz - f_position);

            if (theLights[i].cosCutOff == 0.0) { // positional light
                light_contrib = calculateLocalLight(i, light_direction, f_position, normal, viewDir);
            } else { // Spotlight
                light_contrib = calculateSpotLight(i, light_direction, normal, viewDir);
            }
        }
        i_total += light_contrib;
    }

    gl_FragColor = vec4(scene_ambient + i_total, 1.0) * (texture2D(texture0, f_texCoord));
}