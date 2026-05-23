shader_type canvas_item;

void fragment() {
	vec2 center = UV- vec2(0.5);
	
	float dist = length(center);
	
	if(dist>0.5){
		discard;
	}
	
	COLOR = texture(TEXTURE, UV);
}

//void light() {
//	// Called for every pixel for every light affecting the CanvasItem.
//	// Uncomment to replace the default light processing function with this one.
//}
