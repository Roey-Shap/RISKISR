/// @description

stunnable_draw(function(){
		
	var cx = x;
	var cy = y - yoffset;
	
	var ran_x = 0, ran_y = 0, ran_ang = 0, col = image_blend;
	
	switch (cur_action) {
		case enemy_action.shot_charge:
			var flash_freq = floor(map(shot_charge_time, 0, action_timer, 2, 6)) - 1;
			image_speed = map(shot_charge_time, 0, action_timer, 1, 1.5);
			if action_timer % flash_freq == 0 {
				if instance_exists(target) {
					draw_set_color(merge_color(c_white, c_spark_dark, action_timer/shot_charge_time));
					draw_line_width(cx, cy, cx + lengthdir_x(SCREEN_W*2, shot_angle), cy + lengthdir_y(SCREEN_W*2, shot_angle), map(shot_charge_time, 0, action_timer, 3, 1));
				}
			}
			
			break;
		
		case enemy_action.shooting:
			image_speed = 1;

			draw_set_color(c_ltblue);
			draw_line_width(cx, cy, wall_hit_point.x, wall_hit_point.y, shot_width);
			draw_set_color(c_white);
			draw_line_width(cx, cy, wall_hit_point.x, wall_hit_point.y, floor(shot_width/4));
			
			var shake = 1;
			var ang_range = 2;
			ran_x = irandom_range(-shake, shake);
			ran_y = irandom_range(-shake, shake);
			ran_ang = irandom_range(-ang_range, ang_range);
			
			
			break;
			
		case enemy_action.shot_recoil:
			gpu_set_fog(true, c_black, 0, 1);
			draw_set_alpha(0.3);
			draw_sprite_ext(sprite_index, image_index, 0, 1, image_xscale, image_yscale,
							image_angle, c_white, 1);
			draw_set_alpha(1);
			gpu_set_fog(false, c_black, 0, 1);
			
			break;
	}
	
	draw_sprite_ext(sprite_index, image_index, x + ran_x, y + ran_y, image_xscale, image_yscale, image_angle + ran_ang, col, image_alpha);
});

// Inherit the parent event
event_inherited();

if global.debug {
	if is_hitboxGroup(group){
		draw_text(x, y-35, group.num_hitboxes);
	}
}

//if global.debug {
//	target_spot.draw(0, 0, 8)
//	draw_set_color(c_white);
//	//draw_text(x, y-40, cur_action);
//}