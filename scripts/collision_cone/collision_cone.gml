// Script assets have changed for v2.3.0 see
// https://help.yoyogames.com/hc/en-us/articles/360005277377 for more information

// Angles should be in the range [0, 360)
 
function collision_cone(_x, _y, radius, search_angle, angle_range, instance){
	var dis = point_distance(_x, _y, instance_or_object.x, instance_or_object.y);
	if dis > radius return -1;
	var ang = point_direction(_x, _y, instance_or_object.x, instance_or_object.y);

	var ang_min = search_angle + angle_range;
	var ang_max = search_angle - angle_range;
	return !is_between(ang, ang_min, ang_max);
	
}