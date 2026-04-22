shader_type spatial;
render_mode blend_mix, cull_disabled, unshaded;

uniform float speed : hint_range(0.0, 1.0) = 1.0;   // 0 = stopped, 1 = max
uniform float blade_count = 4.0;
uniform float opacity = 0.45;
uniform vec4 tint : source_color = vec4(0.08,0.08,0.08,1.0);

void fragment() {
    vec2 p = UV * 2.0 - 1.0;
    float r = length(p);

    if (r > 1.0) discard;

    float ang = atan(p.y, p.x);

    // rotating phase
    float phase = TIME * mix(2.0, 40.0, speed);

    // repeating blade arcs
    float blade_pattern = cos((ang + phase) * blade_count);

    // sharpen into streaks
    float streak = smoothstep(0.55, 1.0, blade_pattern);

    // radial fade
    float radial = smoothstep(1.0, 0.15, r);

    // stronger blur toward outer radius
    float outer = smoothstep(0.15, 0.95, r);

    float alpha = streak * radial * outer * opacity;

    // high speed adds continuous disc blur
    alpha += speed * 0.18 * radial * outer;

    ALBEDO = tint.rgb;
    ALPHA = alpha;
}