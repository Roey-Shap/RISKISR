// Script assets have changed for v2.3.0 see
// https://help.yoyogames.com/hc/en-us/articles/360005277377 for more information
function push_from_object(object_ind, push_spd) {
	
	//push yourself away from close objects
	
	var inst = instance_place(x, y, object_ind);
	var pushspd_x = 0;
	var pushspd_y = 0;
	if inst != noone {
		var my_center_x = (bbox_left + bbox_right)/2;
		var my_center_y = (bbox_top + bbox_bottom)/2;
		var inst_center_x = (inst.bbox_left + inst.bbox_right)/2;
		var inst_center_y = (inst.bbox_top + inst.bbox_bottom)/2;
		
		var angle = point_direction(inst_center_x, inst_center_y, my_center_x, my_center_y);
		pushspd_x = lengthdir_x(push_spd, angle); // * TIMESTEP for separate push and normal spds ?
		pushspd_y = lengthdir_y(push_spd, angle); // * TIMESTEP for separate push and normal spds ?
	}

	hspd = sign(hspd)*min(abs(hspd + pushspd_x), maxspd_when_pushed);
	vspd = sign(vspd)*min(abs(vspd + pushspd_y), maxspd_when_pushed);
}