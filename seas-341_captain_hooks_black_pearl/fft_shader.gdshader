shader_type spatial;


const vec2 wind_direction = vec2(1,2);
const float wind_speed = 1.;


const float g = 9.8;
//const float PI = 3.14159265358979323846;
varying float L_x;
varying float L_y;

const float M = 200.;
const float N = 200.;

varying float wave_height ;

varying float vertex_distance;
varying float vertex_distance_clamped;
varying vec2 vertex_pos;

// get random number somehow
uniform float random_number_xi;

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


float dispersion(float n_prime, float m_prime){
	float w_0 = 2.0 * PI / 200.0;
	float kx = PI * (2.* n_prime - N) / L_x;
	float kz = PI * (2.* m_prime - N) / L_y;
	return floor(sqrt(g* sqrt(kx * kx + kz * kz)) / w_0) * w_0;
	}

float phillips(float n_prime, float m_prime){
	return 0.;
}


vec2 h_0_bar(float n_prime, float m_prime){
	float xi_r = random_number_xi;
	float xi_i = random_number_xi;

	return vec2(xi_r, xi_i) * sqrt(phillips( n_prime,  m_prime) / sqrt(2));
}


vec2 height_bar(float n_prime, float m_prime, float time){
	return h_0_bar(n_prime, m_prime) * euler(dispersion(n_prime, m_prime) * time) + h_0_bar(-n_prime, -m_prime) * euler(-dispersion(n_prime, m_prime) * time);
}

vec2 height(vec2 x_pos, vec2 z_pos, float time) {
	for (float m_prime = 0.; m_prime <=  M-1.; m_prime++){
		for (float n_prime =0. ; n_prime <= N-1.; n_prime++){
			float kx = PI * (2. * n_prime - N) / L_x;
			float kz = PI * (2. * m_prime - M) / L_y;
			wave_height = height_bar(n_prime, m_prime, time) * euler(x_pos * kx + z_pos *kz);
		}
	}
	return wave_height;
}




complex h_tilda_f(float time, int n_prime, int m_prime) {
	return 
}
//void displacement 

//void normal

void vertex() {
	VERTEX.y = 
}

void fragment() {
	// Place fragment code here.
}
