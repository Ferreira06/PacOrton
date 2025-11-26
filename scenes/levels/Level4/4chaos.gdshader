shader_type canvas_item;

#include "res://addons/shaderV/uv/animated/swirlUV.gdshaderinc"

uniform float time_speed : hint_range(0.0, 10.0, 0.1) = 3.0; // Controla a velocidade da animação do glitch
uniform float glitch_intensity : hint_range(0.0, 1.0, 0.01) = 0.05; // Intensidade de quão longe a imagem 'pula'
uniform float pixelate_factor : hint_range(0.0, 200.0, 1.0) = 20.0; // Fator de pixelização
uniform float scanline_intensity : hint_range(0.0, 1.0, 0.01) = 0.3; // Intensidade das linhas horizontais (scanlines)
uniform vec2 distortion_scale = vec2(0.02, 0.01); // Escala da distorção

// --- Uniforms Adicionais para Swirl ---
uniform float swirl_amount : hint_range(0.0, 5.0, 0.01) = 1.0; // Intensidade do efeito Swirl
uniform vec2 swirl_pivot = vec2(0.5, 0.5); // Ponto central do Swirl (0.5, 0.5 é o centro)

uniform float hue_speed : hint_range(0.0, 5.0, 0.1) = 0.5; // Velocidade da rotação do HUE

// Funções HUE/RGB para a rotação de matiz
// Baseado em: https://www.shadertoy.com/view/lsSyzK

vec3 rgb_to_hsv(vec3 color) {
	vec4 K = vec4(0.0, -1.0 / 3.0, 2.0 / 3.0, -1.0);
	vec4 p = mix(vec4(color.bg, K.wz), vec4(color.gb, K.xy), step(color.b, color.g));
	vec4 q = mix(vec4(p.xyw, color.r), vec4(color.r, p.yzx), step(p.x, color.r));

	float d = q.x - min(q.w, q.y);
	float e = 1.0e-10;
	return vec3(abs(q.z + (q.w - q.y) / (6.0 * d + e)), d / (q.x + e), q.x);
}

vec3 hsv_to_rgb(vec3 color) {
	vec4 K = vec4(1.0, 2.0 / 3.0, 1.0 / 3.0, 3.0);
	vec3 p = abs(fract(color.xxx + K.xyz) * 6.0 - K.w);
	return color.z * mix(K.xxx, clamp(p - 1.0, 0.0, 1.0), color.y);
}

// --- Uniform Adicional para Aberração Cromática ---
uniform float rgb_shift_amount : hint_range(0.0, 0.05, 0.001) = 0.005; // Deslocamento R/B


void fragment() {
	vec2 base_uv = UV;
	float time = TIME * time_speed;
	
	if (pixelate_factor > 0.0) {
		base_uv = floor(base_uv * pixelate_factor) / pixelate_factor;
	}
	float distort_x = sin(base_uv.y * 30.0 + time * 7.0) * glitch_intensity * distortion_scale.x;
	float distort_y = cos(base_uv.x * 15.0 + time * 4.0) * glitch_intensity * distortion_scale.y;
	base_uv.x += distort_x;
	base_uv.y += distort_y;
	
	vec2 rgb_shift = vec2(0.005, 0.0); 

	vec2 uv_r = base_uv - rgb_shift;
	float r = texture(TEXTURE, uv_r).r;
	vec2 uv_g = base_uv;
	float g = texture(TEXTURE, uv_g).g;
	vec2 uv_b = base_uv + rgb_shift;
	float b = texture(TEXTURE, uv_b).b;
	vec4 final_color = vec4(r, g, b, texture(TEXTURE, uv_g).a);
	vec3 hsv = rgb_to_hsv(final_color.rgb);
	
	hsv.x = fract(hsv.x + TIME * hue_speed * 0.1);
	final_color.rgb = hsv_to_rgb(hsv);
	float scanline = sin(base_uv.y * 300.0) * 0.5 + 0.5;
	scanline = mix(1.0, scanline, scanline_intensity);
	final_color.rgb *= scanline;

	COLOR = final_color;
}