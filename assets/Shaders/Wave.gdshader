shader_type canvas_item;

uniform vec2 tile_fac = vec2 (5.0, 5.0);
uniform float aspect_ratio = 0.5;
uniform vec2 offset_scale = vec2(2.0, 2.0);

void fragment() {
	vec2 tile_uv = UV * tile_fac;
	tile_uv.y *= aspect_ratio;
	
	vec2 wave_uv_offset;
	wave_uv_offset.x = cos(TIME) * offset_scale.x;
	wave_uv_offset.y = sin(TIME) * offset_scale.y; 
	
	COLOR = texture(TEXTURE, tile_uv + wave_uv_offset * 0.1);
}

