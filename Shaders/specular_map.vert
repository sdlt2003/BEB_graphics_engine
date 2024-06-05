#version 120

attribute vec3 v_position;
attribute vec3 v_normal;
attribute vec2 v_texCoord;

uniform int active_lights_n; // Number of active lights (< MG_MAX_LIGHT)

uniform mat4 modelToCameraMatrix;
uniform mat4 cameraToClipMatrix;
uniform mat4 modelToWorldMatrix;
uniform mat4 modelToClipMatrix;

varying vec3 f_position;      // camera space
varying vec3 f_viewDirection; // camera space
varying vec3 f_normal;        // camera space
varying vec2 f_texCoord;

void main() {
	vec4 pos_camera_space = modelToCameraMatrix * vec4(v_position, 1.0);
    f_position = pos_camera_space.xyz;
    f_normal = (modelToCameraMatrix * vec4(v_normal, 0.0)).xyz;
    f_viewDirection = -f_position; // assuming the camera is at the origin
    f_texCoord = v_texCoord;
    
    gl_Position = modelToClipMatrix * vec4(v_position, 1.0);
}
