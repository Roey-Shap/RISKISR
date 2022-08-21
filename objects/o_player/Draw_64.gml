/// @description

//switch (cur_action) {
//	case player_action.death:
//		var radius_max = SCREEN_W+1;
//		// get the raw percent value by first mapping total death transition animation time to [0, 1]
//		var percent = map(death_transition_duration, 0, action_timer, 0, 1);
//		// get a "percent of full radius" amount by using the percent
//		var curve = animcurve_get_channel(AnimationCurve1, "cv_animation_death");
//		var radius = radius_max * animcurve_channel_evaluate(curve, percent);
		
//		surface_set_target(global.layer_shapes);
//		draw_clear_alpha(c_black, 0);
//		draw_set_color(c_black);
//		draw_rectangle(0, 0, SCREEN_W, SCREEN_H, false);
		
//		gpu_set_blendmode(bm_subtract);
//		draw_set_color(c_white);
//		draw_circle(SCREEN_W/2, SCREEN_H/2, radius, false);
		
//		gpu_set_blendenable(bm_normal);
//		surface_reset_target();
		
//		draw_surface(global.layer_shapes, 0, 0);
//		draw_set_color(c_white);
//		draw_circle(SCREEN_W/2, SCREEN_H/2, radius, false);
				
//		break;
//}