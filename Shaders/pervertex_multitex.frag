#version 120

varying vec4 f_color;
varying vec2 f_texCoord;

uniform sampler2D texture0;
uniform sampler2D texture1;

uniform float uCloudOffset; // The offset of the cloud texture

void main() {
    vec4 t1 = texture2D(texture0, f_texCoord); 
    vec4 t2 = texture2D(texture1, f_texCoord + vec2(uCloudOffset, 0.0));
    
    vec4 ttotal = 0.5 * t1 + 0.5 * t2;
    
    gl_FragColor = ttotal;  // Establece el color final del fragmento
}
