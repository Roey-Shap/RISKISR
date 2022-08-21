/// @description

event_inherited();

open = false;
outline_col = c_white;
image_speed = 1;

able_to_interact_function = function() {
	var close = false;
	if instance_exists(o_player) {
		close = (distance_to_object(o_player) <= sprite_width*1.5 and !global.entering_gate);
	}
	return (close and global.opened_gate and global.game_state == game.playing);
}

interact_function = function() {
	
	if room == rm_tutorial {
		// reset room, go to "chest phase" and the final HUD explanation
		COUNTDOWN = -1;
		
		var sprites = global.circle_sprites;
		repeat (2) {
			make_sprite_FX_master(x, y, sprites, 0, irandom_range(15, 20), 
									-1, -1, [-2, 2], [-3, -0.5], [0.7, 0.85], [c_white, c_spark, c_spark_dark],
									0.997, 0.1);
			sprites = global.spark_sprites;
		}
		
		make_sprite_FX(x, y, [spr_bomb_exploding], 1, 1, [0, 0], [0, 0], [c_white]);
		
		with (o_activation_module) {
			var sprites = global.circle_sprites;
			repeat (2) {
			make_sprite_FX_master(x, y, sprites, 0, irandom_range(15, 20), 
									-1, -1, [-2, 2], [-3, -0.5], [0.7, 0.85], [c_white, c_spark, c_spark_dark],
									0.997, 0.1);
			sprites = global.spark_sprites;
		}
			instance_destroy(id);
		}
		
		if global.tutorial_function_index >= global.tutorial_functions_num - 1 {
			global.game_state = game.main_menu;
			room = rm_main_menu;
		} else {
			global.tutorial_function_index++;
			// run the next function
			exec(global.tutorial_functions[global.tutorial_function_index]);
		}
		
		instance_destroy(id);
		
	} else {
		with (o_player) {
			cur_action = player_action.enter_gate;
			action_timer = 3.5 * SECOND;
		}
		global.entering_gate = true;
	
		play_sound_random_master([snd_exit_floor], 5);
	}
	
	return;
}
