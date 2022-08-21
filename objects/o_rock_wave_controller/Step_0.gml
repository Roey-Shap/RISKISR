/// @description


if point_distance(x, y, wave_target.x, wave_target.y) <= point_distance(0, 0, hspd, vspd) {
	instance_destroy(id);
}

if place_piece_timer <= 0 {
	place_piece_timer = place_piece_pause;
	
	var r = 6;
	var add_x = irandom_range(-r, r);
	var add_y = irandom_range(-r, r);
	
	var piece = instance_create_layer(round(x) + add_x, round(y) + add_y, LAYER_BULLET, o_rock_wave);
}

place_piece_timer -= TIMESTEP;

x += hspd * TIMESTEP;
y += vspd * TIMESTEP;