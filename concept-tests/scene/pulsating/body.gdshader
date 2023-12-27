shader_type canvas_item;

uniform vec4 color: source_color = vec4(1);

void vertex() {
	// Called for every vertex the material is visible on.
}

void fragment() {
	const vec4 org = texture(TEXTURE, UV);
	
	if(org.a > 0.01) {
		COLOR = vec4(color.rgb, org.a);
	}
	else {
		COLOR = vec4(0);
	}
}

//void light() {
	// Called for every pixel for every light affecting the CanvasItem.
	// Uncomment to replace the default light processing function with this one.
//}
