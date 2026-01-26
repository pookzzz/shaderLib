uniform float iTime;
uniform vec3  iResolution;
uniform float paramFlameSpeed;
uniform vec2  paramFlameDirection;
uniform vec3  paramColor1;
uniform vec3  paramColor2;

float noise(vec3 p) {
    vec3 i = floor(p);
    vec4 a = dot(i, vec3(1.0, 57.0, 21.0)) + vec4(0.0, 57.0, 21.0, 78.0);
    vec3 f = cos((p - i) * acos(-1.0)) * (-0.5) + 0.5;
    a = mix(sin(cos(a) * a), sin(cos(1.0 + a) * (1.0 + a)), f.x);
    a.xy = mix(a.xz, a.yw, f.y);
    return mix(a.x, a.y, f.z);
}

float sphere(vec3 p, vec4 spr) {
    return length(spr.xyz - p) - spr.w;
}

float fire(vec3 p) {
    float d = sphere(p * vec3(1.0, 0.5, 1.0), vec4(0.0, -1.0, 0.0, 1.0));
    return d + (noise(p + vec3(0.0, iTime * paramFlameSpeed / 100.0, 0.0)) +
                noise(p * 3.0) * 0.5) * 0.25 * (p.y);
}

float scene(vec3 p) {
    return min(100.0 - length(p), abs(fire(p)));
}

vec4 Raymarche(vec3 org, vec3 dir) {
    float d = 0.0;
    vec3  p = org;
    float glow = 0.0;
    float eps = 0.02;
    bool glowed = false;

    for (int i = 0; i < 64; i++) {
        d = scene(p) + eps;
        p += d * dir;
        if (d > eps) {
            if (fire(p) < 0.0) glowed = true;
            if (glowed) glow = float(i) / 64.0;
        }
    }
    return vec4(p, glow);
}

void mainImage(out vec4 fragColor, in vec2 fragCoord) {
    vec2 res = iResolution.xy;
    vec2 v = -1.0 + 2.0 * fragCoord.xy / res;
    v.x *= res.x / res.y;

    vec3 org = vec3(0.0, -2.0, 4.0);
    vec3 dir = normalize(vec3(v.x * paramFlameDirection.x, -v.y, -paramFlameDirection.y));
    vec4 p = Raymarche(org, dir);
    float glow = p.w;

    vec4 c1 = vec4(paramColor1, 1.0);
    vec4 c2 = vec4(paramColor2, 1.0);
    vec4 col = mix(vec4(0.0),
                   mix(c1, c2, p.y * 0.02 + 0.4),
                   pow(glow * 2.0, 4.0));

    fragColor = col;
}