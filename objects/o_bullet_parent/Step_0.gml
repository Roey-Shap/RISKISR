/// @description

collided = false;

if collide {
	// Collision
	var h_col = instance_place(x + hspd, y, o_collision_basic);
	if h_col != noone {
		hspd = 0;
		collided = true;
	}

	x += hspd * TIMESTEP;


	var v_col = instance_place(x, y + vspd, o_collision_basic);
	if v_col != noone {
		vspd = 0;
		collided = true;
	}

	y += vspd * TIMESTEP;	
}

try_graze();