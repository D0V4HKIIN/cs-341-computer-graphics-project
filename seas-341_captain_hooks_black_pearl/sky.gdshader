shader_type sky;

render_mode use_half_res_pass;

uniform vec4 skyColor: source_color;
uniform vec4 cloudColor: source_color;
uniform bool addClouds = true;

uniform float speed : hint_range(0.0, 0.25, 0.001) = 0.002;
uniform float cloudLight : hint_range(0.0, 1.0, 0.01) = 0.3;
uniform float cloudCover : hint_range(0.0, 1.0, 0.01) = 0.4;
uniform float cloudWeight : hint_range(0.0, 10.0, 0.01) = 8.0;
uniform float skyWeight : hint_range(0.0, 1.0, 0.001) = 0.5;

// Height based on current pixel
uniform float height_offset : hint_range(0.0, 1.0, 0.001) = 0.2;

// This matrix is scale both x and z axis by 2 and rotate 60 degrees
const mat2 m = mat2(vec2(0, 2), vec2(-2, 0));

// hash, noise are taken from this aritcle: https://greentec.github.io/shadertoy-fire-shader-en/#fbm
// The hash and noise function implements the simplex noise which should produce similar
// results as perlin noise but less computation intensive
vec2 hash( vec2 p ) {
	p = vec2(dot(p, vec2(127.1, 311.7)), dot(p, vec2(269.5, 183.3)));
	return -1.0 + 2.0 * fract(sin(p) * 43758.5453123);
}

float noise( in vec2 p ) {
	const float K1 = 0.366025404; // (sqrt(3)-1)/2;
	const float K2 = 0.211324865; // (3-sqrt(3))/6;
	vec2 i = floor(p + (p.x + p.y)*K1);
	vec2 a = p - i + (i.x + i.y) * K2;
	vec2 o = (a.x > a.y) ? vec2(1.0, 0.0) : vec2(0.0, 1.0);
	vec2 b = a - o + K2;
	vec2 c = a - 1.0 + 2.0 * K2;
	vec3 h = max(0.5 - vec3(dot(a, a), dot(b, b), dot(c, c)), 0.0 );
	vec3 n = h * h * h * h * vec3(dot(a, hash(i + 0.0)), dot(b, hash(i + o)), dot(c, hash(i + 1.0)));
	return dot(n, vec3(70.0));
}

// fbm is inspired by this documentation: https://thebookofshaders.com/13/
float fbm(vec2 st) {
	float value = 0.0;
	float amplitude = 0.2;
	for (int i = 0; i < 6; i++) {
		value += amplitude * noise(st);
		st = m * st;
		amplitude *= 0.4;
	}
	return value;
}

void sky() {
	COLOR = skyColor.rgb;
	if (AT_CUBEMAP_PASS) {
		COLOR = skyColor.rgb;
	} else if (addClouds) {
		vec3 normal = normalize(EYEDIR);
		vec3 intersect = normal / (normal.y + height_offset);
		
		vec2 p = intersect.xz;
		vec2 uv = p;
		
		float time = TIME * speed;
		float q = fbm(uv * 0.5);
		
		// the usage of abs, which is turbulance comes from: https://thebookofshaders.com/13/
		// turbulence noise shape
		float turbShape = 0.0;
		uv = p;
		float weight = 0.8;
		for(int i = 0; i < 8; i++){
			turbShape += abs(weight * noise(uv));
			uv += m * uv + time + q;
			weight *= 0.5;
		}
		
		// turbulence noise colour
		float turbColor = 0.0;
		time = TIME * speed * 3.0;
		uv = p;
		weight = 0.4;
		for (int i = 0; i < 8; i++){
			turbColor += abs(weight * noise(uv));
			uv += m * uv + time + q;			
			weight *= 0.5;
		}
		
		// cloud main shape
		float cloudShape = 0.0;
		uv = p;
		weight = 0.7;
		for(int i = 0; i < 8; i++){
			cloudShape += weight * noise(uv);
			uv += m * uv + time + q;
			weight *= 0.5;
		}
		
		// cloud main colour
		float color = 0.0;
		time = TIME * speed * 2.0;
		uv = p;
		weight = 0.4;
		for(int i = 0; i < 8; i++){
			color += weight * noise(uv);
			uv += m * uv + time + q;
			weight *= 0.5;
		}
	
		cloudShape += turbShape;
		color += turbColor;
		
		vec3 skycolour = COLOR;
		vec3 cloudFinalColour = cloudColor.rgb * clamp((cloudLight * color), 0.0, 1.0);
		
		cloudShape = cloudCover + cloudWeight * (cloudShape + turbShape);
		
		COLOR = mix(skycolour, clamp(skyWeight * skycolour + cloudFinalColour, 0.0, 1.0), clamp(cloudShape + color, 0.0, 1.0) * normal.y);
	}
}