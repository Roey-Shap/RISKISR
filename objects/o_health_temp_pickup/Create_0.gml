/// @description

// Inherit the parent event
event_inherited();

interact_function = function() {
	
	with(o_player){
		var prev_temp_hp = temp_hp;
		temp_hp = min(temp_hp+1, global.player_max_temp_hp);
		var overflow = temp_hp == prev_temp_hp;
		if overflow {
			hp = min(hp + overflow, hpmax);
		}
		
		var spd = 0.85;
		var cols = overflow?	[c_white, c_spark, c_hotpink]:
								[c_white, merge_color(c_white, c_spark, 0.5), c_spark, c_spark_dark];
		make_sprite_FX_ext(x, y, global.circle_sprites, -1, choose(3, 5), 
			new Point(-1, -1), new Point(1, 1), [-spd, spd], [-spd, spd], [0.8, 1], cols);
	}
	var snd = play_sound_random([snd_health_1]);
	audio_sound_pitch(snd, random_range(0.7, 0.9));

	instance_destroy(id);
	
	return;
}

image_speed = 1;