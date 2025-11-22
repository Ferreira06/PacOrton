@tool

extends Sprite2D

func _Aspect_Ratio():
	material.set_shader_param("aspect_ratio", scale.y / scale.x);
