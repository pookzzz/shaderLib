#ifdef GL_ES
precision mediump float;
#endif

uniform sampler2D u_scene;
uniform vec3 u_camera;
uniform vec3 u_light;

uniform vec2 u_resolution;
uniform vec2 u_mouse;
uniform float u_time;

varying vec4 v_position;
varying vec3 v_normal;
varying vec2 v_texcoord;

#include "lygia/distort/barrel.glsl"

void main(void) {
    vec4 color = vec4(0.0, 0.0, 0.0, 1.0);
    vec2 pixel = 1.0 / u_resolution;
    vec2 st = gl_FragCoord.xy * pixel;
    
#if defined(BACKGROUND)
    color.rgb += step(0.5, fract((st.x + st.y) * 10.0 + u_time));
    
#elif defined(POSTPROCESSING)
    color.rgb = texture2D(u_scene, st).rgb;
    
    float dist = distance(st, vec2(0.5, 0.5));

    vec2 offset = pixel * 5.;
    color.r = texture2D(u_scene, st + offset * dist).r;
    color.b = texture2D(u_scene, st - offset * dist).b;
    
#else
    color.rgb = v_normal.xyz * 0.5 + 0.5;
    // Diffuse shading from directional light
    vec3 n = normalize(v_normal);
    vec3 l = normalize(u_light - v_position.xyz);
    color.rgb *= dot(n, l) * 0.5 + 0.5;
#endif
    
    gl_FragColor = color;
}
