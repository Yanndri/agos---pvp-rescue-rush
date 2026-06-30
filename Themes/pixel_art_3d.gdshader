shader_type spatial;

render_mode unshaded, depth_test_disabled, depth_draw_never, cull_disabled;

uniform sampler2D screentex : hint_screen_texture, filter_nearest;

uniform int pixelation_level = 2;
uniform float color_levels = 8.0;

void fragment() {
	int pixel = max(pixelation_level * 2, 1);

	vec2 pixel_uv = vec2(
		float(int(FRAGCOORD.x) % pixel),
		float(int(FRAGCOORD.y) % pixel)
	);

	pixel_uv.x = FRAGCOORD.x + floor(float(pixel) / 2.0 - pixel_uv.x);
	pixel_uv.y = FRAGCOORD.y + floor(float(pixel) / 2.0 - pixel_uv.y);

	vec4 screen = texture(screentex, pixel_uv / VIEWPORT_SIZE);

	// Crush each RGB channel separately so colors stay colored.
	vec3 crushed_color = floor(screen.rgb * color_levels) / color_levels;

	ALBEDO = crushed_color;
	ALPHA = 1.0;
}