/// @description

event_inherited();

open = false;
outline_col = c_white;

able_to_interact_function = function() {
	return (!open);
}

interact_function = function() {
	open = true;
	sprite_index = spr_activator_open;
	global.countdown_timer = get_crumble_time();
	
	return;
}