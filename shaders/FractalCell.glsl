uniform sampler2D iChannel0; // inputNoise
uniform float     iTime;
uniform vec3      iResolution;
uniform float     paramSpeed;
uniform bool      UseLigthModulation;

// Parallax scrolling fractal galaxy (CBS)

float field(in vec3 p, float s) {
    float strength = 7.0 + 0.03 * log(1.0e-6 + fract(sin(iTime * paramSpeed / 100.0) * 4373.11));
    float accum = s / 4.0;
    float prev = 0.0;
    float tw = 0.0;
    for (int i = 0; i < 26; ++i) {
        float mag = dot(p, p);
        p = abs(p) / mag + vec3(-0.5, -0.4, -1.5);
        float w = exp(-float(i) / 7.0);
        accum += w * exp(-strength * pow(abs(mag - prev), 2.2));
        tw += w;
        prev = mag;
    }
    return max(0.0, 5.0 * accum / tw - 0.7);
}

float field2(in vec3 p, float s) {
    float strength = 7.0 + 0.03 * log(1.0e-6 + fract(sin(iTime * paramSpeed / 100.0) * 4373.11));
    float accum = s / 4.0;
    float prev = 0.0;
    float tw = 0.0;
    for (int i = 0; i < 18; ++i) {
        float mag = dot(p, p);
        p = abs(p) / mag + vec3(-0.5, -0.4, -1.5);
        float w = exp(-float(i) / 7.0);
        accum += w * exp(-strength * pow(abs(mag - prev), 2.2));
        tw += w;
        prev = mag;
    }
    return max(0.0, 5.0 * accum / tw - 0.7);
}

vec3 nrand3(vec2 co) {
    vec3 a = fract(cos(co.x * 8.3e-3 + co.y) * vec3(1.3e5, 4.7e5, 2.9e5));
    vec3 b = fract(sin(co.x * 0.3e-3 + co.y) * vec3(8.1e5, 1.0e5, 0.1e5));
    return mix(a, b, 0.5);
}

void mainImage(out vec4 fragColor, in vec2 fragCoord) {
    vec2 res = iResolution.xy;
    vec2 uv = 2.0 * fragCoord.xy / res - 1.0;
    vec2 uvs = uv * res / max(res.x, res.y);
    vec3 p = vec3(uvs / 4.0, 0.0) + vec3(1.0, -1.3, 0.0);
    p += 0.2 * vec3(
        sin(iTime * paramSpeed / 100.0 / 16.0),
        sin(iTime * paramSpeed / 100.0 / 12.0),
        sin(iTime * paramSpeed / 100.0 / 128.0));

    float freqs[4];
    if (UseLigthModulation) {
        freqs[0] = texture2D(iChannel0, vec2(0.01, 0.25)).x;
        freqs[1] = texture2D(iChannel0, vec2(0.07, 0.25)).x;
        freqs[2] = texture2D(iChannel0, vec2(0.15, 0.25)).x;
        freqs[3] = texture2D(iChannel0, vec2(0.30, 0.25)).x;
    } else {
        freqs[0] = 0.5;
        freqs[1] = 0.5;
        freqs[2] = 0.5;
        freqs[3] = 0.5;
    }

    float t = field(p, freqs[2]);
    float v = (1.0 - exp((abs(uv.x) - 1.0) * 6.0)) *
              (1.0 - exp((abs(uv.y) - 1.0) * 6.0));

    vec3 p2 = vec3(
        uvs / (4.0 + sin(iTime * paramSpeed / 100.0 * 0.11) * 0.2 + 0.2 +
               sin(iTime * paramSpeed / 100.0 * 0.15) * 0.3 + 0.4),
        1.5) + vec3(2.0, -1.3, -1.0);
    p2 += 0.25 * vec3(
        sin(iTime * paramSpeed / 100.0 / 16.0),
        sin(iTime * paramSpeed / 100.0 / 12.0),
        sin(iTime * paramSpeed / 100.0 / 128.0));
    float t2 = field2(p2, freqs[3]);
    vec4 c2 = mix(0.4, 1.0, v) *
              vec4(1.3 * t2 * t2 * t2,
                   1.8 * t2 * t2,
                   t2 * freqs[0],
                   t2);

    vec2 seed  = p.xy * 2.0;
    seed = floor(seed * res.x);
    vec3 rnd = nrand3(seed);
    vec4 starcolor = vec4(pow(rnd.y, 40.0));

    vec2 seed2 = p2.xy * 2.0;
    seed2 = floor(seed2 * res.x);
    vec3 rnd2 = nrand3(seed2);
    starcolor += vec4(pow(rnd2.y, 40.0));

    vec4 col = mix(freqs[3] - 0.3, 1.0, v) *
               vec4(1.5 * freqs[2] * t * t * t,
                    1.2 * freqs[1] * t * t,
                    freqs[3] * t,
                    1.0) + c2 + starcolor;

    fragColor = col;
}