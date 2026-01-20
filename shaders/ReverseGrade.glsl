uniform vec3 iResolution;
uniform sampler2D iChannel0;
uniform sampler2D iChannel1;
uniform sampler2D iChannel2;
uniform int premultiplied;
uniform vec3 s_whitePoint, s_blackPoint;
uniform vec3 t_whitePoint, t_blackPoint;

void mainImage(out vec4 fragColor, in vec2 fragCoord) {
    vec2 uv = fragCoord.xy / iResolution.xy;

    vec3 source = texture2D(iChannel0, uv).rgb;
    vec3 target = texture2D(iChannel1, uv).rgb;
    float alpha = texture2D(iChannel2, uv).r;

    vec3 result = vec3(1.0);

    if (premultiplied == 1)
        if (alpha != 0.0)
            result = source / vec3(alpha);
        else
            result = vec3(0.0);

    // White Balance Source
    result = vec3((source - s_blackPoint) / s_whitePoint);

    // White Balance to Target Values
    result = vec3((result * t_whitePoint) + t_blackPoint);

    if (premultiplied == 1)
        fragColor = vec4(result * vec3(alpha), alpha);
    else
        fragColor = vec4(result, alpha);
}