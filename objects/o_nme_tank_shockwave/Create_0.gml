/// @description

event_inherited();

hpmax = 3;
hp = hpmax;

reward = 9;

action_timer = 0;
cur_action = enemy_action.none;

can_attack = false;
do_next_attack_timer = 0;

// waiting and roaming
target_spot = new Point(x, y);
roam_spd = 1;
roam_spot_find_range = 90;
wait_time_base = 1 * SECOND;
stop_spd = 0.1;

player_search_range = 185;
short_range_attack_range = 15;
projectile_attack_range = 105;


approach_spd = 0.8;
approach_lerp_spd = 0.3;

// attacks
target = noone;
pre_short_range_attack_duration = 0.6 * SECOND;
short_range_attack_cooldown = 1 * SECOND;
short_range_attack_pause_duration = 0.15 * SECOND;	// time between attacks if multiple are performed

projectile_charge_duration = 0.9 * SECOND;
projectile_pause_duration = 0.3 * SECOND;	// time between attacks if multiple are performed
projectile_cooldown = 1.25 * SECOND;

short_range_attack_function = -1;
attack_locked_pos = -1;

var temp_arr = [0.6, 0.3, 0.1];
slam_chance_array = cumulative_chance(temp_arr);

next_action = enemy_action.none;
hitbox = -1;

// Sprites
sprite_idle = spr_nme_slammer_idle;
sprite_move_slow = spr_nme_slammer_idle;
sprite_charge = spr_nme_slammer_slam_charge;
sprite_attack = spr_nme_lunge_attack;
sprite_cooldown = spr_nme_slammer_slam_after;

function enemy_step() {
	
	var slam_audio = false;
	
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
			
			if distance_to_object(target) <= short_range_attack_range {
				cur_action = enemy_action.wait;
				var factor = 0.7;			//slows down a bit to emphasize the close-range slam
				action_timer = pre_short_range_attack_duration * (1/factor);
				image_speed = factor;
				slam_amount = choose_from_cumulative_array(slam_chance_array);
				hitbox = -1;
				
			} else if distance_to_object(target) <= projectile_attack_range and do_next_attack_timer <= 0 {
				cur_action = enemy_action.shot_charge;
				action_timer = projectile_charge_duration;
				rock_wave = noone;
				slam_amount = choose_from_cumulative_array(slam_chance_array);	// no need for +1 because we're using one now
				target_spot = new Point(target.x, target.y);
			}
			
			
			var targ_dir = point_direction(x, y, target.x, target.y);
			
			hspd = lerp(hspd, lengthdir_x(approach_spd, targ_dir), approach_lerp_spd);
			vspd = lerp(vspd, lengthdir_y(approach_spd, targ_dir), approach_lerp_spd);
					
		break;
		
		// short range attack
		case enemy_action.wait:
			hold_sprite(sprite_charge);
			hspd = lerp(hspd, 0, 0.12);
			vspd = lerp(vspd, 0, 0.12);
			
			if action_timer <= 1 {
		
				cur_action = enemy_action.lunge_cooldown;
				action_timer = short_range_attack_cooldown * random_range(0.9, 1.1);
				
				if short_range_attack_function != -1 {
					short_range_attack_function();
				}
			}
		break;
		
		case enemy_action.lunge_cooldown:
			image_speed = 1;
			hspd = lerp(hspd, 0, 0.12);
			vspd = lerp(vspd, 0, 0.12);
			
			if !instance_exists(target) {
				// make its new target position where it is right now so it immediately snaps into the roaming loop
				cur_action = enemy_action.roaming;
				target_spot.xy(x, y);
				target = noone;
				break;
			}	
			
			hold_sprite(sprite_cooldown);
			
			// on the correct frame range, create the hitbox and perform effects
			if is_between(image_index, 0.5, 1) and !is_hitbox(hitbox){
				
				cam_shake(random(1), random_range(1, 2.5), 15 + irandom_range(0, 8), 0);
				
				// just make the hitbox as a way to denote it having attacked - don't want other random variables floating around
				hitbox = new Hitbox(-1, -1, 60, 60, hitbox_shape.ellipse, 0, 20, 0, id, new Vector2_xy(0, 0));
				hitbox.no_hits = [id];
				hitbox.no_hits_objects = [o_nme_parent];
				
				var accuracy = 10;
				for (var i = 0; i < accuracy; i++) {
					var angle = (i/accuracy) * 360;
					var r = 3;
					var radius = 30;
					var add_x = lengthdir_x(radius, angle) + irandom_range(-r, r);
					var add_y = lengthdir_y(radius, angle) + irandom_range(-r, r);
	
					var piece = instance_create_layer(round(x) + add_x, round(y) + add_y, LAYER_BULLET, o_rock_wave);
					
					effect_create_below(ef_ring, x, y, 0.1, c_spark);
				
					slam_audio = true;
				}
				
				make_sprite_FX_master(x, y, global.spark_sprites, -1, irandom_range(6, 9), new Point(-4, -4), new Point(4, 4), 
										[-2, 2], [-4.5, -1.5], [0.8, 1], [c_white, c_flame , c_ltblue],
										0.99, 0.18);
				
			}
			

			if action_timer <= 1 {
				cur_action = enemy_action.none;
				action_timer = short_range_attack_cooldown * random_range(0.8, 1.1);
				do_next_attack_timer = 20 * random_range(1, 1.3);
				hitbox = -1;
			}
		break;		
		
		
		// mid-range attack
		case enemy_action.shot_charge:
			hold_sprite(sprite_charge);
			hspd = lerp(hspd, 0, 0.12);
			vspd = lerp(vspd, 0, 0.12);
			
			if action_timer <= 1 {
				cur_action = enemy_action.shot_recoil;
				action_timer = (slam_amount > 0? projectile_pause_duration : projectile_cooldown) * random_range(1, 1.3);
			}
		break;
		
		case enemy_action.shot_recoil:
			hspd = lerp(hspd, 0, 0.12);
			vspd = lerp(vspd, 0, 0.12);
			
			
			if !instance_exists(target) {
				// make its new target position where it is right now so it immediately snaps into the roaming loop
				cur_action = enemy_action.roaming;
				target_spot.xy(x, y);
				target = noone;
				break;
			}	
			
			hold_sprite(sprite_cooldown);
			if is_between(image_index, 0.5, 1) {
				
				if rock_wave == noone {
					rock_wave = instance_create_layer(x, y - 4, LAYER_BULLET, o_rock_wave_controller);
					rock_wave.wave_direction = point_direction(x, y - 4, target.x, target.y);
					var spd = 3;
					rock_wave.hspd = lengthdir_x(spd, rock_wave.wave_direction);
					rock_wave.vspd = lengthdir_y(spd, rock_wave.wave_direction);
					rock_wave.wave_target = new Point(target.x + rock_wave.hspd*2, target.y + rock_wave.vspd*2);
					effect_create_below(ef_ring, x, y, 0.05, c_spark);
					
					cam_shake(random(1), random_range(1, 2), 15 + irandom_range(0, 8), 0);
					
					slam_audio = true;
				}
				make_sprite_FX_master(x, y, global.spark_sprites, -1, 5, new Point(-4, -4), new Point(4, 4), 
											[-2, 2], [-4, -1], [0.8, 1], [c_white, c_ltgray],
											0.99, 0.2);
											
				
			}
			
			
			// loop back in to another projectile slam
			if is_between(action_timer, 2, 3) and slam_amount > 0 {
				sprite_index = sprite_idle;	// reset it for animation playing next slam
				image_index = 0;
				slam_amount--;
				cur_action = enemy_action.shot_charge;
				action_timer = floor(projectile_pause_duration * random_range(0.8, 1.1));
			
				rock_wave = noone;
				target_spot = new Point(target.x, target.y);
				
				hitbox = -1;
				
				break;		// cuts off the action here once it's decided to go again!
			}
			
			if action_timer <= 1 {
				cur_action = enemy_action.none;
				action_timer = wait_time_base * random_range(0.8, 1.1);
				do_next_attack_timer = action_timer * random_range(1, 1.3);
			}
		break;
	
		
		
		
	}	
	
	nme_default_push_func();
	
	
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
	
	if slam_audio {
		play_sound_random_pitch([snd_tank_slam_1]);
	}
	
	// Timers
	action_timer -= TIMESTEP * (action_timer > 0);
	do_next_attack_timer -= TIMESTEP * (do_next_attack_timer > 0);
	enemy_health_check();
	
}