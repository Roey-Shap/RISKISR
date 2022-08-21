/// @description

event_inherited();

hpmax = 1;
hp = hpmax;

action_timer = 0;
cur_action = enemy_action.none;

can_attack = false;

player_search_range = 150;

// waiting and roaming
target_spot = new Point(x, y);
roam_spd = 2;
roam_spot_find_range = 70;
wait_time_base = SECOND;
stop_spd = 0.07;

// shot
projectile = o_bullet;
target = noone;
shot_charge_time = 0.75 * SECOND;
shot_recoil_time = 1 * SECOND
shot_angle = 0;

shot_spd = 4;
shot_life = 4 * SECOND;

kickback_spd = 0.7;
shot_function = -1;


sprite_idle = spr_nme_basic_idle;
sprite_move_slow = spr_nme_basic_walk;
sprite_charge = spr_nme_basic_shot_charge;
sprite_cooldown = spr_nme_basic_shot_recoil;

yoffset = 7;


function enemy_step() {
	
	// Find the player
	if can_attack and global.enemy_find_target_timer <= 0 {
		var near_player = instance_nearest(x, y, o_player);
		if distance_to_object(near_player) <= player_search_range {
			cur_action = enemy_action.shot_charge;
			action_timer = shot_charge_time;
			target = near_player;
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
		
		case enemy_action.shot_charge:
			hold_sprite(sprite_charge);
			if !instance_exists(target) {
				// make its new target position where it is right now so it immediately snaps into the roaming loop
				cur_action = enemy_action.roaming;
				target_spot.xy(x, y);
				break;
			}
				
			
			hspd = lerp(hspd, 0, stop_spd);
			vspd = lerp(vspd, 0, stop_spd);
			shot_angle = point_direction(x, y - yoffset, target.x, target.y);
			
			if action_timer <= 1 {
				// shoot the projectile 
				var shot = spawn_shot(x, y, projectile);
				shot.hspd = lengthdir_x(shot_spd, shot_angle);
				shot.vspd = lengthdir_y(shot_spd, shot_angle);
				shot.image_angle = shot_angle;
				shot.life = shot_life;
				
				if shot_function != -1 shot_function();
				
				// shot kickback
				var kickback = kickback_spd * random_range(0.8, 1.1);
				hspd += lengthdir_x(kickback, shot_angle + 180);
				vspd += lengthdir_y(kickback, shot_angle + 180);	
				
				// sound
				play_sound_random_pitch(global.bullet_sounds);
				
				// move to recoil
				cur_action = enemy_action.shot_recoil;
				action_timer = shot_recoil_time;
				
				effect_create_below(ef_ring, x, y, 0.075, c_spark);
				
			}
		break;

		case enemy_action.shot_recoil:
			hold_sprite(sprite_cooldown);
			hspd = lerp(hspd, 0, stop_spd);
			vspd = lerp(vspd, 0, stop_spd);
			
			if action_timer <= 1 {
				// hmm. Gives an interesting bounce behavior. 
				// to make them just stand there, use:
				 cur_action = enemy_action.none;
				 action_timer = 2;
				
				//cur_action = enemy_action.roaming;
				//target_spot.xy(x, y);
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
	
	
	// Timers
	action_timer -= TIMESTEP * (action_timer > 0);
	
	enemy_health_check();
}