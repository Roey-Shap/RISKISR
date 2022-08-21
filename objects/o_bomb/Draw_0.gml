/// @description

stunnable_draw(function() {
	
	
	if cur_action == bomb_state.falling {
		var heightscale = map(0, global.spawn_falling_object_height, z, 1.5, 0);
		var w = sprite_width * heightscale;
		var h = sprite_height * heightscale / 2;
		var rx = RX;
		var ry = RY - 8;
			
		draw_set_alpha(map(0, global.spawn_falling_object_height/2, z, 1, 0));
		draw_set_color(c_black);
		draw_ellipse(rx - w/2, ry - h/2, rx + w/2, ry + h/2, false);
			
		draw_set_alpha(1);
		draw_set_color(c_white);
	}
	
	
	draw_sprite_ext(sprite_index, image_index, RX, RY + z, image_xscale, image_yscale,
					image_angle, image_blend, image_alpha);
						
	
});
