shader_type particles;

uniform float scale_factor;
uniform vec2 direction;
uniform float travel_distance;
uniform float amplitude;
uniform float frequency;
uniform float speed;

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
	//TRANSFORM[3].xy -= EMISSION_TRANSFORM[3].xy*CUSTOM[0];
   
    // --------- Debug visuals ----------
    // progress 0..1 across lifetime
    float prog = clamp(CUSTOM[0] / LIFETIME, 0.0, 1.0);
    // normalized sine 0..1
    float s_norm = 0.5 + 0.5 * sin(sin_arg);
    // color: R = prog, G = s_norm, B = 1-prog  (so each cycle shows as G pulses)
    COLOR = vec4(prog, s_norm, 1.0 - prog, 1.0);

    // size pulses strongly at peaks so you can count them
    // when sin crosses 1 (peak), size increases
    float peakness = smoothstep(0.95, 1.0, sin(sin_arg)); // near 1 at peaks
    // base size 4..12 px (adjust with SIZE in particle UI if needed)		
//
//
//
//
    //// compute perpendicular velocity term (derivative of A*sin(k*s))
    //// dy/dt = A * k * cos(k*s) * ds/dt  (ds/dt == speed)
    //float perp_vel_scalar = amplitude * freq * cos(freq * s) * speed;
//
    //// set velocity: base along dir + oscillating component along normal
    //VELOCITY.xy = direction * speed + normal * perp_vel_scalar;
	}
