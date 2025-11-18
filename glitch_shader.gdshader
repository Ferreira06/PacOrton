shader_type canvas_item;

// Controla a velocidade da animação do glitch
uniform float time_speed : hint_range(0.0, 10.0, 0.1) = 3.0; 
// Intensidade de quão longe a imagem 'pula'
uniform float glitch_intensity : hint_range(0.0, 1.0, 0.01) = 0.05; 
// Fator de pixelização
uniform float pixelate_factor : hint_range(0.0, 50.0, 1.0) = 20.0; 
// Intensidade das linhas horizontais (scanlines)
uniform float scanline_intensity : hint_range(0.0, 1.0, 0.01) = 0.3; 
// Escala da distorção (vec2 não pode ter hint_range)
uniform vec2 distortion_scale = vec2(0.02, 0.01); 

void fragment() {
    vec2 base_uv = UV;
    vec4 final_color;

    // --- Efeito de Pixelização ---
    if (pixelate_factor > 0.0) {
        base_uv = floor(base_uv * pixelate_factor) / pixelate_factor;
    }

    // --- Efeito de Distorção e Glitch ---
    float time = TIME * time_speed;
    float distort_x = sin(base_uv.y * 30.0 + time * 7.0) * glitch_intensity * distortion_scale.x;
    float distort_y = cos(base_uv.x * 15.0 + time * 4.0) * glitch_intensity * distortion_scale.y;

    base_uv.x += distort_x;
    base_uv.y += distort_y;

    final_color = texture(TEXTURE, base_uv);

    // --- Efeito de Scanlines ---
    float scanline = sin(base_uv.y * 300.0) * 0.5 + 0.5; 
    scanline = mix(1.0, scanline, scanline_intensity);
    final_color.rgb *= scanline;

    COLOR = final_color;
}