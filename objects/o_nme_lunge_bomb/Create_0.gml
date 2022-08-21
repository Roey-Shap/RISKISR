/// @description

// Inherit the parent event
event_inherited();

lunge_function = function(cur_point, lunge_vector) {
	var shot = spawn_shot(cur_point.x, cur_point.y, o_bullet);
	var mag = lunge_vector.mag * 0.35;
	var dir = lunge_vector.dir + 15*random_range(-1, 1);
	
	shot.hspd = lengthdir_x(mag, dir);
	shot.vspd = lengthdir_y(mag, dir);
	shot.image_angle = dir;
	shot.life = -1;
}

image_blend = c_spark;