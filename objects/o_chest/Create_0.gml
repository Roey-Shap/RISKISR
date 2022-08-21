/// @description
event_inherited();

image_speed = 0;
image_index = 0;

open = false;
outline_col = c_white;
charm_type = charms.none;

spawned_contents = false;

able_to_interact_function = function() {
	// gives some buffer space between highlight that shows you can interact and the actual opening
	return (!open and collision_circle(x + sprite_width/2, y + sprite_height/2, 17, o_player, false, false));
}

interact_function = function() {
	
	open = true;
	
	// the delay in the sound is large enough that it can begin right as you interact with it
	play_sound_random_pitch([snd_chest_open]);	
		
	return;
}