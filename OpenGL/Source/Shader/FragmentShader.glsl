#version 300 es

precision mediump float;

uniform sampler2D s_front;
uniform sampler2D s_back;
uniform int frontFacing;

in vec2 texcoord;

out vec4 fragColor;

void main()
{
    if (frontFacing == 1) {
        if (!gl_FrontFacing) {
            fragColor = texture(s_front, texcoord);
        }else{
            fragColor = texture(s_back, texcoord);
        }
    }else{
        if (gl_FrontFacing) {
            fragColor = texture(s_front, texcoord);
        }else{
            fragColor = texture(s_back, texcoord);
        }
    }
    
}
