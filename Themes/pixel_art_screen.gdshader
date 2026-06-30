shader_type canvas_item;

uniform sampler2D screen_texture : hint_screen_texture, filter_nearest;

uniform int pixel_size = 4;
uniform float color_levels = 8.0;
uniform float dither_strength = 0.35;

// New: choose darkest and lightest colors.
uniform vec4 darkest_color : source_color = vec4(0.0, 0.0, 0.0, 1.0);
uniform vec4 lightest_color : source_color = vec4(1.0, 1.0, 1.0, 1.0);

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
	vec2 screen_size = 1.0 / SCREEN_PIXEL_SIZE;

	vec2 screen_pixel = SCREEN_UV * screen_size;

	// Snap screen to pixel blocks.
	vec2 pixelated_pos = floor(screen_pixel / float(pixel_size)) * float(pixel_size);
	pixelated_pos += float(pixel_size) * 0.5;

	vec2 pixelated_uv = pixelated_pos / screen_size;

	vec4 screen_color = texture(screen_texture, pixelated_uv);

	// Ordered dithering.
	float dither = bayer_4x4(screen_pixel);
	dither = (dither - 0.5) * dither_strength;

	vec3 color = screen_color.rgb + vec3(dither / color_levels);

	// Crush each RGB channel separately.
	color = floor(color * color_levels) / color_levels;

	// Normalize crushed color into 0..1 range and remap between darkest/lightest colors.
	color = clamp(color, 0.0, 1.0);
	vec3 remapped = mix(darkest_color.rgb, lightest_color.rgb, color);

	COLOR = vec4(remapped, screen_color.a);
}