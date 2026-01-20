// uniform float iTime;

// void mainImage(out vec4 fragColor, in vec2 fragCoord) {
//     vec2 uv = fragCoord.xy / iResolution.xy;
//     fragColor = vec4(uv, 0.5 + 0.5 * sin(iTime), 1.0);
// }

uniform vec3 iResolution;
uniform sampler2D iChannel0;
uniform float amount;
uniform int type;

void mainImage(out vec4 fragColor, in vec2 fragCoord) {
   vec2 uv = fragCoord.xy / iResolution.xy;
	vec3 source = texture2D(iChannel0, uv).rgb;
	vec3 result = source;
	vec3 suppressed = source;
	
	if (type == 0)
	suppressed.g = min((source.r + source.b) * 0.5, suppressed.g);
	else if (type == 1)
	suppressed.b = min((source.g + source.r) * 0.5, suppressed.b);
	else if (type == 2)
	suppressed.r = min((source.g + source.b) * 0.5, suppressed.r);
	
	result = mix(source, suppressed, amount);
	
	fragColor = vec4(result, 1.0);
}

