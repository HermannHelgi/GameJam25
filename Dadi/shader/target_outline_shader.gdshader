shader_type spatial;
render_mode cull_front, unshaded, depth_test_disabled;

uniform vec4 outline_color : source_color = vec4(0.5, 0.0, 0.0, 0.6);
uniform float outline_width : hint_range(0.1, 10.0) = 1.0;

void vertex() {
	vec4 clip_position = PROJECTION_MATRIX * (MODELVIEW_MATRIX * vec4(VERTEX, 1.0));
	vec3 clip_normal = mat3(PROJECTION_MATRIX) * (mat3(MODELVIEW_MATRIX) * NORMAL);
	
	vec2 offset = normalize(clip_normal.xy) / VIEWPORT_SIZE * clip_position.w * outline_width * 2.0;
	
	clip_position.xy += offset;
	
	POSITION = clip_position;
}

void fragment() {
	// Make the outline more visible and stand out against PSX effects
	ALBEDO = outline_color.rgb * 2.0; // Brighten to overcome post-processing
	ALPHA = outline_color.a;
	
	// Ensure depth is written correctly
	DEPTH = FRAGCOORD.z;
}