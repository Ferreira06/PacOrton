shader_type canvas_item;

#include "res://addons/shaderV/uv/animated/swirlUV.gdshaderinc"

uniform float time_speed : hint_range(0.0, 10.0, 0.1) = 3.0; // Controla a velocidade da animação do glitch
uniform float glitch_intensity : hint_range(0.0, 1.0, 0.01) = 0.05; // Intensidade de quão longe a imagem 'pula'
uniform float pixelate_factor : hint_range(0.0, 200.0, 1.0) = 20.0; // Fator de pixelização
uniform float scanline_intensity : hint_range(0.0, 1.0, 0.01) = 0.3; // Intensidade das linhas horizontais (scanlines)
uniform vec2 distortion_scale = vec2(0.02, 0.01); // Escala da distorção

uniform vec4 ALFA = vec4(1.0, 1.0, 1.0, 1.0);

uniform float pivot : hint_range(0.0, 1.0, 0.1);

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

void vertex() {
    // Calculo o deslocamento com base no tempo e nos pivôs (poderia ser qualquer outra lógica de onda)
    vec2 wave_offset;
    wave_offset.x = cos((TIME) * distortion_scale.x + distortion_scale.y) * pivot; // Multiplico por um valor alto para tornar visível
    wave_offset.y = sin((TIME) * distortion_scale.y / distortion_scale.x) * pivot; // Uso distortion_scale do seu uniform

    // Aplico o deslocamento às coordenadas UV
    UV += wave_offset; // Esta é a linha crucial.
}

void fragment() {
    // A coordenada UV já está modificada pela função vertex()
    vec2 base_uv = UV; 
    float time = TIME * time_speed;
    
    // 1. Pixelização
    if (pixelate_factor > 0.0) {
        base_uv = floor(base_uv * pixelate_factor) / pixelate_factor;
    }
    
    // 2. Distorção Glitch
    float distort_x = sin(base_uv.y * 30.0 + time * 7.0) * glitch_intensity * distortion_scale.x;
    float distort_y = cos(base_uv.x * 15.0 + time * 4.0) * glitch_intensity * distortion_scale.y;
    base_uv.x += distort_x;
    base_uv.y += distort_y;
    
    // 3. Aberração Cromática
    vec2 shift_amount = vec2(rgb_shift_amount, 0.0); // Usando o uniform
    
    // Amostragem R, G e B deslocadas
    float r = texture(TEXTURE, base_uv - shift_amount).r;
    float g = texture(TEXTURE, base_uv).g;
    float b = texture(TEXTURE, base_uv + shift_amount).b;
    
    // Usamos a amostra G para o alfa, assumindo que as cores R, G e B têm o mesmo alfa original
    vec4 final_color = vec4(r, g, b, texture(TEXTURE, base_uv).a);
    
    // 4. Rotação de HUE
    vec3 hsv = rgb_to_hsv(final_color.rgb);
    hsv.x = fract(hsv.x + TIME * hue_speed * 0.1);
    final_color.rgb = hsv_to_rgb(hsv);
    
    // 5. Scanlines
    float scanline = sin(base_uv.y * 300.0) * 0.5 + 0.5;
    scanline = mix(1.0, scanline, scanline_intensity);
    final_color.rgb *= scanline;
    
    // 6. Aplicação da Cor Final e ALFA Global
    // Atribui o resultado final processado
    final_color *= ALFA; // Aplica a cor/transparência global
    
    COLOR = final_color; // Aqui está a correção principal!
}