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


vec2 euler(float value){
	return vec2 (cos(value), sin(value));
}

var rng = RandomNumberGenerator.new()

float phillips(n_prime, n_prime){
	
}


vec2 h_0_bar(int n_prime, int m_prime){
	float xi_r = gaussianRandomVariable()
	return vec2(xi_r, xi_i) * sqrt(phillips(int n_prime, m_prime) / sqrt(2));
}


vec2 height_bar(int n_prime, int m_prime, float time){
	return h_0_bar(n_prime, m_prime) * euler(dispersion(n_prime, m_prime) * time) + h_0_bar(-n_prime, -m_prime) * euler(-dispersion(n_prime, m_prime) * time);
}

vec2 height(vec2 x_pos, vec2 z_pos, float time) {
	for (float m_prime = 0.; m_prime <=  M-1.; m_prime++){
		for (float n_prime =0. ; n_prime <= N-1.; n_prime++){
			float kx = PI * (2. * n_prime - N) / L_x;
			float kz = PI * (2. * m_prime - M) / L_y;
			wave_height = height_bar(n_prime, m_prime, float time) * euler(x_pos * kx + z_pos *kz);
		}
	}
	return wave_height;
}



float dispersion(int n_prime, int m_prime){
	float w_0 = 2.0 * M_PI / 200.0;
	float kx = PI * (2* n_prime - N) / L_x;
	float kz = PI * (2* m_prime - N) / L_y;
	return floor(sqrt(g* sqrt(kx * kx + kz * kz)) / w_0) * w_0;
	}

complex h_tilda_f(float time, int n_prime, int m_prime) {
	return 
}



void displacement 

void normal








void fragment() {
	// Place fragment code here.
}
