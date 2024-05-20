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

	// Calculates the total lighting contribution from a directional light
	vec3 calculateDirectionalLight(vec3 lightDir, vec3 normal, vec3 viewDir, vec3 lightColor, float shininess) {
		vec3 i_diff = vec3(0.0); 
		vec3 i_spec = vec3(0.0); 

		float lam = lambert(normal, lightDir);
		if(lam > 0.0) {
			i_diff = lightColor * theMaterial.diffuse;

			vec3 reflectDir = reflect(lightDir, normal);
			float spec = pow(lambert(viewDir, reflectDir), shininess);
			i_spec = spec * lightColor * theMaterial.specular;
		}
		return (lam * (i_diff + i_spec));
	}

	// Calculates the total lighting contribution from a local light
	vec3 calculateLocalLight(vec3 lightPos, vec3 vertPos, vec3 normal, vec3 viewDir, vec3 lightColor, vec3 materialDiffuse, vec3 materialSpecular, float shininess, vec3 att) {
		vec3 i_diff = vec3(0.0);
		vec3 i_spec = vec3(0.0);

		vec3 l = normalize(lightPos - vertPos);
		float d = length(lightPos - vertPos);

		float attenuation = 1.0 / (att.x + att.y * d + att.z * d * d);

		float NoL = lambert(normal, l);
		if (NoL > 0.0) {
			i_diff = lightColor * theMaterial.diffuse * attenuation;

			vec3 reflectDir = reflect(-l, normal);
			float spec = pow(lambert(viewDir, reflectDir), shininess);
			i_spec = spec * lightColor * theMaterial.specular * attenuation;
		}
		return (NoL * (i_diff + i_spec));
	}

	// Calculates the total lighting contribution from a spotlight light
	vec3 calculateSpotLight(int i, vec3 l, vec3 spotDir, float cutoff, float exponent, vec3 vertPos, vec3 normal, vec3 viewDir, vec3 materialSpecular, float shininess, vec3 att) {
		vec3 i_diff = vec3(0.0);
		vec3 i_spec = vec3(0.0);

		vec3 dir = normalize(theLights[i].spotDir);
		float cos = dot(dir, -l);
		float c_spot = 0.0;
		float NoL = 0.0;

		if (cos > theLights[i].cosCutOff) {
			if (cos > 0.0) {
				NoL = lambert(normal, l);
				if (NoL > 0.0) {
					c_spot = pow(cos, theLights[i].exponent);
					i_diff = theMaterial.diffuse * theLights[i].diffuse;

					vec3 reflectDir = reflect(-l, normal);
					float spec = pow(lambert(viewDir, reflectDir), shininess);

					i_spec = spec * theMaterial.specular * theLights[i].specular;
				}
			}
		}
		return (c_spot * NoL * (i_diff + i_spec));
	}



	void main() {	
		vec3 i_total = vec3(0.0);
		vec3 l;

		vec3 position_eye = (modelToCameraMatrix * vec4(v_position, 1.0)).xyz;
		vec3 normal_eye = normalize((modelToCameraMatrix * vec4(v_normal, 0.0)).xyz);
		vec3 view_direction = normalize(position_eye); // Uso directo

		for (int i = 0; i < active_lights_n; i++) {
			vec3 light_contrib;

			if (theLights[i].position.w == 0.0) { // directional light
				light_contrib = calculateDirectionalLight(
					normalize(-theLights[i].position.xyz), normal_eye, view_direction,
					theLights[i].diffuse, theMaterial.shininess
				);
			} else { 
				vec3 light_vector = theLights[i].position.xyz - position_eye;
				float distance = length(light_vector);
				vec3 light_direction = normalize(light_vector);

				if (theLights[i].cosCutOff == 0.0) { // positional light
					light_contrib = calculateLocalLight(
						theLights[i].position.xyz, position_eye, normal_eye, view_direction,
						theLights[i].diffuse, theMaterial.diffuse, theMaterial.specular,
						theMaterial.shininess, theLights[i].attenuation
					);
				} else { // Spotlight
					l = normalize(theLights[i].position.xyz - position_eye);
					light_contrib = calculateSpotLight(
						i, l, theLights[i].spotDir, theLights[i].cosCutOff,
						theLights[i].exponent, position_eye, normal_eye, view_direction,
						theMaterial.specular, theMaterial.shininess, theLights[i].attenuation
					);
				}
			}

			i_total += light_contrib;
		}

		f_color = vec4(i_total + scene_ambient, 1.0);
		f_texCoord = v_texCoord;
		gl_Position = modelToClipMatrix * vec4(v_position, 1.0);
	}


