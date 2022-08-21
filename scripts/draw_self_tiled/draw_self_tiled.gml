// Script assets have changed for v2.3.0 see
// https://help.yoyogames.com/hc/en-us/articles/360005277377 for more information
function draw_self_tiled(){
	var base_spr_w = sprite_get_width(sprite_index);
	var base_spr_h = sprite_get_height(sprite_index);
	for (var w = 0; w < image_xscale; w++) {
		for (var h = 0; h < image_yscale; h++) {
			draw_sprite_ext(sprite_index, image_index, 
							x + (w*base_spr_w), y + (h*base_spr_h),
							1, 1, 0, image_blend, image_alpha);
		}
	}
}