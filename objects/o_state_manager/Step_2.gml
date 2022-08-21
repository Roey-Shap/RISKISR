/// @description

//for (var i = 0; i < ds_list_size(global.hitboxes); i++) {
//	var cur = global.hitboxes[| i];
//	if cur.prepare_to_remove cur.remove();
//}

if global.room_generated {
	if global.paused_this_frame {
		reset_GUI_FX_lists();
		deactivate();
	} else {
		switch (global.game_state) {
			case game.playing:
				//assess only relevant objects
				var factor = 1;
				deactivate();
				
				instance_activate_region(CAM_X - CAM_W*factor, CAM_Y - CAM_H*factor,
											CAM_W*factor*2, CAM_H*factor*2, true);
				
				if global.enemy_find_target_timer <= 0 {
					global.enemy_find_target_timer = global.enemy_find_target_frequency;
				}
				
				break;
			
			case game.end_review:
				
				
				break;
		
		}
	}
}
