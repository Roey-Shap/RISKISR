/// @description

depth_sorting_grid = ds_grid_create(2, 0);
cur_grid_h = 0;

title_x1_off = 0;
title_y1_off = 0;
title_x2_off = 0;
title_y2_off = 0;
title_x3_off = 0;
title_y3_off = 0;
title_x4_off = 0;
title_y4_off = 0;


player_under_minimap_alpha = 1;
player_under_HUD_alpha = 1;

var title = spr_RISKISR;
title_w = sprite_get_bbox_right(title) - sprite_get_bbox_left(title);
title_h = sprite_get_bbox_bottom(title) - sprite_get_bbox_top(title);

