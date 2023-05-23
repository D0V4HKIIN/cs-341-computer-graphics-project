shader_type spatial;
render_mode unshaded, cull_disabled;
 
uniform sampler2D tex;
uniform vec4 color1 : source_color;
uniform float displ_amnt = 0.8;
uniform float displ_speed = 20.0;
uniform float time_scale = 1.;

void vertex()
{
	float mask = 1.0 - sin(PI * UV.x);
	float time = (TIME * (0.5 + INSTANCE_CUSTOM.y) * time_scale) + (6.28318 * INSTANCE_CUSTOM.x);;
	
	VERTEX.y += cos(time * displ_speed) * displ_amnt * mask;
}
 
void fragment()
{
	vec4 col = texture(tex, UV) * color1;
	ALPHA_SCISSOR_THRESHOLD = 0.01;
	ALPHA = col.a;
	ALBEDO = col.rgb;
}
