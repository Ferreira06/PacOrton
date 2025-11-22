shader_type canvas_item;

uniform float Speed : hint_range(0.0, 1.0, 0.1) = 0.0;

void vertex(){
	UV.x += TIME * Speed;
	UV.y += TIME * Speed;
}

void fragment() {
}

