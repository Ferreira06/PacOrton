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

// NOVO UNIFORM para controlar o Hue Shift
uniform float hue_shift : hint_range(-1.0, 1.0, 0.01) = 0.0;

// Funções de conversão (melhor fora do fragment())
vec3 rgb_to_hsv(vec3 color) {
    vec4 K = vec4(0.0, -1.0 / 3.0, 2.0 / 3.0, -1.0);
    vec4 P = mix(vec4(color.bg, K.wz), vec4(color.gb, K.xy), step(color.b, color.g));
    vec4 Q = mix(vec4(P.xyw, color.r), vec4(color.r, P.yzx), step(P.x, color.r));

    float D = Q.x - min(Q.w, Q.y);
    // Mude 'E' para 'epsilon'
    float epsilon = 1.0e-10;

    // Use 'epsilon' no lugar de 'E'
    return vec3(abs(Q.z + (Q.w - Q.y) / (6.0 * D + epsilon)), D / (Q.x + epsilon), Q.x);
}

vec3 hsv_to_rgb(vec3 color) {
    vec4 K = vec4(1.0, 2.0 / 3.0, 1.0 / 3.0, 3.0);
    vec3 P = abs(fract(color.xxx + K.xyz) * 6.0 - K.w);
    return color.z * mix(K.xxx, clamp(P - 1.0, 0.0, 1.0), color.y);
}


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

	vec3 hsv_color = rgb_to_hsv(color.rgb);

	float auto_hue_shift = TIME * 0.1;
	hsv_color.r = fract(hsv_color.r + auto_hue_shift);

	color.rgb = hsv_to_rgb(hsv_color);

	COLOR = color;
}