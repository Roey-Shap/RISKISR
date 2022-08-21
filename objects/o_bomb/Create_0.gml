/// @description

event_inherited();

parent = noone;
invinciblility_timer = 0;
hitbox = -1;
hp = 0.5;

can_explode_timer = 12;	// so instantiators don't immediately trigger it
explosion_duration = sprite_get_time(spr_bomb_exploding);
fall_explosion_height = 5;
grav = 0.2;
zspd = 0;
zspd_max = 5;


// set initial fuse time
action_timer = 2.25 * SECOND;

enum bomb_state {
	moving,
	exploding,
	falling,
}
cur_action = bomb_state.moving;

function bomb_step() {
	switch (cur_action) {
		case bomb_state.moving:
			if z != 0 {
				cur_action = bomb_state.falling;
				action_timer = 8 * SECOND;
				break;
			}
			
			try_graze();
			
			collided = false;

			if collide {
				// Collision
				var h_col = instance_place(x + hspd, y, o_collision_basic);
				if h_col != noone {
					hspd = 0;
					collided = true;
				}

				x += hspd * TIMESTEP;


				var v_col = instance_place(x, y + vspd, o_collision_basic);
				if v_col != noone {
					vspd = 0;
					collided = true;
				}

				y += vspd * TIMESTEP;	
			}

			if can_explode_timer <= 0 and (place_meeting(x, y, o_hit_parent) or hp <= 0 or collided) {
				action_timer = 0;
			}
		break;
	
		case bomb_state.exploding:
			if action_timer <= 1 {
				instance_destroy(id);
			}
	
		break;
		
		case bomb_state.falling:
			
			invinciblility_timer = -1;
			zspd += grav;
			zspd = max(zspd, zspd_max);
			z += zspd;
		
			if z >= -fall_explosion_height {
				cam_shake(random_range(0.8, 1.3), random_range(2.5, 5.5), random_range(20, 40), 0);
				action_timer = 0;
			}
		
		break;
	}
	action_timer -= TIMESTEP;
	can_explode_timer -= TIMESTEP;
}