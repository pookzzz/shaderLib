uniform sampler2D iChannel0; // inputNoise
uniform sampler2D iChannel1; // inputBump
uniform float     iTime;
uniform vec3      iResolution;
uniform float     paramSpeed;

const float pi = 3.14159;

float getTimeVal() {
    return 15.0 + iTime * paramSpeed / 100.0;
}

vec4 mapFunc(in vec3 pos) {
    float timeVal = getTimeVal();
    vec3 pn = normalize(pos);

    vec2 texC = vec2(0.0);
    texC.y = -acos(pn.y) / pi;
    texC.x = atan(-pn.z, -pn.x) / pi;
    texC.x += timeVal * 0.01;

    vec3 tex1 = texture2D(iChannel1, texC.xy * 2.0).xyz * 1.5;
    tex1 = texture2D(iChannel1, texC.yx * 1.0 + tex1.xy * 0.1).xyz;

    vec3 tex2 = texture2D(iChannel0, texC.xy * 2.0).xyz * 1.5;
    tex2 = texture2D(iChannel0, texC.yx * 1.0 + tex1.xy * 0.2).xyz;

    float mask1 = clamp(tex1.z * -3.0 + 1.2, 0.0, 1.0);
    float mask2 = clamp(mask1 + tex1.x + (abs(pos.y * 9.0) - 7.0), 0.0, 1.0) * (tex2.x + 0.2);

    float tex3 = texture2D(iChannel0,
                           (texC.xy + vec2(timeVal * 0.025,
                                           sin(timeVal * 0.05) * 0.1)) * 3.0 +
                           tex1.xy * 0.1).x;
    tex3 = texture2D(iChannel1,
                     texC.xy * 2.0 -
                     vec2(timeVal * 0.125,
                          cos(timeVal * 0.05) * 0.15) +
                     tex1.yx * 0.1).y - tex3 -
           clamp(mask1 - 0.75, 0.0, 1.0);

    vec3 c = mix(vec3(0.4, 0.3, 0.1), vec3(0.3, 0.6, 0.2), mask1) * tex2;
    c = mix(c, vec3(0.8, 0.7, 0.4),
            clamp(tex1.z * 2.0 - 1.0 - abs(pn.y * 3.0), 0.0, 0.5) * 2.0);
    c = mix(c, vec3(0.0, 0.1, 0.6) * (tex2 * 0.65 + 0.25),
            clamp(mask1 * 4.0 - 3.0, 0.0, 1.0));
    c = mix(c, vec3(1.0), mask2);
    c += clamp(tex3 * 1.5, 0.0, 1.0);

    mask1 = mix(mask1, 0.0, clamp(tex3 * 10.0, 0.0, 1.0));
    return vec4(c, length(pos) - 1.0 + mask1 * 0.01);
}

vec4 castRay(in vec3 ro, in vec3 rd, in float maxd) {
    float precis = 0.001;
    float h = precis * 2.0;
    float t = 0.0;
    vec3 m = vec3(-1.0);
    for (int i = 0; i < 20; i++) {
        if (abs(h) < precis || t > maxd) continue;
        t += h;
        vec4 res = mapFunc(ro + rd * t);
        h = res.w;
        m = res.xyz;
    }

    if (t > maxd) m = vec3(-1.0);
    return vec4(m, t);
}

float softshadow(in vec3 ro, in vec3 rd, in float mint, in float maxt, in float k) {
    float res = 1.0;
    float t = mint;
    for (int i = 0; i < 30; i++) {
        if (t < maxt) {
            float h = mapFunc(ro + rd * t).w;
            res = min(res, k * h / t);
            t += 0.02;
        }
    }
    return clamp(res, 0.0, 1.0);
}

vec3 calcNormal(in vec3 pos) {
    vec3 eps = vec3(0.001, 0.0, 0.0);
    vec3 nor = vec3(
        mapFunc(pos + eps.xyy).w - mapFunc(pos - eps.xyy).w,
        mapFunc(pos + eps.yxy).w - mapFunc(pos - eps.yxy).w,
        mapFunc(pos + eps.yyx).w - mapFunc(pos - eps.yyx).w);
    return normalize(nor);
}

float calcAO(in vec3 pos, in vec3 nor) {
    float totao = 0.0;
    float sca = 1.0;
    for (int aoi = 0; aoi < 5; aoi++) {
        float hr = 0.01 + 0.05 * float(aoi);
        vec3 aopos = nor * hr + pos;
        float dd = mapFunc(aopos).w;
        totao += -(dd - hr) * sca;
        sca *= 0.75;
    }
    return clamp(1.0 - 4.0 * totao, 0.0, 1.0);
}

vec3 render(in vec3 ro, in vec3 rd, in vec2 p) {
    float timeVal = getTimeVal();
    vec4 res = castRay(ro, rd, 20.0);
    float t = res.w;
    vec3 m = res.xyz;
    vec3 lig = normalize(vec3(cos(timeVal * 0.1), 0.0, sin(timeVal * 0.1)));

    if (m.x > -0.5) {
        vec3 pos = ro + t * rd;
        vec3 nor = calcNormal(pos);
        float ao = calcAO(pos, nor);
        float amb = clamp(0.5 + 0.5 * nor.y, 0.0, 1.0);
        float dif = clamp(dot(nor, lig), 0.0, 1.0);
        float bac = clamp(dot(nor, normalize(vec3(-lig.x, 0.0, -lig.z))), 0.0, 1.0) *
                    clamp(1.0 - pos.y, 0.0, 1.0);

        float sh = 1.0;
        if (dif > 0.02) {
            sh = softshadow(pos, lig, 0.02, 10.0, 7.0);
            dif *= sh;
        }

        vec3 brdf = vec3(0.0);
        brdf += 0.20 * amb * vec3(0.10, 0.11, 0.23) * ao;
        brdf += 0.20 * bac * vec3(0.15, 0.15, 0.15) * ao;
        brdf += 1.20 * dif * vec3(1.00, 0.90, 0.70);

        float pp = clamp(dot(reflect(rd, nor), lig), 0.0, 1.0);
        float spe = sh * pow(pp, 16.0);
        float fre = ao * pow(clamp(1.0 + dot(nor, rd), 0.0, 1.0), 12.0);

        m = m * brdf +
            ((0.5 + dif) * fre * vec3(0.10, 0.21, 0.53)) +
            (spe * 5.0 * m.z * dif);
    }

    float dSq = dot(p, p);
    if (dSq > 0.82) {
        float d = sqrt(dSq);
        m = mix(vec3(1.0), vec3(0.1, 0.33, 1.0), smoothstep(0.74, 1.0, d));
        m += mix(m, vec3(0.0, 0.02, 0.2), smoothstep(0.8, 1.2, d));
        m *= dot(rd, lig) * 0.5 + 1.5;
        m *= smoothstep(1.1, 0.8, sqrt(d));
    }

    return clamp(m, 0.0, 1.0);
}

void mainImage(out vec4 fragColor, in vec2 fragCoord) {
    vec2 res = iResolution.xy;
    vec2 q = fragCoord.xy / res;
    vec2 p = q * 2.0 - 1.0;
    p.x *= res.x / res.y;

    vec3 ro = vec3(-3.0, 0.0, 0.0);
    vec3 ta = vec3(0.0);

    vec3 cw = normalize(ta - ro);
    vec3 cp = vec3(0.0, 1.0, 0.0);
    vec3 cu = normalize(cross(cw, cp));
    vec3 cv = normalize(cross(cu, cw));
    vec3 rd = normalize(p.x * cu + p.y * cv + 2.5 * cw);

    vec3 col = render(ro, rd, p);
    col = pow(col * 1.2, vec3(1.0 / 2.2));

    fragColor = vec4(col, 1.0);
}