// Script assets have changed for v2.3.0 see
// https://help.yoyogames.com/hc/en-us/articles/360005277377 for more information
function cam_shake(_shake_x, _shake_y, _duration, _base_time_on_decay) {
	with (o_camera) {
		shake_x = _shake_x;
		shake_y = _shake_y;
		shake_counter = _duration;
		end_shake_with_decay = _base_time_on_decay != 0;
		if end_shake_with_decay shake_counter = -1;
	}
}