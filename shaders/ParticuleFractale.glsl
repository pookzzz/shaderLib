uniform float iTime;
uniform vec3  iResolution;
uniform float paramSpeed;
uniform bool  paramWarp;

void mainImage(out vec4 fragColor, in vec2 fragCoord) {
    float s = 0.0;
    float v = 0.0;

    for (int r = 0; r < 140; r++) {
        vec3 p = vec3(0.3, 0.2, floor(iTime * paramSpeed) * 0.005)
               + s * vec3(fragCoord.xy * 0.00003 - vec2(0.009, 0.005), 1.0);

        if (paramWarp) {
            p.xy += 0.1 * sin(vec2(p.z * 6.28318) + iTime);
        }

        p.z = fract(p.z);

        for (int i = 0; i < 18; i++) {
            p = abs(p) / dot(p, p) * 2.0 - 1.0;
        }

        v += length(p * p) * (0.75 - s) * 0.0015;
        s += 0.005;
    }

    vec3 col = v * vec3(0.9, 0.625, v);
    fragColor = vec4(col, 1.0);
}