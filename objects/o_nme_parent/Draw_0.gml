/// @description

if global.debug {
	draw_set_color(c_lime);
	draw_circle(floor(x), floor(y), player_search_range, true);
}

if !draw_self_custom draw_self();

var rad = 3, margin = 5;
var total_hp_w = (rad * (hp - 1+1)) + (margin*(hp-1 + 1));
var left = round(x) - total_hp_w/2;
var yy = round(y) - sprite_yoffset - 8;
for (var i = 0; i < hp; i++) {
	draw_set_color(c_spark_dark);
	draw_circle(left + (rad * (i+1)) + (margin*(i)), yy, rad, false);
	draw_set_color(c_white);
	draw_circle(-1 + left + (rad * (i+1)) + (margin*(i)), yy - 1, rad, false); 
}