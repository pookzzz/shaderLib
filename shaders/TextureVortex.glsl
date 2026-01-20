uniform sampler2D iChannel0; // inputVideo
uniform float     iTime;
uniform vec3      iResolution;

uniform vec2  paramPos;
uniform float paramSpeed;
uniform float paramWaveSize;

const float PI = 3.14159;

void mainImage(out vec4 fragColor, in vec2 fragCoord) {
    vec2 res = iResolution.xy;
    vec2 rcpResolution = 1.0 / res;
    vec2 uv = fragCoord.xy * rcpResolution;

    vec4 mouseNDC = -1.0 + vec4(paramPos.xy, uv) * 2.0;
    vec2 diff = mouseNDC.zw - mouseNDC.xy;

    float dist = length(diff);
    float angle = PI * dist * paramWaveSize + iTime * paramSpeed / 100.0;

    vec3 sincos;
    sincos.x = sin(angle);
    sincos.y = cos(angle);
    sincos.z = -sincos.x;

    vec2 newUV;
    mouseNDC.zw -= mouseNDC.xy;
    newUV.x = dot(mouseNDC.zw, sincos.yz);
    newUV.y = dot(mouseNDC.zw, sincos.xy);

    vec3 col = texture2D(iChannel0, newUV.xy).xyz;
    fragColor = vec4(col, 1.0);
}