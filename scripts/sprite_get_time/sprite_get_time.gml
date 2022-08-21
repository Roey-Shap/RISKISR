// Script assets have changed for v2.3.0 see
// https://help.yoyogames.com/hc/en-us/articles/360005277377 for more information
function sprite_get_time(sprite){
	return (sprite_get_number(sprite) * (SECOND / sprite_get_speed(sprite)));
}