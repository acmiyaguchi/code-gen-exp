
// GLSL shader for a subtle animated background

uniform float time;

vec3 mod289(vec3 x) {
    return x - floor(x * (1.0 / 289.0)) * 289.0;
}

vec2 mod289(vec2 x) {
    return x - floor(x * (1.0 / 289.0)) * 289.0;
}

vec3 permute(vec3 x) {
    return mod289(((x*34.0)+1.0)*x);
}

// Perlin noise function
float snoise(vec2 v) {
    const vec4 C = vec4(0.211324865405187,  // (3.0-sqrt(3.0))/6.0
                      0.366025403784439,  // 0.5*(sqrt(3.0)-1.0)
                     -0.577350269189626,  // -1.0 + 2.0 * C.x
                      0.024390243902439); // 1.0 / 41.0
    
    // First corner
    vec2 i  = floor(v + dot(v, C.yy));
    vec2 x0 = v -   i + dot(i, C.xx);

    // Other corners
    vec2 i1;
    i1 = (x0.x > x0.y) ? vec2(1.0, 0.0) : vec2(0.0, 1.0);
    vec4 x12 = x0.xyxy + C.xxzz;
    x12.xy -= i1;

    // Permutations
    i = mod289(i); // Avoid truncation effects in permutation
    vec3 p = permute(permute(i.y + vec3(0.0, i1.y, 1.0)) + i.x + vec3(0.0, i1.x, 1.0));

    vec3 m = max(0.5 - vec3(dot(x0,x0), dot(x12.xy,x12.xy), dot(x12.zw,x12.zw)), 0.0);
    m = m*m;
    m = m*m;

    // Gradients
    vec3 x = 2.0 * fract(p * C.www) - 1.0;
    vec3 h = abs(x) - 0.5;
    vec3 ox = floor(x + 0.5);
    vec3 a0 = x - ox;

    // Normalise gradients
    m *= 1.79284291400159 - 0.85373472095314 * (a0*a0 + h*h);

    // Compute final noise value at P
    vec3 g;
    g.x  = a0.x  * x0.x  + h.x  * x0.y;
    g.yz = a0.yz * x12.xz + h.yz * x12.yw;
    return 130.0 * dot(m, g);
}

vec4 effect(vec4 color, Image tex, vec2 texture_coords, vec2 screen_coords)
{
    // Normalized pixel coordinates (from 0 to 1)
    vec2 uv = screen_coords / love_ScreenSize.xy;
    
    // Time varying pixel color based on perlin noise
    float speed = 0.03;
    float scale = 3.0;
    
    // Create moving noise patterns
    float n1 = snoise(vec2(uv.x * scale, uv.y * scale - time * speed * 0.5));
    float n2 = snoise(vec2(uv.x * scale * 0.5, uv.y * scale * 0.5 + time * speed * 0.2));
    
    // Mix two noise patterns
    float noise = 0.5 * n1 + 0.5 * n2;
    
    // Create a subtle color gradient effect
    vec3 baseColor1 = vec3(0.05, 0.05, 0.15);  // Dark blue
    vec3 baseColor2 = vec3(0.1, 0.1, 0.2);     // Slightly lighter blue
    
    // Mix the colors based on noise and position
    vec3 finalColor = mix(baseColor1, baseColor2, noise * 0.3 + uv.y * 0.5);
    
    // Add subtle highlights based on a different noise pattern
    float highlight = snoise(vec2(uv.x * scale * 2.0, uv.y * scale * 2.0 + time * speed));
    finalColor += vec3(0.05) * smoothstep(0.7, 0.9, highlight);
    
    // Output final color
    return vec4(finalColor, 1.0);
}
