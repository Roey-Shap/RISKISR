// Script assets have changed for v2.3.0 see
// https://help.yoyogames.com/hc/en-us/articles/360005277377 for more information
function set_sprite(sprite){
	if sprite_index != sprite {
		image_index = 0;
		image_index_last = 0;
	}
	sprite_index = sprite;
}