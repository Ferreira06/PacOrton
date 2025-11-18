shader_type canvas_item;

// A cor de tintura que você define no Inspector
uniform vec4 tint_color : source_color = vec4(1.0);

void fragment() {
    // 1. Pega a cor original do seu tile (o azul escuro)
    vec4 original_color = texture(TEXTURE, UV);

    // 2. Calcula a Luminosidade (Brightness) da cor original.
    // Isso nos diz se o pixel é uma parede escura, um caminho claro, etc.
    // O vec3(0.2126, 0.7152, 0.0722) são pesos padrão para RGB (luminância).
    float brightness = dot(original_color.rgb, vec3(0.2126, 0.7152, 0.0722));

    // 3. Usa a Cor de Tintura e Modifica sua Luminosidade.
    // O resultado é a cor de tintura (vermelho) com a mesma intensidade do tile original.
    vec3 new_color_rgb = tint_color.rgb * brightness;

    // 4. Conecta o novo RGB e mantém o canal Alpha (transparência) original.
    COLOR = vec4(new_color_rgb, original_color.a);
}