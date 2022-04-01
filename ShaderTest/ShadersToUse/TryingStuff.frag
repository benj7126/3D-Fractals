
uniform float time;
uniform float deg1;
uniform float deg2;
uniform vec3 xyzOffset;

uniform vec2 vecForManip[10];

float infSphere(vec3 pos){
    return distance(vec3(0, 0, 0), pos) - 4 - sin(pos.x*2)-sin(pos.y*2)-sin(pos.z*2);
}

vec4 effect( vec4 color, Image tex, vec2 texture_coords, vec2 screen_coords )
{
    texture_coords = vec2(screen_coords.x/600, screen_coords.y/600);
    vec2 texture_coords_center = texture_coords-0.5;

    vec3 ro = xyzOffset;
    vec3 rd = vec3(texture_coords_center.x, texture_coords_center.y, 1);

    float r1 = radians(deg1);
    float r2 = radians(deg2);
    rd *= mat3(
        vec3(1, 0, 0),
        vec3(0, cos(r1), -sin(r1)),
        vec3(0, sin(r1), cos(r1))
    );
    rd *= mat3( // around y
        vec3(cos(r2), 0, sin(r2)),
        vec3(0, 1, 0),
        vec3(-sin(r2), 0, cos(r2))
    );
    // rd *= mat3( // around z
    //    vec3(cos(r), -sin(r), 0),
    //    vec3(sin(r), cos(r), 0),
    //    vec3(0, 0, 1)
    // );

    int loop = 500;
    float distTraveled = 0;
    float minHitDist = 0.001;
    float maxTraceDist = 100;

    float maxRenderDist = 100;

    for(int i = 0; i < loop; i++){
        vec3 curPos = ro+distTraveled*rd;
        
        float distToJump = infSphere(curPos);
        
        //min(distance(vec3(0, 0, 15), curPos)-5, distance(vec3(cos(time*2)*9, sin(time*2)*9, 15), curPos)-3); // 5 is circle rad

        if (distToJump < minHitDist){
            float aO = 1.0/(float(i)/(10.0+vecForManip[1].x*10.0-vecForManip[1].y*10.0))+vecForManip[0].x-vecForManip[0].y;
            return vec4(0.2+aO, 0.2+aO, 0.2+aO, 1);
        }

        if (distToJump > maxTraceDist){
            return vec4(0, 0, 0, 0);
        }

        if (distTraveled > maxRenderDist){
            return vec4(0, 0, 0, 0);
        }

        distTraveled += distToJump;
    }
    
    return vec4(0, 0, 0, 1);
}