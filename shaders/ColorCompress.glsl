uniform vec3 iResolution;
uniform sampler2D iChannel0; // front
uniform sampler2D iChannel1; // matte

uniform vec3  color_target;
uniform float hue_strength;
uniform float sat_strength;
uniform float lum_strength;
uniform int   strength_curve; // kept for compatibility, acts as a dummy selector

// Simple stand‑in: in Flame this evaluates a user curve. Here we just clamp x.
float adskEvalDynCurves(int curve, float x) {
    return clamp(x, 0.0, 1.0);
}

// Standard hsv/rgb helpers (same signature as the Matchbox API)
vec3 adsk_rgb2hsv(vec3 c) {
    vec4 K = vec4(0.0, -1.0 / 3.0, 2.0 / 3.0, -1.0);
    vec4 p = mix(vec4(c.bg, K.wz), vec4(c.gb, K.xy), step(c.b, c.g));
    vec4 q = mix(vec4(p.xyw, c.r), vec4(c.r, p.yzx), step(p.x, c.r));

    float d = q.x - min(q.w, q.y);
    float e = 1.0e-10;
    return vec3(
        abs(q.z + (q.w - q.y) / (6.0 * d + e)),
        d / (q.x + e),
        q.x
    );
}

vec3 adsk_hsv2rgb(vec3 c) {
    vec4 K = vec4(1.0, 2.0 / 3.0, 1.0 / 3.0, 3.0);
    vec3 p = abs(fract(c.xxx + K.xyz) * 6.0 - K.www);
    return c.z * mix(K.xxx, clamp(p - K.xxx, 0.0, 1.0), c.y);
}

float hue_distance(vec3 a, vec3 b) {
    return min(abs(a.r - b.r), 1.0 - abs(a.r - b.r));
}

vec3 compress_hue(vec3 current, vec3 ref) {
    float old_hue  = current.r;
    float new_hue  = old_hue;
    float ref_hue  = ref.r;
    float distance = hue_distance(current, ref);

    float strength = adskEvalDynCurves(strength_curve, hue_strength / 100.0);
    float new_distance = distance - distance * (1.0 - strength);

    if ((old_hue < ref_hue && abs(ref_hue - old_hue) < 0.5) ||
        (old_hue > ref_hue && abs(ref_hue - old_hue) > 0.5)) {
        new_hue = old_hue + new_distance;
        if (new_hue > 1.0) new_hue -= 1.0;
    } else {
        new_hue = old_hue - new_distance;
        if (new_hue < 0.0) new_hue += 1.0;
    }

    return vec3(new_hue, current.g, current.b);
}

vec3 compress_sat(vec3 current, vec3 ref) {
    float old_sat  = current.g;
    float new_sat  = old_sat;
    float ref_sat  = ref.g;
    float distance = abs(current.g - ref.g);

    float strength = adskEvalDynCurves(strength_curve, sat_strength / 100.0);
    float new_distance = distance - distance * (1.0 - strength);

    new_sat += (old_sat < ref_sat) ? new_distance : -new_distance;

    return vec3(current.r, clamp(new_sat, 0.0, 1.0), current.b);
}

vec3 compress_lum(vec3 current, vec3 ref) {
    float old_lum  = current.b;
    float new_lum  = old_lum;
    float ref_lum  = ref.b;
    float distance = abs(old_lum - ref_lum);

    float strength = adskEvalDynCurves(strength_curve, lum_strength / 100.0);
    float new_distance = distance - distance * (1.0 - strength);

    new_lum += (old_lum < ref_lum) ? new_distance : -new_distance;

    return vec3(current.r, current.g, clamp(new_lum, 0.0, 1.0));
}

void mainImage(out vec4 fragColor, in vec2 fragCoord) {
    vec2 uv   = fragCoord.xy / iResolution.xy;
    vec4 in1  = texture2D(iChannel0, uv);
    float m   = texture2D(iChannel1, uv).r;

    vec3 ref     = adsk_rgb2hsv(color_target);
    vec3 current = adsk_rgb2hsv(in1.rgb);

    current = compress_hue(current, ref);
    current = compress_sat(current, ref);
    current = compress_lum(current, ref);

    fragColor = mix(in1, vec4(adsk_hsv2rgb(current), 1.0), m);
}