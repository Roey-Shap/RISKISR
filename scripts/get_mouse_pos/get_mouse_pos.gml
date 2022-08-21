// Script assets have changed for v2.3.0 see
// https://help.yoyogames.com/hc/en-us/articles/360005277377 for more information
function get_mouse_pos(){
	var mx = (window_mouse_get_x()/window_get_width()) * display_get_gui_width();
	var my = (window_mouse_get_y()/window_get_height()) * display_get_gui_height();
	
	return (new Point(mx, my));
}