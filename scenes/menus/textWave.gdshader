shader_type canvas_item;

uniform float frequency : hint_range(0.1, 10.0, 0.1) = 4.0;
uniform float amplitude : hint_range(0.0, 50.0, 1.0) = 15.0;
uniform float speed : hint_range(0.1, 5.0, 0.1) = 2.0;

void vertex() {

	float normalized_y = VERTEX.y;

	float wave_value = sin(normalized_y * frequency * 2.0 * PI + TIME * speed);

	VERTEX.x += wave_value * amplitude;

}