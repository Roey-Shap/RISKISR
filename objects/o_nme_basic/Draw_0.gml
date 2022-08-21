/// @description

// Inherit the parent event
event_inherited();

stunnable_draw(function(){ 
	if cur_action == enemy_action.shot_charge {
		draw_set_color(c_ltblue);
		draw_line_ext(x, y - yoffset, target.x, target.y, 1, 0, 15);
	}
	
	draw_self();	
});

//if global.debug {
//	target_spot.draw(0, 0, 8)
//	draw_set_color(c_white);
//	//draw_text(x, y-40, cur_action);
//}