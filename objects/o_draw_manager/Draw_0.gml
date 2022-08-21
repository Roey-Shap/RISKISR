/// @description


if global.game_state == game.playing {

	draw_from_list(global.sprite_FX_list_under);


	var grid = depth_sorting_grid;
	var h = cur_grid_h;

	var cur_inst;
	for (var i = 0; i < h; i ++) {
		cur_inst = grid[# 0, i];

		with (cur_inst) {
			event_perform(ev_draw, 0);
		}
	}
	
	with (o_player) {
		if !global.death_animation {
			var mx = MX;
			var my = MY;
			var xx = round(x);
			var yy = round(y);
			
			if invinciblility_timer > 0 and (invinciblility_timer % 6 == 0) {
				draw_set_alpha(0.4);
				gpu_set_fog(true, c_hurt, 0, 1);
				draw_sprite_ext(sprite_index, image_index, xx, yy, image_xscale, image_yscale,
							image_angle, c_white, image_alpha);
				gpu_set_fog(false, c_white, 0, 1);
				draw_set_alpha(1);
			}
				

			var cursor_rad = 4;
			draw_set_color(c_black);
			draw_circle(mx, my, cursor_rad++, true);
			draw_set_color(cursor_color);
			draw_circle(mx, my, cursor_rad++, true);
			draw_circle(mx, my, cursor_rad++, true);
			draw_set_color(c_black);
			draw_circle(mx, my, cursor_rad, true);
		}
	}

}