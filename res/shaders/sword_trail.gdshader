shader_type spatial;
render_mode unshaded, cull_disabled, blend_add;

uniform sampler2D noise_tex;
uniform sampler2D width_gradient;
uniform sampler2D length_gradient;

uniform sampler2D highlight : source_color,hint_default_transparent;
uniform sampler2D color_lookup : source_color,hint_default_white;

uniform float mix_strength : hint_range(0.0, 2.0, 0.01) = 1.0; 
uniform float rotate_all : hint_range(0.0, 360.0, 0.1) = 0.0; // Rotates the final image by x degrees
uniform float zoom : hint_range(0.0, 2.0, 0.01) = 0.6; // Scales the final image, Inverted (smaller means bigger)

uniform float progress: hint_range(0., 1.) = 0.0;
uniform float glow = 2.0;
uniform float scroll_speed = 0.5;
uniform float anim_rot_amt = 1;

vec2 polar_coordinates(vec2 uv, vec2 center, float zoomm, float repeat) {
	vec2 dir = uv - center;
	float radius = length(dir) * 2.0;
	float angle = atan(dir.y, dir.x) * 1.0/(3.1416 * 2.0);
	return mod(vec2(radius * zoomm, angle * repeat), 1.0);
}

vec2 rotate(vec2 uv, vec2 pivot, float angle) {
	mat2 rotation = mat2(vec2(sin(angle), -cos(angle)),
						vec2(cos(angle), sin(angle)));
	uv -= pivot;
	uv = uv * rotation;
	uv += pivot;
	return uv;
}

float easeInOut(float x) {
	float result;
	if (x < 0.5) {result = (1.0 - sqrt(1.0 - pow(2.0 * x, 2.0))) / 2.0;}
	else {result =(sqrt(1.0 - pow(-2.0 * x + 2.0, 2.0)) + 1.0) / 2.0;}
	return result;
}

void fragment() {
	//float p = progress * 0.75;
	vec2 aUV = polar_coordinates(
		rotate(UV,vec2(0.5),radians(rotate_all)),
		vec2(0.5),
		zoom,
		1.0
	);
	aUV = aUV + vec2(0.0, TIME * 0.5);
	
	vec4 b = texture(noise_tex, aUV);
	vec4 wm = texture(width_gradient, aUV);
	vec4 lm = texture(
		length_gradient, 
		rotate(
			aUV,
			vec2(0.5),
			radians(180.0)
		)
	);
	
	// Combine Them
	vec4 prefinal = (b - wm) - lm;
	vec3 albe = vec3(1.0)*(texture(color_lookup,vec2(clamp(prefinal.r * UV.x,0.0,1.0),0.0)).rgb*mix_strength);
	vec4 high = clamp(texture(highlight,aUV) - (lm),0.0,1.0);
	
	// Apply Them
	ALBEDO = clamp(albe + high.rgb,0.0,1.0);
	EMISSION = clamp(albe + high.rgb,0.0,1.0) * (3.0 * glow);
	
	float alpha_mask = (1.0 - wm.r) * (1.0 - lm.r);
	ALPHA = alpha_mask;
}