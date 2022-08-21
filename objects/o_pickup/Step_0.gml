/// @description

pickup_limit_timer -= TIMESTEP * (pickup_limit_timer > 0);


hspd = lerp(hspd, 0, fric);
vspd = lerp(vspd, 0, fric);

// Collision
var h_col = instance_place(x + hspd, y, o_collision_basic);
var hdir = sign(hspd);

if h_col != noone {
	while !place_meeting(x + hdir, y, h_col) {
		x += hdir;
	}
	hspd *= 0.9;
}

x += hspd * TIMESTEP;


var v_col = instance_place(x, y + vspd, o_collision_basic);
var vdir = sign(vspd);

if v_col != noone {
	while !place_meeting(x, y + vdir, v_col) {
		y += vdir;
	}
	vspd *= 0.9;
}

y += vspd * TIMESTEP;
	
if abs(hspd) < 0.1 hspd = 0;
if abs(vspd) < 0.1 vspd = 0;