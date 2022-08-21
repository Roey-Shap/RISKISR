/// @description

event_inherited();

action_timer = 0;
cur_action = enemy_action.none;

can_attack = false;
hpmax = 2;
hp = hpmax;

player_search_range = 130;

// waiting and roaming
target_spot = new Point(x, y);
roam_spd = 1.75;
roam_spot_find_range = 55;
wait_time_base = 1.25 * SECOND;
stop_spd = 0.07;

// shot
target = noone;
shot_charge_time = 0.9 * SECOND;
shooting_duration = 3.5 * SECOND;
shot_recoil_time = 1.5 * SECOND;
shot_angle = 0;

shot_spd = 4;
shot_life = 4 * SECOND;

shot_frequency = 15;


yoffset = 11;

sprite_idle = spr_nme_spin_shot_idle;
sprite_move_slow = spr_nme_spin_shot_walk;
sprite_charge = spr_nme_spin_shot_charge;
sprite_attack = spr_nme_spin_shot_attack;
sprite_cooldown = spr_nme_spin_shot_dizzy;//spr_nme_shoot_charge_cooldown;

draw_self_custom = true;


function enemy_step() {
	
	// Find the player
	if can_attack {
		var near_player = instance_nearest(x, y, o_player);
		if distance_to_object(near_player) <= player_search_range {
			effect_create_below(ef_ring, x, y, 0.1, c_aqua);
			
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
			set_sprite(sprite_charge);
			if !instance_exists(target) {
				// make its new target position where it is right now so it immediately snaps into the roaming loop
				cur_action = enemy_action.roaming;
				target_spot.xy(x, y);
				break;
			}
				
			
			hspd = lerp(hspd, 0, stop_spd);
			vspd = lerp(vspd, 0, stop_spd);
			shot_angle = point_direction(x, y, target.x, target.y);
			
			if action_timer <= 1 {
				// go into the spin attack
				cur_action = enemy_action.shooting;
				action_timer = shooting_duration;
				hspd = lengthdir_x(4, shot_angle);
				vspd = lengthdir_y(4, shot_angle);
			}
		break;
		
		case enemy_action.shooting:
			hspd = lerp(hspd, 0, stop_spd);
			vspd = lerp(vspd, 0, stop_spd);
			
			set_sprite(sprite_attack);
			if action_timer % shot_frequency == 0 {
				// shoot the projectile 
				var shot = spawn_shot(x, y, o_bullet);
				var ran_angle = round_to_unit(irandom(359), 20);
				shot.hspd = lengthdir_x(shot_spd, ran_angle);
				shot.vspd = lengthdir_y(shot_spd, ran_angle);
				shot.image_angle = ran_angle;
				shot.life = shot_life;

				make_sprite_FX_ext(x, y, global.spark_sprites, 0, irandom(3) + 1, new Point(-shot.hspd, -shot.vspd), new Point(shot.hspd, shot.vspd), 
									[0, shot.hspd], [0, shot.vspd], [0.8, 1], [c_white, c_ltblue, c_spark]);	
				play_sound_random_pitch_priority(global.bullet_sounds, 5);
			}
			
			if irandom(10) == 0 make_sprite_FX_ext(x, y, global.spark_sprites, 0, 1, new Point(-1, -1), new Point(1, 1), [-3, 3], [-3, 3], [0.8, 1], [c_white, c_black]);	
	
			if action_timer <= 1 {
				cur_action = enemy_action.shot_recoil;
				action_timer = shot_recoil_time;
			}
		break;
		
		case enemy_action.shot_recoil:
			set_sprite(sprite_cooldown);
			hspd = lerp(hspd, 0, stop_spd);
			vspd = lerp(vspd, 0, stop_spd);
			
			if action_timer <= 1 {
				// hmm. Gives an interesting bounce behavior. 
				// to make them just stand there, use:
				// cur_action = enemy_action.none;
				// action_timer = 2;
				
				cur_action = enemy_action.roaming;
				target_spot.xy(x, y);
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

	if hdir != 0 image_xscale = hdir;
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