uniform float time;
uniform float deg1;
uniform float deg2;
uniform vec3 xyzOffset;

uniform vec2 vecForManip[10];

vec4 sphere (vec4 z) {
    float r2 = dot (z.xyz, z.xyz);
    if (r2 < 2.0)
        z *= (1.0 / r2);
    else z *= 0.5;

    return z;
}
    
// SDF box
vec3 box (vec3 z) {
    return clamp (z, -1.0, 1.0) * 2.0 - z;
}
    
float DE0 (vec3 pos) {
    vec2 m = vec2(0.0);
    vec3 from = vec3 (0.0);
    vec3 z = pos - from;
    float r = dot (pos - from, pos - from) * pow (length (z), 2.0);
    return (1.0 - smoothstep (0.0, 0.01, r)) * 0.01;
}

float DE2 (vec3 pos) {
    vec2 m = vec2(0.0);
    // vec3 params = vec3 (0.22, 0.5, 0.5);
    vec3 params = vec3 (vecForManip[0].x+cos(time+vecForManip[2].y)+sin(time+vecForManip[4].y), vecForManip[0].y+cos(time+vecForManip[2].y)+sin(time+vecForManip[4].x), vecForManip[3].x*vecForManip[3].y+cos(time+vecForManip[2].x));
    vec4 scale = vec4 (((-10.0*(vecForManip[1].x+1))*(vecForManip[1].y+1)) * 0.272321);
    vec4 p = vec4 (pos, 1.0), p0 = p;
    vec4 c = vec4 (params, 0.5) - 0.5; // param = 0..1

    for (float i = 0.0; i < 10.0; i++) {
        p.xyz = box (p.xyz);
        p = sphere (p);
        p = p * scale + c;
    }

    return length (p.xyz) / p.w;
}

float DE (vec3 pos) {

    float d0 = DE0 (pos);
    float d2 = DE2 (pos);

    return max (d0, d2);
}

float rayToSky(vec3 pos)
{
    vec3 dir = vec3(cos(radians(time+270)), sin(radians(time+270)), 0.1);
    dir = normalize(dir);

    pos = pos + dir;

    int loop = 500;
    float distTraveled = 0;
    float minHitDist = 0.1;
    float minTraceDist = 1000;

    for(int i = 0; i < loop; i++){
        vec3 curPos = pos+distTraveled*dir;

        float distToJump = DE(curPos);
        
        //infSphere(curPos);
        
        //min(distance(vec3(0, 0, 15), curPos)-5, distance(vec3(cos(time*2)*9, sin(time*2)*9, 15), curPos)-3); // 5 is circle rad

        if (distToJump < minHitDist){
            return 1;
        }

        if (distToJump > minTraceDist){
            return 0;
        }

        distTraveled += distToJump;
    }
    
    return 0;
}

vec4 effect( vec4 color, Image tex, vec2 texture_coords, vec2 screen_coords )
{
    texture_coords = vec2(screen_coords.x/1920, screen_coords.y/1080);
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

        //closest point
        float de = DE(curPos);

        //adding floor
        float floorLevel = 5;
        float distToFloor = floorLevel-curPos.y;

        float distToJump = min(distToFloor, de);
        
        //infSphere(curPos);
        
        //min(distance(vec3(0, 0, 15), curPos)-5, distance(vec3(cos(time*2)*9, sin(time*2)*9, 15), curPos)-3); // 5 is circle rad

        if (distToJump < minHitDist){
            float shadows = 0;
            if (distToJump == distToFloor)
                shadows = rayToSky(curPos);

            float aO = 1.0/(float(i)/10.0);
            return vec4(0.2+aO * cos(curPos.x+(10+time/10))-shadows, 0.2+aO * cos(curPos.y+(20+time/10))-shadows, 0.2+aO * cos(curPos.z+(30+time/10))-shadows, 1);
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