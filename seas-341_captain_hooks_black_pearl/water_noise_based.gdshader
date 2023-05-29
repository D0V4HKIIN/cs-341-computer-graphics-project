shader_type spatial;
render_mode specular_toon;

uniform vec2 water_displacement; // to simulate the water without actually moving the boat
uniform float cpu_time; // so that we have the same time in gpu and cpu

// variables that affect the water
uniform float height_scale;
uniform float noise_frequency;
uniform float wave_speed;
uniform float foam_height = 0.5;
uniform float foam_weight = 0.1;
uniform float max_seam_compensation = 500.;

uniform float boat_length;
uniform float boat_width;
uniform float boat_rotation;
uniform float boat_wave_height;
uniform float boat_wave_width;


uniform sampler2D noise;
uniform sampler2D noise2;
uniform sampler2D normalmap;
uniform sampler2D white_water_noise;

uniform vec3 color1 : source_color;
uniform vec3 color2 : source_color;

varying vec2 tex_position;
varying float scaling;

varying float vertex_distance;
varying float vertex_distance_clamped;
varying vec2 vertex_pos;

float wave(vec2 time_pos, vec2 pos){
	// * 2.0 - 1.0 to make it in [-1, 1]
	time_pos += texture(noise, time_pos * noise_frequency).x * 2.0 - 1.0;
	float height_delta = (texture(noise2, pos * noise_frequency).x) * 0.2;
	float wv = 1.0 - abs(sin(time_pos.x + time_pos.y));
	return pow(1.0 - pow(wv, 0.65), 4.0) + height_delta;
}

float height(vec2 position, float time) {
	float d = wave((position + time) * 0.4, position) * 0.3;
	d += wave((position + time * 1.1) * 0.3, position) * 0.3;
	d += wave((position + time * 0.9) * 0.5, position) * 0.2;
	d += wave((position + time) * 0.6, position) * 0.2;
	return d * height_scale;
}

float fresnel(float amount, vec3 normal, vec3 view) {
	return pow((1.0 - clamp(dot(normalize(normal), normalize(view)), 0.0, 1.0)), amount);
}

// square
float sq(float x){
	return x*x;
}

void vertex() {
	vec3 world_pos = (MODEL_MATRIX * vec4(VERTEX, 1.0)).xyz;
	tex_position = world_pos.xz / 2.0 + cpu_time * wave_speed + water_displacement;
	
	vertex_distance = distance(world_pos, vec3(0.0));
	vertex_distance = clamp(vertex_distance, 0.0, max_seam_compensation);
	vertex_distance_clamped = vertex_distance / max_seam_compensation;
	
	scaling = 1.0 - vertex_distance_clamped;
	float R = 3.5;
	float r = boat_wave_width;
	float h = height(tex_position, cpu_time);
	
	//mat2 world_to_boat_space = mat2(vec2(cos(boat_rotation), -sin(boat_rotation)), vec2(sin(boat_rotation), cos(boat_rotation)));
	//vec2 boat_space = world_pos.xz * world_to_boat_space;
	
	//float boat_wave_factor = sqrt(max(-0.2 * (boat_space.x - 3. - boat_length), 0.));
	// add half torus for boat
	//h += boat_wave_factor * boat_wave_height * sqrt(max(sq(r) - sq(sqrt(sq((1./boat_length) * boat_space.x) + sq((1./boat_width) * boat_space.y)) - R), 0.));

	VERTEX.y += h * scaling;

	NORMAL = normalize(vec3(h - height(tex_position + vec2(0.1, 0.0), cpu_time), 0.1, h - height(tex_position + vec2(0.0, 0.1), cpu_time)));
}

void fragment() {
	// noise to make water less plastic like
	vec3 normal_noise = texture(normalmap, tex_position).xyz;
	NORMAL_MAP = normal_noise;
	
	vec3 world_vertex = (INV_VIEW_MATRIX * vec4(VERTEX, 1.0)).xyz;
	
	float fresnel = fresnel(5.0, NORMAL, VIEW);
	vec3 surface_color = mix(color1, color2, fresnel);
	// normal water material
	RIM = 0.2;
	METALLIC = 0.0;
	ROUGHNESS = 0.01 * (1.0 - fresnel);
	
	// white water
	float height_above_white_water = world_vertex.y - height_scale * scaling * foam_height;
	if(height_above_white_water > 0.){
		surface_color += texture(white_water_noise, tex_position).xyz * foam_weight * height_above_white_water * 9.;
		ROUGHNESS = 0.1;
	}
	
	ALBEDO = surface_color;
}
