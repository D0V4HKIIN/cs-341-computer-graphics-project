shader_type spatial;
render_mode cull_disabled;

uniform sampler2D noise;
uniform vec2 uv_scale = vec2(.1, .2);
uniform vec2 time_scale = vec2(.2, .0);
uniform float distortion = 0.;

uniform sampler2D flag_texture;

void vertex() {
	vec2 flag_uv = UV * uv_scale - TIME * time_scale;
	
	float displacement = texture(noise, flag_uv).r * 2. - 1.; // normalized to [-1, 1]
	displacement *= UV.x;
	VERTEX.y += displacement;
	VERTEX.x -= displacement * distortion;
	VERTEX.z += displacement * distortion;
}

void fragment() {
	ALBEDO = texture(flag_texture, UV).rgb;
}