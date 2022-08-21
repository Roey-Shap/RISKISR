/// @description

// Inherit the parent event
event_inherited();

interact_function = function() {
	
	with(o_player){
		hp += 1;
		var spd = 0.85;
		make_sprite_FX_ext(x, y, global.circle_sprites, -1, choose(3, 5), 
			new Point(-1, -1), new Point(1, 1), [-spd, spd], [-spd, spd], [0.8, 1], [c_white, merge_color(c_white, c_hotpink, 0.5), c_hotpink]);
	}
	play_sound_random([snd_health_1]);

	instance_destroy(id);
	
	return;
}

image_speed = 1;