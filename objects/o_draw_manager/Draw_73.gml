/// @description

if global.game_state == game.playing {
	


	var grid = depth_sorting_grid;
	var h = cur_grid_h;

	var cur_inst;
	for (var i = 0; i < h; i ++) {
		cur_inst = grid[# 0, i];
	
		with (cur_inst) {
			event_perform(ev_draw, ev_draw_end);
			
			if global.debug {
				draw_set_alpha(0.25);
				var col = c_lime;
				draw_rectangle_colour(bbox_left,bbox_top,bbox_right,bbox_bottom,col,col,col,col,false);
			}
		}
	}

	draw_from_list(global.sprite_FX_list_over);

	if global.debug and ds_exists(global.hitboxes, ds_type_list) {
		var hitboxes = ds_list_size(global.hitboxes);
		for (var i = 0; i < hitboxes; i++) {
			var cur = global.hitboxes[| i];
			if is_hitbox(cur) cur.draw();
		}
	}
}
