// Script assets have changed for v2.3.0 see
// https://help.yoyogames.com/hc/en-us/articles/360005277377 for more information
function hold_sprite(sprite, min_image, max_image){
	min_image = is_undefined(min_image) ? 0 : min_image;
	max_image = is_undefined(max_image) ? image_number-1 : max_image;

	if sprite_index != sprite {
		image_index = min_image;
	}
	sprite_index = sprite;
	end_of_loop = false;
	if image_index+1 >= max_image {
		image_index = max_image;
		end_of_loop = true;
	}
	return(end_of_loop);
}