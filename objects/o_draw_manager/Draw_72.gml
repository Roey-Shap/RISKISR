/// @description

if global.game_state == game.playing {


	var grid = depth_sorting_grid;
	var h = cur_grid_h;

	var cur_inst;
	for (var i = 0; i < h; i ++) {
		cur_inst = grid[# 0, i];

		with (cur_inst) {
			event_perform(ev_draw, ev_draw_begin);
		}
	}

}