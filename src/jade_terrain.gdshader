shader_type canvas_item;
render_mode unshaded;

uniform float clarity_amount : hint_range(0.0, 0.4) = 0.0;
uniform float pixel_mix : hint_range(0.0, 0.3) = 0.0;
uniform sampler2D relief_delta_texture : filter_linear, repeat_disable;

void fragment() {
	vec4 base = texture(TEXTURE, UV);
	vec2 texel = TEXTURE_PIXEL_SIZE;
	vec3 neighbors = (texture(TEXTURE, UV + vec2(texel.x, 0.0)).rgb
		+ texture(TEXTURE, UV - vec2(texel.x, 0.0)).rgb
		+ texture(TEXTURE, UV + vec2(0.0, texel.y)).rgb
		+ texture(TEXTURE, UV - vec2(0.0, texel.y)).rgb) * 0.25;
	vec3 color = clamp(base.rgb + (base.rgb - neighbors) * (0.18 + clarity_amount), 0.0, 1.0);
	// Offline signed source detail; keep clamp and land masking after interpolation.
	float relief_delta = texture(relief_delta_texture, UV).r;
	float land = smoothstep(0.04, 0.12, base.g - base.b);
	float shade = clamp(relief_delta * 2.5, -0.14, 0.14) * land;
	color += shade * (shade > 0.0 ? vec3(1.0, 0.92, 0.68) : vec3(0.68, 0.8, 0.78));
	// Existing relief contrast only: this is not elevation-based relighting.
	color = clamp((color - vec3(0.5)) * 1.08 + vec3(0.52), 0.0, 1.0);
	// Fixed map-space fine color steps: no screen-space noise, UV snapping or blur.
	vec3 stepped = floor(color * 31.0 + 0.5) / 31.0;
	color = mix(color, stepped, pixel_mix);
	COLOR *= vec4(color, base.a);
}
