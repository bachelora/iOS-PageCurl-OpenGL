#version 300 es

uniform mat4 u_mvpMatrix;
uniform vec4 u_mn;// m n width height

uniform vec3 direction;
uniform vec2 point;

layout (location = 0) in vec2 a_position;
layout (location = 1) in vec2 a_texCoord;


out vec2 texcoord;

#define M_PI 3.14159265358979323846264338327950288

void main()
{
    int row = gl_InstanceID/(int(u_mn.x));
    int col = gl_InstanceID%(int(u_mn.x));
    texcoord = vec2(a_texCoord.x + float(col)/u_mn.x,a_texCoord.y + float(row)/u_mn.y);
    vec3 pos = vec3(a_position.x + float(col) * u_mn.z/u_mn.x,a_position.y + float(row) * u_mn.w/u_mn.y,0);
  
    float distance = dot((point - pos.xy),direction.xy);
    if(distance > 0.f){
         vec2 bottom = pos.xy + distance * direction.xy;
         float moreThanHalfCir = (distance -  M_PI * direction.z);
    
          if(moreThanHalfCir >= 0.f){//exceed
            vec3 topPoint = vec3(bottom, float(2) * direction.z);
            pos = topPoint + moreThanHalfCir * vec3(direction.xy,0);
          }else{
    
            float angle = M_PI - distance / direction.z;
            float h = distance - sin(angle)*direction.z;
            float z = direction.z + cos(angle)*direction.z;
            vec3 vD = pos + h * vec3(direction.xy,0);
            pos = vec3(vD.xy,z);
    
          }
    }
    
    gl_Position = u_mvpMatrix * vec4(pos,1);
}
