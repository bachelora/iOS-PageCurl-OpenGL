#version 300 es

precision mediump float;

uniform sampler2D s_front;
uniform sampler2D s_back;
//varying vec2 v_texCoord;
//varying vec3 v_normal;

in vec2 texcoord;

out vec4 fragColor;

void main()
{
   // gl_FragColor = vec4(1,1,1.0,1);
   // vec4 color = texture2D(s_tex, v_texCoord);
   // vec3 n = normalize(v_normal);
    if (gl_FrontFacing) {
        fragColor = texture(s_front, texcoord);
    }else{
        fragColor = texture(s_back, texcoord);
    }
    ;//vec4(1,0,0,1);
}
