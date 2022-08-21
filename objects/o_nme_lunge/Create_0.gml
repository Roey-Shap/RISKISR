/// @description

event_inherited();

hpmax = 1;
hp = hpmax;

action_timer = 0;
cur_action = enemy_action.none;

can_attack = false;

// waiting and roaming
target_spot = new Point(x, y);
roam_spd = 2.5;
roam_spot_find_range = 65;
wait_time_base = 0.75 * SECOND;
stop_spd = 0.07;

player_search_range = 185;
lunge_range = 45;

approach_spd = 2.25;
approach_lerp_spd = 0.3;

// attack
target = noone;
pre_lunge_duration = 0.3 * SECOND;
//lunge_duration = 0.1 * SECOND;
lunge_cooldown_time = 1.2 * SECOND;

lunge_cooldown_lerp_spd = 0.055;
lunge_spd = 7.5;
lunge_function = -1;
lunge_locked_pos = -1;

sprite_idle = spr_nme_lunge_idle;
sprite_move_slow = spr_nme_lunge_walk;
sprite_charge = spr_nme_lunge_ready;
sprite_attack = spr_nme_lunge_attack;
sprite_cooldown = spr_nme_lunge_cooldown;


function enemy_step() {
	
	// Find the player
	var near_player = instance_nearest(x, y, o_player);
	if can_attack {
		if distance_to_object(near_player) <= player_search_range {
			
			var hdir = sign(near_player.x - x);
			var vdir = sign(near_player.y - y)
			cur_action = enemy_action.approach;
			action_timer = 2;
			target = near_player;
			image_xscale = hdir;
		}
	}
	
	// from here assume that you can't attack - an action will update to true if necessary
	can_attack = false;
	
	// Manage actions
	
	switch(cur_action) {
		case enemy_action.none:
			set_sprite(sprite_idle);
			can_attack = true;
			
			hspd = 0;
			vspd = 0;
			
			if action_timer <= 1 {
				cur_action = enemy_action.roaming;

				// pick a new spot
				var tries = 15;
				var pot_point = pick_point_on_circle(x, y, roam_spot_find_range);
				while (place_meeting(pot_point.x, pot_point.y, o_collision_basic) and tries > 0) {
					pot_point = pick_point_on_circle(x, y, roam_spot_find_range);
				}
				if tries == 0 target_spot.xy(x, y);
				else target_spot = pot_point;
			}
		break;
		
		case enemy_action.roaming:
			set_sprite(sprite_move_slow);
			can_attack = true;
			
			var to_targ_dir = point_direction(x, y, target_spot.x, target_spot.y);
			hspd = lengthdir_x(roam_spd, to_targ_dir);
			vspd = lengthdir_y(roam_spd, to_targ_dir);
		
			if point_distance(x, y, target_spot.x, target_spot.y) <= roam_spd {
				cur_action = enemy_action.none;
				
				action_timer = wait_time_base * random_range(0.8, 1.1);
			}
		break;
		
		case enemy_action.approach:
			set_sprite(sprite_move_slow);
			if !instance_exists(target) {
				// make its new target position where it is right now so it immediately snaps into the roaming loop
				cur_action = enemy_action.roaming;
				target_spot.xy(x, y);
				target = noone;
				break;
			}	
			
			if distance_to_object(target) <= lunge_range {
				cur_action = enemy_action.wait;
				action_timer = pre_lunge_duration;
				effect_create_below(ef_ring, x, y, 0.05, c_spark);
				target_spot = new Point(target.x, target.y);
			
			}
			
			
			
			var targ_dir = point_direction(x, y, target.x, target.y);
			
			hspd = lerp(hspd, lengthdir_x(approach_spd, targ_dir), approach_lerp_spd);
			vspd = lerp(vspd, lengthdir_y(approach_spd, targ_dir), approach_lerp_spd);
					
		break;
		
		case enemy_action.wait:
			hold_sprite(sprite_charge);
			hspd = lerp(hspd, 0, 0.12);
			vspd = lerp(vspd, 0, 0.12);
			if action_timer <= 1 {
			
				cur_action = enemy_action.lunge_cooldown;
				action_timer = lunge_cooldown_time * random_range(0.9, 1.1); //lunge_duration; (not using mid lunge section for now)
				
				var to_targ_dir = point_direction(x, y, target_spot.x, target_spot.y);
				hspd = lengthdir_x(lunge_spd, to_targ_dir);
				vspd = lengthdir_y(lunge_spd, to_targ_dir);
		
				hitbox = new Hitbox(x, y, 14, 14, hitbox_shape.ellipse, 0, 13, 1, id, new Vector2_xy(0, 0));
				hitbox.no_hits = [id];
				hitbox.no_hits_objects = [o_nme_parent];
				
				if lunge_function != -1 {
					// provides current point and lunge speed vector
					lunge_function(new Point(x, y), new Vector2(lunge_spd, to_targ_dir));
				}
				
				var hdir = sign(near_player.x - x);
				var vdir = sign(near_player.y - y)
				var c1 = new Point(-3 * hdir, -3 * vdir);
				var c2 = c1.add_xy(4, 4);
				make_sprite_FX_ext(x, y, global.spark_sprites, -1, 4, c1, c2, [-2*hdir, 0], [-2*vdir, 0], [0.8, 1], [c_white, c_ltblue]);
			}
		break;
	
		
		case enemy_action.lunge_cooldown:
			if point_distance(0, 0, hspd, vspd) > 1.5 {
				set_sprite(sprite_attack);
			} else {
				set_sprite(sprite_cooldown);
			}
			hspd = lerp(hspd, 0, lunge_cooldown_lerp_spd);
			vspd = lerp(vspd, 0, lunge_cooldown_lerp_spd);
			
			if action_timer <= 1 {
				// hmm. Gives an interesting bounce behavior. 
				// to make them just stand there, use:
				cur_action = enemy_action.none;
				action_timer = wait_time_base * random_range(0.8, 1.1);
			}
		break;		
		
	}	
	
	if cur_action != enemy_action.lunge_cooldown {
		push_from_object(o_nme_parent, push_spd);
	}
	
	
	// Collision
	var h_col = instance_place(x + hspd, y, o_collision_basic);
	var hdir = sign(hspd);

	if h_col != noone {
		while !place_meeting(x + hdir, y, h_col) {
			x += hdir;
		}
		hspd = 0;
	}

	x += hspd * TIMESTEP;


	var v_col = instance_place(x, y + vspd, o_collision_basic);
	var vdir = sign(vspd);

	if v_col != noone {
		while !place_meeting(x, y + vdir, v_col) {
			y += vdir;
		}
		vspd = 0;
	}

	y += vspd * TIMESTEP;
		
	get_out_of_wall(4);
	
	if hspd != 0 image_xscale = sign(hspd);
	
	// Timers
	action_timer -= TIMESTEP * (action_timer > 0);
	enemy_health_check();
	
}