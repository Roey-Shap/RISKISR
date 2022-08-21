/// @description

stunnable_draw(function() { 
	var rad = radius;
	var ebb2 = map(-1, 1, sin(current_time/100), 0.9, 1);
	var ebb1 = map(-1, 1, sin(current_time/50), 0.5, 1);
	draw_set_color(c_white);
	draw_circle(round(x), round(y), rad, false);
	draw_set_color(c_ltblue);
	draw_circle(round(x), round(y), rad * 0.8 * ebb2, false);	
	draw_set_color(c_white);
	draw_circle(round(x), round(y), rad * 0.25 * ebb1, false);
})