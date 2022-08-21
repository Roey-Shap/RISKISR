// Script assets have changed for v2.3.0 see
// https://help.yoyogames.com/hc/en-us/articles/360005277377 for more information
function find_player_path(targ_x, targ_y, input_path, avoid_obj){
	if input_path != noone {
		path_delete(input_path);
	}
	var path = path_add();
	
	mp_potential_path_object(path, targ_x, targ_y, 1, 5, avoid_obj);
	
	return(path);
}