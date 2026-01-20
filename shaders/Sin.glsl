uniform float iTime;
uniform vec3  iResolution;
uniform float paramSinSpeed;
uniform float paramSinSPosX;

void mainImage(out vec4 fragColor, in vec2 fragCoord) {
    vec2 res = iResolution.xy;
    vec2 uPos = fragCoord.xy / res;

    uPos.x -= paramSinSPosX;

    float vertColor = 0.0;
    for (float i = 0.0; i < 1.0; i += 0.25) {
        float t = iTime * paramSinSpeed / 100.0 * (i + 0.9);
        uPos.x += sin(uPos.y + t) * 0.3;
        float fTemp = abs(1.0 / uPos.x / 100.0);
        vertColor += fTemp;
    }

    vec4 color = vec4(vertColor, vertColor, vertColor * 2.5, 1.0);
    fragColor = color;
}