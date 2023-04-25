shader_type spatial;
render_mode specular_toon;

uniform float normal_mix = 0.1;
uniform float height_scale = 0.5;

uniform sampler2D noise;
uniform sampler2D normalmap;

varying vec2 tex_position;

float wave(vec2 pos){
	pos += texture(noise, pos).x * 2.0 - 1.0;
	vec2 wv = 1.0 - abs(sin(pos));
	return pow(1.0 - pow(wv.x * wv.y, 0.65), 4.0);
}

float height(vec2 pos, float time){
	vec2 offset = 0.01 * (pos + time);
	float d = wave(pos * 0.4) * 0.6;
	d += wave((pos - offset) * 0.3) * 0.6;
	d += wave((pos + offset) * 0.5) * 0.4;
	d += wave((pos - offset) * 0.6) * 0.4;
	return d - 1.0;
}

void vertex() {
	tex_position = VERTEX.xz / 2.0 + TIME * 0.05;
	float height = height(tex_position, TIME);
	VERTEX.y += height * height_scale;
}

void fragment() {
	vec3 normal_noise = texture(normalmap, tex_position).xyz;
	NORMAL_MAP = normal_noise;
	// mix noise and some random normalmap for nice sun reflections
	// vec3 real_normal = texture(noise, tex_position).xyz;
	// NORMAL_MAP = mix(normal_noise, real_normal, normal_mix);
	// NORMAL_MAP = normalize(real_normal + normal_noise); // should be more realistic but looks worse
	
	// normal water material
	float fresnel = sqrt(1.0 - dot(NORMAL, VIEW));
	RIM = 0.2;
	METALLIC = 0.0;
	ROUGHNESS = 0.01 * (1.0 - fresnel);
	ALBEDO = vec3(0.1, 0.3, 0.5) + (0.1 * fresnel);
}