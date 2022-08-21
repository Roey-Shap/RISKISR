// Script assets have changed for v2.3.0 see
// https://help.yoyogames.com/hc/en-us/articles/360005277377 for more information
function stunnable_create(){
	hpmax = 3;
	hp = hpmax;
	
	hspd = 0;
	vspd = 0;
	
	being_hit = false;
	stun_timer = 0;
	invinciblility_timer = 0;
	state = stun_state.none;
	
	hurt_sprite = sprite_index;
}

function stunnable_step(unstunned_function) {
	switch (state) {
		case stun_state.none:
			if unstunned_function != undefined {
				unstunned_function();
			}
			if invinciblility_timer != -1 {
				invinciblility_timer -= TIMESTEP;
				invinciblility_timer = max(invinciblility_timer, 0);
			}
		break;
		
		
		case stun_state.stun:
			image_speed = 0;
			stun_timer -= TIMESTEP;
			if stun_timer <= 0 {
				image_speed = 1;
				stun_timer = -1;
				being_hit = false;
				state = stun_state.none;
			}
		break;
	}
}

function stunnable_draw(unstunned_function) {
	switch (state) {
		case stun_state.none:
			if unstunned_function != undefined {
				unstunned_function();
			}
		break;
		
		
		case stun_state.stun:
			var xx = floor(x);
			var yy = floor(y);
			var sprite = sprite_index;
			var rot = image_angle;
			var col = image_blend;
			
			if being_hit {
				sprite = hurt_sprite;
				
				var shudder = 2;
				var angle_shudder = 5;
				xx += irandom_range(-shudder, shudder);
				yy += irandom_range(-shudder, shudder);
				rot += irandom_range(-angle_shudder, angle_shudder)
				
				gpu_set_fog(true, c_hurt, 0, 1);
				var offsets = [
					[0, -1],
					[1, 0],
					[0, 1],
					[0, -1],
				]
				for (var i = 0; i < 4; i++) {
					var rad = 1;
					draw_sprite_ext(sprite, image_index, xx + offsets[i][0]*rad, yy + offsets[i][1]*rad, image_xscale, image_yscale, rot, col, image_alpha);
				}
				gpu_set_fog(false, c_white, 0, 1);
			}
			
			draw_sprite_ext(sprite, image_index, xx, yy, image_xscale, image_yscale, rot, col, image_alpha);
			
				
		break;
	}
}