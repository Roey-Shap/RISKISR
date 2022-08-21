if fade_timer > 0 or fade_timer == -1 {
	var adj_timer = (fade_timer == -1 ? maxTime : fade_timer);
	var fade_fraction = clamp((2*adj_timer/maxTime), 0, 1);
	// fade == 1 --> fade from 0 to 1
	// fade == 0 --> fade from 1 to 0
	var a = ( fade == 1 ? 1-fade_fraction : fade_fraction );
	
	draw_set_color(merge_color(c_dkblue, c_black, 0.8));
	draw_set_alpha(a);
	draw_rectangle(x - camwidth/2, y - camheight/2, x + camwidth/2, y + camheight/2, false);
	
	draw_set_alpha(1);
}

//if instance_exists(follow) {
//	draw_set_color(c_black);
//	draw_text(x, y, [follow.x, follow.y]);
//}