// KE Gradient Tracker v.3
// Created by Ted Stanley (KuleshovEffect) May 2024
// Based on code from:
// Ivar's crok_gradient https://logik-matchbook.org/shader/crok_gradient
// Ivar's crok_gradient is based on https://www.shadertoy.com/view/ltjXDt by anastadunbar
// Tsoding's Straight Lines https://www.youtube.com/watch?v=cU5WcrU_YI4 + https://www.shadertoy.com/view/fst3DH
// Autodesks's PyramidBlur Example

uniform sampler2D front, matte;
uniform float adsk_result_w, adsk_result_h, adsk_result_pixelratio;
uniform vec2 starttrack, endtrack, startAdjust, endAdjust;
uniform float blurAmount, bias_adj;
//uniform bool overlay;
uniform int outputType;
// The UI width is based on the frame size
float width = adsk_result_h / 200.0;

#define PI 3.141592653589793238462

//Return a color for a given point, blurred by the blurAmount
vec3 get_color(vec2 pos)
{
    int intPart = int( blurAmount );
    
    if (intPart < 1)
        // There's no blur, so return the color
        return vec3(texture2D(front, pos).rgb);

    // Stolen from Autodesk's PyramidBlur
    vec3 accu = vec3(0.0);
    float energy = 0.0;
    vec3 endColor = vec3(0.0);
   
    for( int x = -intPart; x <= intPart; x++)
    {
        vec2 currentCoord = vec2(pos.x+float(x)/adsk_result_w, pos.y);
        vec3 aSample = texture2D(front, currentCoord).rgb;
        float anEnergy = 1.0 - ( abs(float(x)) / blurAmount );
        energy += anEnergy;
        accu += aSample * anEnergy;
    }

    for( int y = -intPart; y <= intPart; y++)
   {
      vec2 currentCoord = vec2(pos.x, pos.y+float(y)/adsk_result_h);
      vec3 aSample = texture2D(front, currentCoord).rgb;
      float anEnergy = 1.0 - ( abs(float(y)) / blurAmount );
      energy += anEnergy;
      accu += aSample * anEnergy;
   }
   
    endColor = (accu / energy);
    return endColor;
}

// Stolen from anastadunbar's Shadertoy
float gradient_linear2(vec2 uv, vec2 p1, vec2 p2)
{
    return clamp(dot(uv-p1,p2-p1)/dot(p2-p1,p2-p1),0.,1.);
}

// Stolen from Ivar's crok_gradient
float bias(float x, float b)
{
    b = -log2(1.0 - b);
    return 1.0 - pow(1.0 - pow(x, 1./b), b);
}

void main() {
	vec2 res = vec2(adsk_result_w, adsk_result_h);
    vec2 coords = gl_FragCoord.xy / vec2( adsk_result_w, adsk_result_h );
	vec3 frontpix = texture2D(front, coords).rgb;
    float mattepix = texture2D(matte, coords).r;
    vec2 start;
    vec2 end;

    if (width < 1.5)
        width = 1.5;
    
    // Get the Start and End coordinates from the user, add in the offset
    start.x = ((starttrack.x + startAdjust.x) + (adsk_result_w / 2.0)) / (adsk_result_w);
    start.y = ((starttrack.y + startAdjust.y) + (adsk_result_h / 2.0)) / (adsk_result_h);
    end.x = ((endtrack.x + endAdjust.x) + (adsk_result_w / 2.0)) / (adsk_result_w);
    end.y = ((endtrack.y + endAdjust.y) + (adsk_result_h / 2.0)) / (adsk_result_h);

    vec3 finalColor = vec3(0.0);
    vec3 startColor = vec3(0.0);
    vec3 endColor = vec3(0.0);

   
    // Get the colors for the two points
    startColor = get_color(start);
    endColor = get_color(end);
 
    // Stolen from Ivar's crok_gradient
    float drawing = 0.;
    drawing = gradient_linear2(coords,start,end);
    drawing = clamp(drawing, 0.0, 1.0);
    drawing = bias(drawing, bias_adj);
    finalColor = vec3(drawing * endColor + (1.0 - drawing) * startColor);
    
    // Output Ty[e is 'UI Overlay'
    if (outputType == 0)
    {
        // Output the front image, unless there should be some UI elements instead
        finalColor = frontpix;
        vec2 startOffset, endOffset;

        // The line drawing function I stole works in screen space, not UV space
        startOffset.x = starttrack.x + startAdjust.x + (adsk_result_w / 2.0);
        startOffset.y = starttrack.y + startAdjust.y + (adsk_result_h / 2.0);
        endOffset.x = endtrack.x + endAdjust.x + (adsk_result_w / 2.0);
        endOffset.y = endtrack.y + endAdjust.y + (adsk_result_h / 2.0);

        // Stolen from Tsoding, draws the UI
        vec2 p3 = gl_FragCoord.xy;
        vec2 p12 = endOffset - startOffset;
        vec2 p13 = p3 - startOffset;

        float d = dot(p12, p13) / length(p12);
        vec2 p4 = startOffset + normalize(p12) * d;
        if (length(p4 - p3) < width
            && length(p4 - startOffset) <= length(p12)
            && length(p4 - endOffset) <= length(p12)) {
            finalColor = vec3(0.0, 1.0, 0.0);
        }

        // These two draw the UI circles
        if (length(p3 - startOffset) < width) {
        finalColor = vec3(1.0, 0.0, 0.0);
        }

        if (length(p3 - endOffset) < width) {
        finalColor = vec3(1.0, 0.0, 0.0);
        }
    }

    // Output type is 'Comp'
    if (outputType == 2)
    {
        finalColor = (finalColor * mattepix) + (frontpix * (1.0 - mattepix));
    }

    gl_FragColor = vec4(finalColor, drawing);
}