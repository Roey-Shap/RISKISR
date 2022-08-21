// Script assets have changed for v2.3.0 see
// https://help.yoyogames.com/hc/en-us/articles/360005277377 for more information
function get_gui_coords(_x, _y){
	return (new Point(_x - CAM_X + SCREEN_W/2, _y - CAM_Y + SCREEN_H/2));
}

function get_gui_x(_x) {
	return (_x - CAM_X + SCREEN_W/2);
}

function get_gui_y(_y) {
	return (_y - CAM_Y + SCREEN_H/2);
}