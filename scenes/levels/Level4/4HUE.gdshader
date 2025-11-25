shader_type canvas_item;

uniform float hue_speed : hint_range(0.0, 5.0, 0.1) = 0.5; // Velocidade da rotação do HUE (Matiz)

// --- Funções HUE/RGB para a rotação de matiz (HSV) ---

// Converte a cor RGB (vermelho, verde, azul) para HSV (matiz, saturação, valor)
vec3 rgb_to_hsv(vec3 color) {
    vec4 K = vec4(0.0, -1.0 / 3.0, 2.0 / 3.0, -1.0);
    vec4 p = mix(vec4(color.bg, K.wz), vec4(color.gb, K.xy), step(color.b, color.g));
    vec4 q = mix(vec4(p.xyw, color.r), vec4(color.r, p.yzx), step(p.x, color.r));

    float d = q.x - min(q.w, q.y);
    float e = 1.0e-10; // Pequena constante para evitar divisão por zero
    
    // Retorna vec3(HUE, SATURATION, VALUE)
    return vec3(abs(q.z + (q.w - q.y) / (6.0 * d + e)), d / (q.x + e), q.x);
}

// Converte a cor HSV de volta para RGB
vec3 hsv_to_rgb(vec3 color) {
    vec4 K = vec4(1.0, 2.0 / 3.0, 1.0 / 3.0, 3.0);
    vec3 p = abs(fract(color.xxx + K.xyz) * 6.0 - K.w);
    
    // Retorna a cor RGB
    return color.z * mix(K.xxx, clamp(p - 1.0, 0.0, 1.0), color.y);
}

void fragment() {
    // 1. Busque a cor da textura (adapte seu código conforme necessário)
    vec4 final_color = texture(TEXTURE, UV); 
    
    // 2. Converta para HSV
    vec3 hsv = rgb_to_hsv(final_color.rgb);
    
    // 3. Altere o HUE (componente 'x') com o tempo
    // O 'TIME' garante a animação contínua e o 'fract()' mantém o HUE no ciclo de 0 a 1.
    hsv.x = fract(hsv.x + TIME * hue_speed * 0.1); 
    
    // 4. Converta de volta para RGB
    final_color.rgb = hsv_to_rgb(hsv);
    
    // 5. Atribua a cor final
    COLOR = final_color;
}