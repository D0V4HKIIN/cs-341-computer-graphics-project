shader_type spatial;
render_mode specular_toon;

uniform vec2 water_displacement; // to simulate the water without actually moving the boat
uniform float cpu_time; // so that we have the same time in gpu and cpu

// variables that affect the water
uniform float height_scale;
uniform float noise_frequency;
uniform float wave_speed;

uniform sampler2D noise;
uniform sampler2D normalmap;

uniform vec3 color1 : source_color;
uniform vec3 color2 : source_color;

varying vec2 tex_position;

varying float vertex_distance;
varying float vertex_distance_clamped;
varying vec2 vertex_pos;

float wave(vec2 position){
	// * 2.0 - 1.0 to make it in [-1, 1]
	position += texture(noise, position * noise_frequency).x * 2.0 - 1.0;
	vec2 wv = 1.0 - abs(sin(position));
	return pow(1.0 - pow(wv.x * wv.y, 0.65), 4.0);
}

float height(vec2 position, float time) {
	float d = wave((position + time) * 0.4) * 0.3;
	d += wave((position - time) * 0.3) * 0.3;
	d += wave((position + time) * 0.5) * 0.2;
	d += wave((position - time) * 0.6) * 0.2;
	return d * height_scale;
}

float fresnel(float amount, vec3 normal, vec3 view) {
	return pow((1.0 - clamp(dot(normalize(normal), normalize(view)), 0.0, 1.0)), amount);
}

void vertex() {
	vec3 world_pos = (MODEL_MATRIX * vec4(VERTEX, 1.0)).xyz;
	tex_position = world_pos.xz / 2.0 + cpu_time * wave_speed + water_displacement;
	
	vertex_distance = distance(world_pos, vec3(0.0));
	vertex_distance = clamp(vertex_distance, 0.0, 85.0);
	vertex_distance_clamped = vertex_distance / 85.0;
	
	float h = height(tex_position, cpu_time);
	VERTEX.y += h * (1.0 - vertex_distance_clamped);

	NORMAL = normalize(vec3(h - height(tex_position + vec2(0.1, 0.0), cpu_time), 0.1, h - height(tex_position + vec2(0.0, 0.1), cpu_time)));
}

void fragment() {
	// noise to make water less plastic like
	vec3 normal_noise = texture(normalmap, tex_position).xyz;
	NORMAL_MAP = normal_noise;
	
	// normal water material
	//float fresnel = sqrt(1.0 - dot(NORMAL, VIEW));
	float fresnel = fresnel(5.0, NORMAL, VIEW);
	vec3 surface_color = mix(color1, color2, fresnel);
	RIM = 0.2;
	METALLIC = 0.0;
	ROUGHNESS = 0.01 * (1.0 - fresnel);
	ALBEDO = surface_color;
}
