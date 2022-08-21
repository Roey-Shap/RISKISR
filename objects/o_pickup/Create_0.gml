/// @description
event_inherited();

image_speed = 0;
image_index = 0;

 
outline_col = c_white;
charm_type = charms.none;
pickup_limit_timer = 0.9 * SECOND; 

hspd = 0;
vspd = 0;
charm_spd = 3;
fric = 0.1;


able_to_interact_function = function() {
	// gives some buffer space between highlight that shows you can interact and the actual opening
	var player_is_close = false;
	if instance_exists(o_player) {
		if distance_to_object(o_player) <= 10 player_is_close = true;
	}
	return (player_is_close and pickup_limit_timer <= 0);
}

interact_function = function() {
	instance_destroy(id);

	
	
	return;
}