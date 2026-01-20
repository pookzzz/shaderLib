uniform vec3 iResolution;
uniform sampler2D iChannel0; // input1
uniform sampler2D iChannel1; // matte

uniform float strength;

// Reuse the same hsv helpers as in colorcompress
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

// Simplified vibrance:
// - strength = 1.0  → no change
// - strength = 0.0  → B&W
// - strength > 1.0  → increases saturation
vec4 vibrance(vec4 inCol, float vibranceAmount) {
    vec4 outCol = inCol;

    if (vibranceAmount <= 1.0) {
        float avg = dot(inCol.rgb, vec3(0.3, 0.6, 0.1));
        outCol.rgb = mix(vec3(avg), inCol.rgb, vibranceAmount);
    } else {
        vec3 hsv = adsk_rgb2hsv(inCol.rgb);
        float amt = vibranceAmount - 1.0;
        hsv.y = clamp(hsv.y * (1.0 + amt), 0.0, 1.0);
        outCol.rgb = adsk_hsv2rgb(hsv);
    }

    return outCol;
}

void mainImage(out vec4 fragColor, in vec2 fragCoord) {
    vec2 uv   = fragCoord.xy / iResolution.xy;
    vec4 in1  = texture2D(iChannel0, uv);
    float m   = texture2D(iChannel1, uv).r;

    fragColor = mix(in1, vibrance(in1, strength), m);
}