shader_type particles;

uniform float scale_factor;
uniform vec2 direction;
uniform float travel_distance;
uniform float amplitude;
uniform float frequency;
uniform vec4 color;
uniform float bloom;

void start(){
	CUSTOM[0] = 0.0;
	TRANSFORM[0].xy = vec2(1, 0) * scale_factor;
	TRANSFORM[1].xy = vec2(0, 1) * scale_factor;
}

void process() {
	bool restart = false;
	if (CUSTOM.y > CUSTOM.w) {
		restart = true;
	}

	float pi = 3.14159;
	float degree_to_rad = pi / 180.0;
	//vec3 force = gravity;
	vec3 pos = TRANSFORM[3].xyz;
	pos.z = 0.0;

	TRANSFORM[0].xy = vec2(1, 0) * scale_factor;
	TRANSFORM[1].xy = vec2(0, 1) * scale_factor;

	if (RESTART || restart){
		TRANSFORM = EMISSION_TRANSFORM;
		TRANSFORM[0].xy = vec2(1, 0) * scale_factor;
	    TRANSFORM[1].xy = vec2(0, 1) * scale_factor;
	}

	CUSTOM[0] += DELTA/LIFETIME;
    vec2 normal = vec2(-direction.y, direction.x);

	float forward_speed = travel_distance / LIFETIME; // pixels per second
	// scalar distance along path at time t
    float s = travel_distance * CUSTOM[0]; // 0 .. travel_distance

	// spatial angular freq such that sin_arg = TAU * cycles_over_distance * (s / travel_distance)
    // => sin_arg = TAU * cycles_over_distance * (s / travel_distance)
    float sin_arg = (TAU/2.0) * frequency * CUSTOM[0];

    // time derivative: ds/dt = forward_speed, so perp_vel = A * d/dt[ sin_arg ]
    // d/dt[sin_arg] = TAU * cycles_over_distance * (forward_speed / travel_distance) * cos(...)
    float perp_vel =  TAU * frequency * amplitude * (forward_speed / travel_distance) * cos(sin_arg);

	//TRANSFORM[3].xy = normal * perp_vel + direction * forward_speed;
    // final velocity
    VELOCITY.xy = direction * forward_speed + normal * perp_vel;
    COLOR = vec4(color.r, color.g, color.b, color.a) * bloom;
	}
