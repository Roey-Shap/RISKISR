/// @description

can_be_pressed_timer -= TIMESTEP;
if can_be_pressed_timer <= 0 {
	if distance_to_object(o_player) <= r {
		if global.tutorial_function_index >= global.tutorial_functions_num - 1 {
			global.game_state = game.main_menu;
			room = rm_main_menu;
		} else {
			global.tutorial_function_index++;
			// run the next function
			exec(global.tutorial_functions[global.tutorial_function_index]);
		}
		
		instance_destroy(id);
	}
}