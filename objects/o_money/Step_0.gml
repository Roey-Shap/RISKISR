/// @description

pickup_limit_timer -= TIMESTEP * (pickup_limit_timer > 0);

follow = instance_nearest(x, y, o_player);
var following = false; 
if pickup_limit_timer <= 0 {
	if instance_exists(follow)  {
		if distance_to_object(o_player) <= SCREEN_W {
			following = true;
			var dir = point_direction(x, y, follow.x, follow.y);
			var total_spd = point_distance(0, 0, hspd, vspd);
			total_spd = lerp(total_spd, 10, 0.075);
	
			hspd = lerp(hspd, lengthdir_x(total_spd, dir), 0.425);
			vspd = lerp(vspd, lengthdir_y(total_spd, dir), 0.425);
		}
	} 
}
if following {
	hspd = lerp(hspd, 0, fric);
	vspd = lerp(vspd, 0, fric);
}

x += hspd;
y += vspd;

if place_meeting(x, y, o_player) {
	global.money++;
	var snd = play_sound_random_master([snd_coin_get], 3);
	set_SFX_sound_gain(snd);
	instance_destroy(id)
}