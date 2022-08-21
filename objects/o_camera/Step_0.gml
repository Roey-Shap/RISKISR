/// @description Player tracking

// Check for scale updates
//var lerpSpd = 0.3;
//if place_meeting(x, y, o_camera_zone) {
//	scale = lerp(scale, o_camera_zone.scale, lerpSpd);
//} else {
//	scale = lerp(scale, 1, lerpSpd);
//}



// Use updated scale
var adj_width = camwidth * scale;
var adj_height = camheight * scale;

// decrement
fade_timer -= (fade_timer > 0) * TIMESTEP;

// if not the locking value (-1) then react to having counted down
if fade_timer <= 0 and fade_timer != -1 {
	if fade == 1 {
		if fade_timer != -1 { // to ensure that it doesn't activate from the default "locked" state
			if room_id != -1 { //incase it's just default "room+1" for some reason
				room = room_id;
			} else {
	//			room += 1;
			}
		}
	}
}

if instance_exists(follow){
	xTo = follow.x;
	yTo = follow.y;
} else {
	xTo = room_width/2;
	yTo = room_height/2;
}


if global.game_state == game.playing {
	x += (((xTo - x)/8)) * TIMESTEP;
	y += (((yTo - y)/8)) * TIMESTEP;

	x = clamp(x, adj_width/2, room_width-adj_width/2);
	y = clamp(y, adj_height/2, room_height-adj_height/2);
	
	
	if shake_counter > 0 or shake_counter == -1 {
		if shake_counter != -1 {
			shake_counter -= TIMESTEP;
		}
		x += round(shake_x*choose(-1, 1));
		y += round(shake_y*choose(-1, 1));
		shake_x *= shake_decay;
		shake_y *= shake_decay;
	
		if abs(shake_x) <= 0.1 and abs(shake_y) <= 0.1 and end_shake_with_decay {
			shake_counter = 0;
		}
	} else {
		if abs(x-xTo) <= 1 x = xTo;
		if abs(y-yTo) <= 1 y = yTo;
	}

}

x = round(x);
y = round(y);

global.cam_x = x;
global.cam_y = y;
global.cam_w = adj_width;
global.cam_h = adj_height;
global.cam_scale = scale;

var vm = matrix_build_lookat(x, y, -100, x, y, 0, 0, 1, 0);
var pm_norm = matrix_build_projection_ortho(adj_width, adj_height, 1.0, 32000.0);
camera_set_view_mat(varCamera, vm);
camera_set_proj_mat(varCamera, pm_norm);
