// Script assets have changed for v2.3.0 see
// https://help.yoyogames.com/hc/en-us/articles/360005277377 for more information
function out_of_bounds_destroy(){
	if !in_rectangle(x, y, CAM_X - sprite_width - (CAM_W/2), CAM_Y - sprite_height - CAM_H/2,
							CAM_X + sprite_height + CAM_W/2, CAM_Y + sprite_height + CAM_H/2) {
			instance_destroy(id);	
	}
}