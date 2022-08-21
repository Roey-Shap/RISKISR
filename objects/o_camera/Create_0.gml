/// @description Camera variables

camwidth = SCREEN_W;
camheight = SCREEN_H;
scale = 1;

var adj_width = camwidth * scale;
var adj_height = camheight * scale;
varCamera = camera_create();

view_set_wport(0, camwidth);
view_set_hport(0, camheight);

var vm = matrix_build_lookat(x, y, -100, x, y, 0, 0, 1, 0);
var pm_norm = matrix_build_projection_ortho(adj_width, adj_height, 1.0, 32000.0);

camera_set_view_mat(varCamera, vm);
camera_set_proj_mat(varCamera, pm_norm);

view_camera[0] = varCamera;

follow = noone;
if instance_exists(o_player){
	follow = instance_nearest(x, y, o_player);
	
	x = follow.x;
	y = follow.y;
	if follow.object_index == o_player {
		var ball = new Point(x, y);
		with (follow) {
			if cur_action = player_action.enter_gate_ball {
				var r = 8 + sin(current_time/100);
				var maxHeight = 40;
				var percent = map(0, ball_form_time, action_timer, 0, 1);
				// get a "percent of full radius" amount by using the percent
				var curve = animcurve_get_channel(AnimationCurve1, "cv_animation_ball");
				var z = maxHeight * animcurve_channel_evaluate(curve, percent);
				ball = new Point(lerp(o_exit_gate.x, x, percent), lerp(o_exit_gate.y - 12, y, percent) - z);
			}
		}
		x = ball.x;
		y = ball.y;
	}

}

xTo = x;
yTo = y;

x = round(x);
y = round(y);

current_room = room;

// Shake
shake_counter = 0;
shake_frequency = 0;
shake_x = 0;
shake_y = 0;
shake_decay = 0.998;

maxTime = 45;
fade_timer = maxTime;
room_id = -1;
fade = 0; //0 = fade in, 1 = fade out

up_follow = false;

global.cam_x = x;
global.cam_y = y;
global.cam_w = adj_width;
global.cam_h = adj_height;

global.camera = id;





