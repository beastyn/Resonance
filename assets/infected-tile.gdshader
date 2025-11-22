// infected_tile_ripple.shader (CanvasItem shader)
shader_type canvas_item;
render_mode unshaded;

uniform sampler2D behind_texture; // The texture you want to sample from behind
uniform float tile_size = 200.0;    // The size of your tiles
// A varying variable to pass world position from vertex to fragment shader
varying flat vec2 world_pos;
uniform sampler2D screen_texture : hint_screen_texture, repeat_disable, filter_nearest;

uniform vec4 tint_color : source_color = vec4(0.6, 0.4, 1.0, 0.22);
uniform float mix_tint : hint_range(0.0, 1.0) = 0.7;     // how much tint to mix in
// 1 = enabled, 0 = disabled
uniform float side_top    : hint_range(0.0, 1.0) = 1.0;
uniform float side_right  : hint_range(0.0, 1.0) = 1.0;
uniform float side_bottom : hint_range(0.0, 1.0) = 1.0;
uniform float side_left   : hint_range(0.0, 1.0) = 1.0;
// thickness in pixels for the tinted band
uniform float thickness_px : hint_range(0.0, 200) = 8.0;
// softness (in pixels) for fading the band edges
uniform float soften_px : hint_range(0.0, 32.0) = 4.0;

uniform float pulse_speed : hint_range(0, 100) = 1.6;
uniform float pulse_freq  : hint_range(2, 40.0)  = 10.0;
uniform float pulse_amp   : hint_range(0.0, 0.08)  = 0.02; // normalized (0..1), will convert to screenspace
uniform float edge_fade   : hint_range(0.0, 100.0)   = 0.85; // fade toward tile edges
uniform float noise_seed  : hint_range(0.0, 10.0)  = 0.0;  // vary per-tile slightly via tile atlas param

// how strongly to distort the underlying screen sampling; scale by viewport size
uniform float distortion_strength : hint_range(0.0, 16.0) = 6.0;

void fragment() {
    // base color of the overlay tile (we'll sample the SCREEN below)
    vec2 uv = UV; // local UV inside the tile (0..1)
    vec2 screen_uv = SCREEN_UV; // full-screen uv for sampling SCREEN_TEXTURE

    // small per-pixel ripple based on local uv + time
    float t = TIME * pulse_speed;
    float wave = sin((uv.x + uv.y) * pulse_freq + t + noise_seed * 6.2831);

    // vertical ripple offset (in screen UV units)
    // convert pixel-ish amplitude to screen UV: distortion_strength / VIEWPORT_SIZE.y
    vec2 pixel_offset = vec2(0.0, wave * pulse_amp * distortion_strength);

    // sample the screen behind this tile with a small offset to create a subtle distortion
    vec4 behind = texture(screen_texture, screen_uv + pixel_offset);
	
	
	// --- compute per-side mask using tile-local UV (0..1 inside tile) ---
    vec2 luv = UV; // 0..1 across tile

    // convert thickness/soften from pixels -> tile-UV units
    vec2 thickness_uv = vec2( thickness_px / max(1.0, tile_size),
                              thickness_px / max(1.0, tile_size) );
    vec2 soften_uv = vec2( soften_px / max(1.0, tile_size),
                           soften_px / max(1.0, tile_size) );

   // thickness/soften in UV space
vec2 t_uv = vec2(thickness_px / tile_size, thickness_px / tile_size);
vec2 s_uv = vec2(soften_px / tile_size, soften_px / tile_size);

// Top edge: luv.y near 0
float top_edge = 1.0 - smoothstep(t_uv.y, t_uv.y + s_uv.y, luv.y);

// Bottom edge: luv.y near 1
float bottom_edge = smoothstep(1.0 - t_uv.y - s_uv.y, 1.0 - t_uv.y + s_uv.y, luv.y);

// Left edge: luv.x near 0
float left_edge = 1.0 - smoothstep(t_uv.x - s_uv.x, t_uv.x + s_uv.x, luv.x);

// Right edge: luv.x near 1
float right_edge = smoothstep(1.0 - t_uv.x - s_uv.x, 1.0 - t_uv.x + s_uv.x, luv.x);


// Combine sides
float side_mask = clamp(
    top_edge    * side_top +
    right_edge  * side_right +
    bottom_edge * side_bottom +
    left_edge   * side_left,
    0.0, 1.0
);

    // optionally modulate side_mask with the wave (if you want band intensity to pulse)
    float mask_pulse = 0.5 + 0.5 * wave; // 0..1
    float final_mask = mix(side_mask, side_mask * mask_pulse, 0.0); // 35% pulsing influence

    // --- tint/composition ---
    vec3 tinted = mix(behind.rgb, tint_color.rgb, tint_color.a * mix_tint * final_mask);
	
    // tinting: mix behind color toward our tint
    //vec3 tinted = mix (behind.rgb, tint_color.rgb, tint_color.a);

    // soft fade near tile edges to make effect less harsh
    float edge = smoothstep(0.0, 1.0, min(uv.x, 1.0 - uv.x) * 2.0) * smoothstep(0.0, 1.0, min(uv.y, 1.0 - uv.y) * 2.0);
    edge = pow(edge, 1.0 / max(0.001, edge_fade)); // tweak falloff

    // final mix: blend between behind and tinted+distorted color, modulated by edge and wave amplitude
    float intensity = (0.5 + 0.5*wave) * edge;  // wave gives subtle pulsing
    vec3 final_rgb = mix(behind.rgb, tinted + (tint_color.rgb * 0.001 * wave), intensity * 0.9);

    // compose alpha: keep underlying alpha (we don't want to block)
    float out_alpha = behind.a;

    COLOR = vec4(final_rgb, out_alpha);
}