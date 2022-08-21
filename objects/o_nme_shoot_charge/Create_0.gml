/// @description

event_inherited();

action_timer = 0;
cur_action = enemy_action.none;

can_attack = false;

player_search_range = 180;
hpmax = 2;
hp = hpmax;

reward = ceil(reward * 1.3);

// waiting and roaming
target_spot = new Point(x, y);
roam_spd = 0.6;
roam_spot_find_range = 80;
wait_time_base = SECOND;
stop_spd = 0.09;

// shot
projectile = o_bullet;
target = noone;
shot_charge_time = 2.25 * SECOND;
shooting_time = 1.75 * SECOND;
shot_recoil_time = 3.8 * SECOND;
shot_angle = 0;
kickback_spd = 3.5;
roam_while_shoot_spd = 0.45;

rotation_difference_divisor = 5;	// higher is slower turning speed
rotation_difference_while_charging_divisor = 1;
shot_width = 6;
shot_width_max = shot_width;
group = -1;

nudge_raw = 10;
wall_hit_point = new Point(x, y);


// Sprites

yoffset = 16;

sprite_idle = spr_nme_shoot_charge_idle;
sprite_move_slow = spr_nme_shoot_charge_walk;
sprite_charge = spr_nme_shoot_charge_charging;
sprite_attack = spr_nme_shoot_charge_shooting;
sprite_cooldown = spr_nme_shoot_charge_cooldown;//spr_nme_shoot_charge_cooldown;

draw_self_custom = true;

// Sounds

charge_sound = -1;



function enemy_step() {
	
	// Find the player
	if can_attack {
		var near_player = instance_nearest(x, y, o_player);
		if distance_to_object(near_player) <= player_search_range {
			effect_create_below(ef_ring, x, y - yoffset, 0.05, c_spark);
			
			cur_action = enemy_action.shot_charge;
			action_timer = shot_charge_time;
			target = near_player;
			shot_angle = point_direction(x, y - yoffset, near_player.x, near_player.y); 
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
				
			if !audio_is_playing(snd_charge_loop_1) {
				charge_sound = audio_play_sound(snd_charge_loop_1, 3, true);
				audio_sound_gain(charge_sound, 0, 0);
				audio_sound_gain(charge_sound, global.SFX_volume, shot_charge_time/2);
			}

			
			var cx = x;
			var cy = y - yoffset;

			effect_create_below(ef_smoke, cx, cy, 0.1, c_ltblue);
			
			hspd = lerp(hspd, 0, stop_spd);
			vspd = lerp(vspd, 0, stop_spd);

					
			if action_timer <= 1 {
				if audio_is_playing(charge_sound) {
					audio_stop_sound(charge_sound);
				}
				play_sound_random([snd_charge_shot_1]);

				cur_action = enemy_action.shooting;
				action_timer = shooting_time * random_range(0.8, 1.2);
				wall_hit_point.xy(x, y);
				// always has some error in shooting
				shot_angle += (15 * random_range(0.4, 1) * choose(-1, 1));
				shot_width = 0;
				if is_hitboxGroup(group) {
					list_delete_safe(group.hitboxes);
					delete group;
				}
				group = new HitboxGroup();
				
				// shot kickback
				var kickback = kickback_spd * random_range(0.8, 1.1);
				hspd += lengthdir_x(kickback, shot_angle + 180);
				vspd += lengthdir_y(kickback, shot_angle + 180);				
			} else {
				var targ_angle = point_direction(cx, cy, target.x, target.y);
				var ad = TIMESTEP * angle_difference(shot_angle, targ_angle)/rotation_difference_while_charging_divisor;
				shot_angle -= min(abs(ad), 1) * sign(ad);
			}
		break;
		
		case enemy_action.shooting:
			
			set_sprite(sprite_attack);
			
			if !instance_exists(target) {
				// make its new target position where it is right now so it immediately snaps into the roaming loop
				cur_action = enemy_action.roaming;
				target_spot.xy(x, y);
				break;
			}
			var cx = x;
			var cy = y - yoffset;
			var targ_angle = point_direction(cx, cy, target.x, target.y);
			
			hspd = lerp(hspd, lengthdir_x(roam_while_shoot_spd, targ_angle), 0.075);
			vspd = lerp(vspd, lengthdir_y(roam_while_shoot_spd, targ_angle), 0.075);
			
			var ad = TIMESTEP * angle_difference(shot_angle, targ_angle)/rotation_difference_divisor;
			shot_angle -= min(abs(ad), 1) * sign(ad);

			//reset wall_hit_point 
			wall_hit_point.xy(cx, cy);
			
			//push endpoint towards wall
			var max_dis = ROOM_W;
			var cur_dis = 0;
			
			var nudge_x = lengthdir_x(nudge_raw, shot_angle);
			var nudge_y = lengthdir_y(nudge_raw, shot_angle);
			while (cur_dis < max_dis and instance_position(wall_hit_point.x, wall_hit_point.y, o_collision_basic) == noone) {
				wall_hit_point.x += nudge_x;
				wall_hit_point.y += nudge_y;
				cur_dis += nudge_raw;
			}
			var tries = nudge_raw*2;
			var unit_nudge_x = lengthdir_x(1, shot_angle + 180);
			var unit_nudge_y = lengthdir_y(1, shot_angle + 180);
			while (tries > 0 and instance_position(wall_hit_point.x, wall_hit_point.y, o_collision_basic) != noone) {
				wall_hit_point.x += unit_nudge_x;
				wall_hit_point.y += unit_nudge_y;
				tries--
			}
			shot_width = lerp(shot_width, shot_width_max, 0.1);
			
			// create hitboxes along laser beam
			var final_dis = wall_hit_point.distance_to_xy(cx, cy);
			// shot_width_max since we're using shot_width as the diameter of each hitbox
			// 5/8 to spread apart hitboxes - helps performance and we don't even need that many
			var hitboxes = (4/8) * (final_dis/shot_width_max);
			for (var i = 0; i < hitboxes; i++) {
				var p = wall_hit_point.lerp_xy(cx + nudge_x, cy + nudge_y, i/hitboxes);
				var box = new Hitbox(p.x, p.y, shot_width * 5/8, shot_width * 5/8, hitbox_shape.ellipse, 0, 1, 1, id, -1);
				box.no_hits_objects = [o_nme_parent];
				box.add_to_group(group);
			}
			
			group.update();

			var opp_angle = shot_angle + 180;
			var dustspd = 2.5;
			var variance = 75;
			if irandom(12) == 0 opp_angle += irandom_range(-variance, variance);
			var hkick_min = lengthdir_x(dustspd, opp_angle - variance);
			var hkick_max = lengthdir_x(dustspd, opp_angle + variance);
			var vkick_min = lengthdir_y(dustspd, opp_angle - variance);
			var vkick_max = lengthdir_y(dustspd, opp_angle + variance);
			
			make_sprite_FX_ext(cx, cy, global.spark_sprites, -1, irandom_range(0, 1), new Point(-3, -3), new Point(3, 3), [hkick_min, hkick_max], [vkick_min, vkick_max], [0.8, 1], [c_white, c_flame, c_ltblue]);
			
			make_sprite_FX_ext(wall_hit_point.x, wall_hit_point.y, global.spark_sprites, 0, irandom_range(1, 2), new Point(-1, -1), new Point(1, 1), [hkick_min, hkick_max], [vkick_min, vkick_max], [0.8, 1], [c_white, c_gray, c_black, c_ltblue]);
			effect_create_below(ef_smoke, wall_hit_point.x, wall_hit_point.y, 0.04, c_ltgray);
			
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