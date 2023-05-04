shader_type spatial;
render_mode specular_toon;

uniform float height_scale = 2.0;
uniform vec2 water_displacement; // to simulate the water without actually moving the boat
uniform float cpu_time; // so that we have the same time in gpu and cpu

uniform sampler2D noise;
uniform sampler2D normalmap;

varying vec2 tex_position;

varying float vertex_distance;
varying float vertex_distance_clamped;
varying vec2 vertex_pos;

float wave(vec2 position){
	  position += texture(noise, position / 10.0).x * 2.0 - 1.0;
	  vec2 wv = 1.0 - abs(sin(position));
	  return pow(1.0 - pow(wv.x * wv.y, 0.65), 4.0);
}

float height(vec2 position, float time) {
  float d = wave((position + time) * 0.4) * 0.3;
  d += wave((position - time) * 0.3) * 0.3;
  d += wave((position + time) * 0.5) * 0.2;
  d += wave((position - time) * 0.6) * 0.2;
  return d;
}

void vertex() {
	vec3 world_pos = (MODEL_MATRIX * vec4(VERTEX, 1.0)).xyz;
	tex_position = world_pos.xz / 2.0 + cpu_time * 0.05 + water_displacement;
	
	vertex_distance = distance(world_pos, vec3(0.0));
	vertex_distance = clamp(vertex_distance, 0.0, 85.0);
	vertex_distance_clamped = vertex_distance / 85.0;
	
	float h = height(tex_position, cpu_time);
	VERTEX.y += h * height_scale * (1.0 - vertex_distance_clamped);

	NORMAL = normalize(vec3(h - height(tex_position + vec2(0.1, 0.0), cpu_time), 0.1, h - height(tex_position + vec2(0.0, 0.1), cpu_time)));
}

void fragment() {
	// noise to make water less plastic like
	vec3 normal_noise = texture(normalmap, tex_position).xyz;
	NORMAL_MAP = normal_noise;
	
	// normal water material
	float fresnel = sqrt(1.0 - dot(NORMAL, VIEW));
	RIM = 0.2;
	METALLIC = 0.0;
	ROUGHNESS = 0.01 * (1.0 - fresnel);
	ALBEDO = vec3(0.01, 0.03, 0.05) + (0.1 * fresnel);
}