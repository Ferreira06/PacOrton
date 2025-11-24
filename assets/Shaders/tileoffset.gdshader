shader_type canvas_item;
#include "res://addons/shaderV/uv/animated/distortionUVAnimated.gdshaderinc"

uniform float Speed : hint_range(0.0, 1.0, 0.1) = 0.0;
uniform float scale : hint_range(0.0, 1.0, 0.01) = 0.0;

uniform float distancia_x : hint_range(0.0, 1.0, 0.1);
uniform float distancia_y : hint_range(0.0, 1.0, 0.1);
uniform float onda_x : hint_range(0.0, 1.0, 0.1);
uniform float onda_y : hint_range(0.0, 1.0, 0.1);
uniform float velocity : hint_range(0.0, 1.0, 0.1);

uniform vec2 offset_scale = vec2(2.0, 2.0);

void vertex(){
	UV.x += TIME * Speed;
	UV.y += TIME * Speed;


}

void fragment() {
	vec2 base_uv = UV;

	float dist_x = distancia_x;
	float dist_y = distancia_y;
	float wave_x = onda_x;
	float wave_y = onda_y;
	float speed = velocity;

	float wave_uv_offset;
	wave_uv_offset = cos(TIME) * offset_scale.x;

	vec2 distorted_uv = _distortionUVAnimatedFunc(
		base_uv,
		dist_x,
		dist_y,
		wave_x,
		wave_y,
		speed,
		TIME
	);

	vec4 color = texture(TEXTURE, distorted_uv);

	COLOR = color;
}