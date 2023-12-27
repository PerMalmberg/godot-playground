shader_type canvas_item;


void fragment() {
	vec4 c = texture(TEXTURE, UV);
	if(c.r > 0.0 || c.g > 0.0 || c.b > 0.0) {
		COLOR.a = 0.0;
	}
}

//void light() {
	// Called for every pixel for every light affecting the CanvasItem.
	// Uncomment to replace the default light processing function with this one.
//}
