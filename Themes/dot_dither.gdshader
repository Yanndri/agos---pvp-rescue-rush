shader_type canvas_item;

uniform sampler2D screen_texture : hint_screen_texture, filter_nearest;

uniform vec4 color_a : source_color = vec4(0.0, 0.0, 0.0, 1.0); // darkest dither color
uniform vec4 color_b : source_color = vec4(1.0, 1.0, 1.0, 1.0); // brightest dither color

uniform float effect_strength : hint_range(0.0, 1.0) = 1.0;
uniform float dither_scale : hint_range(1.0, 16.0) = 2.0;
uniform float original_color_blend : hint_range(0.0, 1.0) = 0.0;

// Only colors darker than this get dithered.
uniform float dither_dark_threshold : hint_range(0.0, 1.0) = 0.45;

// Softness of the transition.
// Lower = sharper cutoff, higher = smoother fade.
uniform float dither_fade_softness : hint_range(0.001, 1.0) = 0.15;

float bayer_4x4(vec2 pixel_pos) {
	int x = int(mod(pixel_pos.x, 4.0));
	int y = int(mod(pixel_pos.y, 4.0));
	int index = x + y * 4;

	float value = 0.0;

	if (index == 0) value = 0.0;
	else if (index == 1) value = 8.0;
	else if (index == 2) value = 2.0;
	else if (index == 3) value = 10.0;
	else if (index == 4) value = 12.0;
	else if (index == 5) value = 4.0;
	else if (index == 6) value = 14.0;
	else if (index == 7) value = 6.0;
	else if (index == 8) value = 3.0;
	else if (index == 9) value = 11.0;
	else if (index == 10) value = 1.0;
	else if (index == 11) value = 9.0;
	else if (index == 12) value = 15.0;
	else if (index == 13) value = 7.0;
	else if (index == 14) value = 13.0;
	else if (index == 15) value = 5.0;

	return value / 16.0;
}

void fragment() {
	vec4 screen_color = texture(screen_texture, SCREEN_UV);

	vec2 screen_size = 1.0 / SCREEN_PIXEL_SIZE;
	vec2 pixel_pos = SCREEN_UV * screen_size;

	pixel_pos = floor(pixel_pos / dither_scale);

	float brightness = dot(screen_color.rgb, vec3(0.299, 0.587, 0.114));
	float threshold = bayer_4x4(pixel_pos);

	vec3 dithered_color = brightness > threshold ? color_b.rgb : color_a.rgb;

	vec3 stylized_color = mix(dithered_color, screen_color.rgb, original_color_blend);

	// Dark mask:
	// brightness lower than threshold = strong dither
	// brightness higher than threshold = no dither
	float dark_mask = 1.0 - smoothstep(
		dither_dark_threshold - dither_fade_softness,
		dither_dark_threshold + dither_fade_softness,
		brightness
	);

	float final_strength = effect_strength * dark_mask;

	vec3 final_color = mix(screen_color.rgb, stylized_color, final_strength);

	COLOR = vec4(final_color, 1.0);
}