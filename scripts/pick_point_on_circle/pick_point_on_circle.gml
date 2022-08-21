// Script assets have changed for v2.3.0 see
// https://help.yoyogames.com/hc/en-us/articles/360005277377 for more information
function pick_point_on_circle(_x, _y, _rad){
	var ran_mag = random(_rad);
	var ran_angle = irandom(359);
	return (new Point(_x + lengthdir_x(ran_mag, ran_angle), _y + lengthdir_y(ran_mag, ran_angle)));
}