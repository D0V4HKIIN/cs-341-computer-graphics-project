shader_type spatial;

const float g = 9.8;
//const float PI = 3.14159265358979323846;
varying float L_x;
varying float L_y;

const float M = 10.;
const float N = 10.;

uniform float cpu_time;
uniform float A = 1.0; // "A is a numeric constant"
uniform vec2 w = vec2(1.0); // wind

varying float vertex_distance;
varying float vertex_distance_clamped;
varying vec2 vertex_pos;

// random number generator
float rand(vec2 co){
	return fract(sin(dot(co.xy ,vec2(12.9898,78.233))) * 43758.5453);
}

// if need to work with complex numbers, since we cannot,
// define the methods according to complex numbers

vec2 ComplexMult(vec2 x, vec2 y) {
    return vec2(x[0] * y[0] - x[1] * y[1], x[1] * y[0] + x[0] * y[1]);
}
 
vec2 iMult(vec2 z) {
    return vec2(-z[1], z[0]);
}

vec2 euler(float value){
	return vec2 (cos(value), sin(value));
}

// assume it's correct idk
float dispersion(float n_prime, float m_prime){
	float w_0 = 2.0 * PI / 200.0;
	float kx = PI * (2.* n_prime - N) / L_x;
	float kz = PI * (2.* m_prime - N) / L_y;
	return floor(sqrt(g* sqrt(kx * kx + kz * kz)) / w_0) * w_0;
}

float phillips(float n_prime, float m_prime){
	float L = length(w) * length(w) / g;
	
	float kx = PI * (2. * n_prime - N) / L_x;
	float kz = PI * (2. * m_prime - M) / L_y;
	float k = length(vec2(kx, kz));
	
	float dot_prod = dot(normalize(vec2(kx, kz)), normalize(w));
	
	float damping = 0.001;
	float l2 = L * L * damping * damping;
	
	// euler (-k * k * l2) is some dampening part as in the original paper
	return A * exp(-1.0 / pow((k * L), 2)) * dot_prod * dot_prod * exp(-k * k * l2) / pow(n_prime, 4);
}


vec2 h_0_bar(float n_prime, float m_prime, vec2 pos){
	float xi_r = rand(pos);
	float xi_i = rand(pos);

	return vec2(xi_r, xi_i) * sqrt(phillips(n_prime,  m_prime) / sqrt(2));
}


vec2 height_tilde(float n_prime, float m_prime, float time, vec2 pos){
	return h_0_bar(n_prime, m_prime, pos) * euler(dispersion(n_prime, m_prime) * time) + h_0_bar(n_prime, m_prime, pos) * euler(-dispersion(n_prime, m_prime) * time);
}

vec2 height(vec2 pos, float time) {
	vec2 wave_height = vec2(0.0);
	for (float m_prime = 0.; m_prime <=  M-1.; m_prime++){
		for (float n_prime =0. ; n_prime <= N-1.; n_prime++){
			float kx = PI * (2. * n_prime - N) / L_x;
			float kz = PI * (2. * m_prime - M) / L_y;
			wave_height += height_tilde(n_prime, m_prime, time, pos) * euler(pos.x * kx + pos.y *kz);
		}
	}
	return wave_height;
}

//void displacement 

//void normal

void vertex() {
	vec3 world_pos = (MODEL_MATRIX * vec4(VERTEX, 1.0)).xyz;
	VERTEX.y = height(world_pos.xz, cpu_time).x / 10000000000000000000.0;
}


void fragment(){
	// normal water material
	float fresnel = sqrt(1.0 - dot(NORMAL, VIEW));
	RIM = 0.2;
	METALLIC = 0.0;
	ROUGHNESS = 0.01 * (1.0 - fresnel);
	ALBEDO = vec3(0.01, 0.03, 0.05) + (0.1 * fresnel);
}