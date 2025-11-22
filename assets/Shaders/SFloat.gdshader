shader_type canvas_item;

// Variáveis uniformes para controle fácil no Inspector
uniform float amplitude = 5.0; // Altura máxima da flutuação (em pixels)
uniform float speed = 2.0;     // Velocidade da flutuação

void vertex() {
    // 1. Aplica o seno ao tempo para obter um valor que oscila entre -1 e 1
    float offset = sin(TIME * speed) + amplitude;
    
   	VERTEX.x += offset;
    VERTEX.y += offset;
}

void fragment() {
    // O fragment shader pode ser simples, apenas pegando a cor padrão.
    COLOR = texture(TEXTURE, UV);
}