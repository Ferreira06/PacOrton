shader_type canvas_item;

// Variáveis uniformes para controle fácil no Inspector
uniform float amplitude = 5.0; // Altura máxima da flutuação (em pixels)
uniform float speed = 2.0;     // Velocidade da flutuação

void vertex() {
	vec2 offset;
    
   	VERTEX.x += cos(TIME * speed) + amplitude;
    VERTEX.y += sin(TIME * speed) + amplitude;
}

void fragment() {
    // O fragment shader pode ser simples, apenas pegando a cor padrão.
    COLOR = texture(TEXTURE, UV);
}