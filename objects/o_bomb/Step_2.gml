/// @description

if state != stun_state.stun {
	// Inherit the parent event
	event_inherited();
	
	
	if cur_action != bomb_state.exploding {
		if action_timer <= 0 and !is_hitbox(hitbox) {
			cur_action = bomb_state.exploding;
			action_timer = explosion_duration;
			hitbox = new Hitbox(x, y, 22*image_xscale, 22*image_yscale, hitbox_shape.ellipse, 0, 8, round(1*image_xscale), id, new Vector2_xy(0, 0));
			hitbox.hitstun_time *= 1.3;
				
			var range = 12;
			var colors = [c_white, c_spark, c_spark_dark];
			make_sprite_FX_ext(x, y, global.spark_sprites, 1, irandom_range(13, 16), 
								new Point(-range, -range), new Point(range, range), [-0.5, 0.5], [-1.5, 0.5], [0.7, 1], colors);
			var snd = play_sound_random_master(global.explosion_sounds, 6);
			set_SFX_sound_gain(snd);
			audio_sound_pitch(snd, random_range(0.8, 1.2));
		}
	}
	
	switch (cur_action) {
		case bomb_state.moving:			
			set_sprite(spr_bomb_moving);
		break;

		case bomb_state.falling:			
			set_sprite(spr_bomb_moving);
			
			
		break;

		case bomb_state.exploding:
			set_sprite(spr_bomb_exploding);
		break;
	}
}

//if z >= 0 {
//	out_of_bounds_destroy();
//}