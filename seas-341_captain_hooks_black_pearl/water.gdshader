shader_type spatial;
render_mode specular_toon;

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
	NORMAL_MAP = texture(normalmap, tex_position).xyz;
	
	float fresnel = sqrt(1.0 - dot(NORMAL, VIEW));
	RIM = 0.2;
	METALLIC = 0.0;
	ROUGHNESS = 0.01 * (1.0 - fresnel);
	ALBEDO = vec3(0.1, 0.3, 0.5) + (0.1 * fresnel);
}