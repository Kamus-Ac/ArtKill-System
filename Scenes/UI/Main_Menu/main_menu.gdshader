shader_type canvas_item;

// Intensidad general controlada por el Tween (de 0 a 1)
uniform float glitch_intensity : hint_range(0.0, 1.0) = 0.0;

// Qué tanto se separan los colores (ajusta esto en el inspector si quieres más o menos separación)
uniform float aberration_amount : hint_range(0.0, 0.1) = 0.03; 

// Velocidad a la que parpadean los "cortes" horizontales
uniform float glitch_speed : hint_range(0.0, 50.0) = 15.0;

// Función para generar números pseudo-aleatorios
float random(vec2 uv) {
	return fract(sin(dot(uv.xy, vec2(12.9898,78.233))) * 43758.5453123);
}

void fragment() {
	vec2 uv = UV;
	
	// --- PARTE 1: DESPLAZAMIENTO EN BLOQUES (CORTES ESTILO VHS) ---
	// Dividimos el botón en franjas horizontales (ej. 20 franjas)
	float bands = floor(uv.y * 20.0); 
	
	// Generamos un valor aleatorio para cada franja basado en el tiempo
	float band_shift = random(vec2(bands, TIME * glitch_speed)) * 2.0 - 1.0;
	
	// Hacemos que solo algunas franjas se muevan (cuando el random es muy alto)
	// y multiplicamos por la intensidad para que no se mueva si intensidad es 0
	float block_displacement = step(0.8, abs(band_shift)) * band_shift * 0.1 * glitch_intensity;
	
	// Aplicamos el desplazamiento a la coordenada X
	uv.x += block_displacement;
	
	// --- PARTE 2: ABERRACIÓN CROMÁTICA (SEPARACIÓN RGB) ---
	// La separación crece conforme la intensidad del Tween aumenta
	float split = aberration_amount * glitch_intensity;
	
	// Calculamos las posiciones separadas para el Rojo y el Azul
	vec2 uv_r = uv + vec2(split, 0.0);
	vec2 uv_g = uv; // El Verde se queda en el centro
	vec2 uv_b = uv - vec2(split, 0.0);
	
	// Obtenemos los colores individuales de cada canal en su nueva posición
	float r = texture(TEXTURE, uv_r).r;
	float g = texture(TEXTURE, uv_g).g;
	float b = texture(TEXTURE, uv_b).b;
	
	// Obtenemos el alpha (transparencia) de cada canal desplazado
	float a_r = texture(TEXTURE, uv_r).a;
	float a_g = texture(TEXTURE, uv_g).a;
	float a_b = texture(TEXTURE, uv_b).a;
	
	// Mezclamos la transparencia para que los bordes de color sean visibles
	float final_alpha = max(max(a_r, a_g), a_b);
	
	// Evitamos dibujar píxeles completamente invisibles
	if (final_alpha == 0.0) discard;
	
	// Construimos el color final
	COLOR = vec4(r, g, b, final_alpha);
}