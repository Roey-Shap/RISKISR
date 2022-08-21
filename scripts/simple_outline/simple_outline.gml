// Script assets have changed for v2.3.0 see
// https://help.yoyogames.com/hc/en-us/articles/360005277377 for more information
function simple_outline(x, y, sprite, image_ind, xscale, yscale, xoff, yoff, rot, col, alpha){
	gpu_set_fog(true, col, 0, 1);
	var offsets = [
		[0, -1],
		[1, 0],
		[0, 1],
		[-1, 0],
	]
	draw_set_alpha(alpha);
	for (var i = 0; i < 4; i++) {
		draw_sprite_ext(sprite, image_ind, x + (xoff*offsets[i][0]), y + (yoff*offsets[i][1]),
						xscale, yscale, rot, col, 1);
	}
	
	draw_set_alpha(1);	
	gpu_set_fog(false, col, 0, 1);
}