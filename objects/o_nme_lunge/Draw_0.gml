/// @description

// Inherit the parent event
event_inherited();

stunnable_draw(function(){ 
	draw_self();	
	if global.debug {
		draw_set_color(c_red);
		draw_circle(floor(x), floor(y), lunge_range, true);
	}
});

//if global.debug {
//	target_spot.draw(0, 0, 8)
//	draw_set_color(c_white);
//	//draw_text(x, y-40, cur_action);
//}