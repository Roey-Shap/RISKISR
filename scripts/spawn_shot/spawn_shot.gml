// Script assets have changed for v2.3.0 see
// https://help.yoyogames.com/hc/en-us/articles/360005277377 for more information
function spawn_shot(_x, _y, _type){
	var shot = instance_create_layer(_x, _y, LAYER_BULLET, _type);
	shot.parent = id;
	
	return(shot);
}