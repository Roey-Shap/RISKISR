/// @description

// Inherit the parent event
event_inherited();

image_speed = 0;

uses = 3;		// specifically for Heart of Gold

interact_function = function() {
	var near_player = instance_nearest(x, y, o_player);
	var dir = point_direction(x, y, o_player.x, o_player.y);
	

	if charm_type != charms.linker {
		
		if (global.player_charm_amount == 1 and global.player_charm != charms.none)
			or (global.player_charm_amount > 1 and global.player_charm != charms.none and global.player_charm_2 != charms.none) {
			var charm = instance_create_layer((x + near_player.x)/2, (y + near_player.y)/2,
											LAYER_UNDER, o_charm);
			charm.charm_type = global.player_charm;
			charm.hspd = lengthdir_x(charm_spd, dir + 180);
			charm.vspd = lengthdir_y(charm_spd, dir + 180);
			if global.player_charm == charms.heart_of_gold {
				charm.uses = global.heart_of_gold_uses;
			}
			global.player_charm = global.player_charm_2;
			global.heart_of_gold_uses = global.heart_of_gold_2_uses; 
		}
		
		global.player_charm_2 = charm_type;
		global.heart_of_gold_2_uses = uses;
		if charm_type == charms.heart_of_gold {
			global.heart_of_gold_2_uses = uses;
		}
		
		if global.player_charm == charms.none {
			global.player_charm = global.player_charm_2;
			global.heart_of_gold_uses = global.heart_of_gold_2_uses;
			global.player_charm_2 = charms.none;
			global.heart_of_gold_2_uses = 0;
		}		
		
		
		set_charm_defaults();
		
		//apply new charm (and Linker!) data, if any
		var func = global.charm_info[global.player_charm][4];
		if func != -1 func();
		
		func = global.charm_info[global.player_charm_2][4];
		if func != -1 func();
	}
	
	play_sound_random([snd_charm_get]);
		
	
	if charm_type == charms.linker and global.player_charm_amount == 1 {
		global.player_charm_amount = 2;
		o_player.deactivated_hearts++;
	}
	
	instance_destroy(id);

	
	
	return;
}