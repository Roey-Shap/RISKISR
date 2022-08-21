/// @description

// Inherit the parent event



stunnable_draw(function(){ 
	var ran_x = 0, ran_y = 0, ran_ang = 0, col = image_blend, bob_y = 0;
	
	switch (cur_action) {
		case enemy_action.shooting:
			//var shake = 1;
			//var ang_range = 2; 
			//if irandom(1) ran_x = irandom_range(-shake, shake);
			//if irandom(1) ran_y = irandom_range(-shake, shake);
			ran_ang = 15 * sin((current_time + id)/250);
			
			bob_y = 5 * sin((current_time + id)/100);
			
			break;
	}
	draw_sprite_ext(sprite_index, image_index, x + ran_x, y + ran_y + bob_y, image_xscale, image_yscale, image_angle + ran_ang, col, image_alpha);
});

event_inherited();

//if global.debug {
//	target_spot.draw(0, 0, 8)
//	draw_set_color(c_white);
//	//draw_text(x, y-40, cur_action);
//}