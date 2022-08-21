/// @description

event_inherited();
stunnable_create();

hpmax = global.player_max_hp;
hp = global.player_hp;
temp_hp = global.player_temp_hp;
deactivated_hearts = global.deactivated_hearts;

hclip_max = 0;
vclip_max = 0;
clip_factor = 4;

cur_action = player_action.none;
action_timer = 0;


walk_spd = 1.75;
walk_accel = 0.28;
skid_accel = 0.35;
stop_spd = 0.4;	// friction modifier

// Teleport
teleport_charge_start_timer = 0;	//prevents instant teleport
teleport_charge_start_time = 5;		//prevents instant teleport
teleport_adrenaline_cooldown_factor = 0.6;

teleport_charge_increment = 0.03;
teleport_charge = 0;
teleport_charge_max = 1;

teleport_limit_timer = 0;
teleport_limit_time = 15;		// minimum time between teleports
minimum_assisted_teleport_range = 40; // minimal distance for teleport assist system to give player a valid teleport - don't want them dropping bombs on themselves in place

cur_teleport_target = -1;
teleport_max_range_base = 155;
teleport_max_range_charge_factor = 1.2;
teleport_max_range_adrenaline_factor = 0.7;
teleport_max_range_adrenaline_2_charms_factor = 1;
teleport_max_range = teleport_max_range_base;
after_image_dis = 20;
after_image_duration_base = 18;

bomb_shot_spd = 3;

z = 0;

graze_radius = 30;
graze_offset_y = -7;
devil_horns_dup_range_bonus = 1.7;	// multiplier for when 2 devil's horns are active

// Movement control variables
hinput = 0;
vinput = 0;
teleinput = 0;
teleinput_hold = 0;

hinput_lock = false;
vinput_lock = false;
tele_lock = false;


// Action Duration data
death_transition_duration = 2.5 * SECOND;

// Sprites and visuals
cursor_color = c_white;
hurt_sprite = spr_player_hurt;

spark_sprites = global.spark_sprites;
ball_form_time = 1.6 * SECOND;

hit_effect_timer = 0;
hit_effect_duration = 0.5 * SECOND;
hit_effect_hp_add = 0;


// Meta control
key_up		= ord("W");
key_right	= ord("D");
key_down	= ord("S");
key_left	= ord("A");


// Extra, Tutorial
draw_tutorial_banter_timer = 0;


//global.money = 300;

//var charm = instance_create_layer(x, y + 100, LAYER_UNDER, o_charm);
//charm.charm_type = charms.linker;

//var charm = instance_create_layer(x - 100 , y + 100, LAYER_UNDER, o_charm);
//charm.charm_type = charms.stopwatch;

//var charm = instance_create_layer(x + 100 , y + 100, LAYER_UNDER, o_charm);
//charm.charm_type = charms.stopwatch;
//charm.uses = 2;

// spawn the exit door
if room == rm_generated {
	var door = instance_create_layer(x, y - 20, LAYER_BULLET, o_exit_gate);
}

// Functions

function handle_graze() {
	drop_reward_money(x, y + 10, irandom_range(1, 3));
	var effect = new fade_FX(RX, RY + 10, sprite_index, 1, image_index, SECOND);
	effect.alpha_factor = 0.75;
	var scale = 2;
	effect.image_xscale = scale;
	effect.image_yscale = scale;
	effect.fog_col = c_ltblue;
	
	var snd = play_sound_random_master([snd_graze_1], 4);
	set_SFX_sound_gain(snd);
	audio_sound_pitch(snd, random_range(0.8, 1.2));
}


function get_teleport_target() {
	var xx = floor(x);
	var yy = floor(y);
	
	// get vector to mouse
	var teleport_vec = new Vector2_fromTo(xx, yy, MX, MY);
	// then limit it to the appropriate distance
	teleport_vec.limit(teleport_max_range);
	
	// get the coordinates relative to you
	var teleport_targ = new Point(xx + teleport_vec.x, yy + teleport_vec.y);
	
	return teleport_targ;
}
	
function player_step() {

	var mx = MX;
	var my = MY; 
	
	var transition_lock = false;
	if instance_exists(o_camera) {
		transition_lock = o_camera.fade_timer > 0;
	}
	transition_lock = transition_lock or (cur_action == player_action.death);

	// Manage input
	var hinput_raw = clamp((keyboard_check(key_right) - keyboard_check(key_left) + 
					keyboard_check(vk_right) - keyboard_check(vk_left)), -1, 1);
	var vinput_raw = clamp((keyboard_check(key_down) - keyboard_check(key_up) + 
					keyboard_check(vk_down) - keyboard_check(vk_up)), -1, 1);
	var teleinput_raw = mouse_check_button_released(mb_left) and LMB_RELEASE;
	var teleinput_hold_raw = mouse_check_button(mb_left);

	hinput = hinput_raw * (!hinput_lock);
	vinput = vinput_raw * (!vinput_lock);
	teleinput = teleinput_raw * (!tele_lock) * (!transition_lock) 
				* (!global.left_click_locked) * (!global.player_must_release_lmb) * (global.tutorial_player_teleport_active or (room != rm_tutorial));
	teleinput_hold = teleinput_hold_raw * (!tele_lock) * (!transition_lock);
	
	if teleinput_raw global.player_must_release_lmb = false;

	var can_charge = has_charm(charms.big_balls);
	
	// the player moves and updates timers normally if they're using slowmo while having more than one stopwatch
	var alt_timestep = TIMESTEP * ((global.player_using_slowmo and has_charm(charms.stopwatch) > 1)? (1/(global.player_slowmo * 1.25)) : 1);

	// Basic movement
	var diagonal_mod = ((hinput == 0 or vinput == 0)? 1 : 1/SQRT2);
	var charging_teleport_mod = teleinput_hold? 0.6 : 1;
	var target_walk_spd = walk_spd * diagonal_mod * charging_teleport_mod;
	
	var charm_run_speed_multiplier = has_charm(charms.running_shoes)? 1.45 : 1;
	if has_charm(charms.running_shoes) > 1 charm_run_speed_multiplier = 1.85;
	var charm_teleport_cooldown_multiplier = has_charm(charms.adrenaline_on_a_stick)? teleport_adrenaline_cooldown_factor : 1;
	
	if (hinput != 0) {
		var accel = walk_accel;
		if hspd * hinput < 0 {
			accel = skid_accel;
		}
		hspd = lerp(hspd, hinput*target_walk_spd, accel);
	
	} else {
		hspd = lerp(hspd, 0, stop_spd);
	}


	if (vinput != 0) {
		var accel = walk_accel;
		if vspd * vinput < 0 {
			accel = skid_accel;
		}
		vspd = lerp(vspd, vinput*target_walk_spd, walk_accel);
	} else {
		vspd = lerp(vspd, 0, stop_spd);
	}

	

	// Teleporting
	var targ = get_teleport_target();
	var has_valid_spot = !place_meeting(targ.x, targ.y, o_collision_basic);
	if teleinput {	// walk along towards the player from the wall looking for the furthest valid spot
		if has_valid_spot {
			cur_teleport_target = targ;
		} else {
			
			// first nudge out with in-wall algorithm
			var new_targ = get_out_of_wall_ext(targ, 16, o_collision_basic, TILE_W*1.5, TILE_H*1.5);
			has_valid_spot = true;		//I realize taht this variable is redundant but don't want to go through removing it and risking that it ruins something else depending on it
			if is_point(new_targ) {
				cur_teleport_target = new_targ;
			} else {
				cur_teleport_target = new Point(x, y);
			}
			
		}
	}
	
	cursor_color = tele_lock? c_spark_dark : c_ltblue;
	//if tele_lock cursor_color = c_dkgray;

	// give appropriate charge if the charge initiation timer is finished
	if teleport_charge_start_timer <= 0 {
		effect_create_below(ef_spark, x + irandom_range(-1, 1), y + irandom_range(-1, 1), 0.25, c_spark);
		
		var charge_mult = has_charm(charms.big_balls) > 1? 1.6 : 1;
		teleport_charge = min(teleport_charge + (teleport_charge_increment * alt_timestep * charge_mult), teleport_charge_max);
	} else {
		teleport_charge = 0;
	}

	// do the actual teleport
	if has_valid_spot and teleinput {
		
		play_sound_random_pitch([snd_player_teleport_2]);
		
		global.lmb_release_buffer = 0;
		
		teleport_limit_timer = teleport_limit_time * charm_teleport_cooldown_multiplier;
		effect_create_below(ef_ring, x, y, 0.1, c_spark);
		var range = 12;
		var colors = [c_white, c_spark, c_spark_dark];
		make_sprite_FX_ext(x, y, spark_sprites, 1, map(0, 1, teleport_charge, 0.9, 1.5) * irandom_range(11, 15), 
							new Point(-range, -range), new Point(range, range), [-1, 1], [-1.5, 0.5], [0.8, 1], colors);

		var targ = cur_teleport_target;
		var dir = point_direction(x, y, targ.x, targ.y);
		
		if point_distance(x, y, cur_teleport_target.x, cur_teleport_target.y) >= minimum_assisted_teleport_range {
			var charge_scale = map(0, 1, teleport_charge, 1, 1.5);
			var deux_balls = has_charm(charms.deux_balls);
			if deux_balls {
				var perp = dir + 90;
				var offx = lengthdir_x(25, perp);
				var offy = lengthdir_y(25, perp);
			
				var shot = spawn_shot(x + offx, y + offy, o_bomb);
				var shotdir = point_direction(x + offx, y + offy, targ.x, targ.y);
				shot.hspd = lengthdir_x(bomb_shot_spd, shotdir);
				shot.vspd = lengthdir_y(bomb_shot_spd, shotdir);
				shot.life = -1;
				shot.image_xscale = charge_scale;
				shot.image_yscale = charge_scale;
				shot.can_graze_timer = -1;
			
				var shot2 = spawn_shot(x - offx, y - offy, o_bomb);
				shotdir = point_direction(x - offx, y - offy, targ.x, targ.y);
				shot2.hspd = lengthdir_x(bomb_shot_spd, shotdir);
				shot2.vspd = lengthdir_y(bomb_shot_spd, shotdir);
				shot2.life = -1;
				shot2.image_xscale = charge_scale;
				shot2.image_yscale = charge_scale;
				shot2.can_graze_timer = -1;
			}
			
			// we add the center ball back in if they don't have it OR
			// if they have 2 of them
			if deux_balls != 1 {			
				
				var shot = spawn_shot(x, y, o_bomb);
				shot.hspd = lengthdir_x(bomb_shot_spd, dir);
				shot.vspd = lengthdir_y(bomb_shot_spd, dir);
				shot.life = -1;
				shot.image_xscale = charge_scale;
				shot.image_yscale = charge_scale;
				shot.can_graze_timer = -1;
			}
		}
		// after-images
		var dis = point_distance(x, y, targ.x, targ.y);
		var images = floor(dis / after_image_dis);
		for (var i = 0; i < images; i++) {
			var t = i/images;
			var s = 1-t;
			var FX = new fade_FX((x*s) + (targ.x*t), (y*s) + (targ.y*t), sprite_index, -1, image_index, after_image_duration_base * i * 0.4);
			FX.alpha_factor = 1;
			FX.fog_col = merge_color(c_white, c_ltblue, s);
		}
		
		x = targ.x;
		y = targ.y;
		make_sprite_FX_ext(x, y, spark_sprites, 1, map(0, 1, teleport_charge, 0.9, 1.5) * irandom_range(7, 10), 
							new Point(-range, -range), new Point(range, range), [-1, 1], [-1.5, 0.5], [0.8, 1], colors);
		
	}
	
	// Interactables
	var list = ds_list_create();
	var interacts = collision_circle_list(x, y, 40, o_interact_parent, false, true, list, true);
	for (var i = 0; i < interacts; i++) {
		var cur = list[| i];

		var can_activate = true;
		if cur.able_to_interact_function != -1 {
			with(cur) {
				can_activate = able_to_interact_function();
				near = can_activate;
			}
		}
		if can_activate and cur.interact_function != -1 {
			with(cur){
				interact_function();
			}
		}
	}


	// Collision
	
	var h_col = instance_place(x + hspd, y, o_collision_basic);
	var hdir = sign(hspd);
	// likewise, the amount you can slip past corners vertically is dependent on your horizontal speed
	var vclip_test = 0;
	vclip_max = abs(hspd) * clip_factor;

	if h_col != noone {
		// First, nudge up or down to clip past wall if the edge is close enough
		
		// so long as you can continue trying and are still stuck, increment
		while (vclip_test < vclip_max and place_meeting(x + hspd, y + vclip_test, o_collision_basic)) {
			vclip_test++;
			// if the next iteration would push you into a wall vertically, kill this check altogether
			//if place_meeting(x + hspd, y + vclip_test + 1, o_collision_basic) {
				
			//}
		}
		// if you've gone as far as you can, try the other direction
		if vclip_test >= vclip_max {
			vclip_test = 0;
			while (vclip_test < vclip_max and place_meeting(x + hspd, y - vclip_test, o_collision_basic)) {
				vclip_test++;
				// if the next iteration would push you into a wall vertically, kill this check altogether
				//if place_meeting(x + hspd, y + vclip_test + 1, o_collision_basic) {
				
				//}
			}
			// if you've found way in this direction, then nudge over
			if vclip_test < vclip_max {
				y -= vclip_test;
			}
			// if not, then you just hit the wall
		} else {
			// otherwise, you've found a way to clip past and can move
			y += vclip_test;
		}
		
		// if you still couldn't find a way to clip past, be stopped 
		if vclip_test >= vclip_max {
			while !place_meeting(x + hdir, y, h_col) {
				x += hdir;
			}
		
			hspd = 0;
		}
	}

	x += hspd * alt_timestep * charm_run_speed_multiplier;


	var v_col = instance_place(x, y + vspd, o_collision_basic);
	var vdir = sign(vspd);
	// the amount you can slip past corners horizontally is dependent on your vertical speed
	var hclip_test = 0;
	hclip_max = abs(vspd) * clip_factor;

	if v_col != noone {
		// so long as you can continue trying and are still stuck, increment
		while (hclip_test < hclip_max and place_meeting(x + hclip_test, y + vspd, o_collision_basic)) {
			hclip_test++;
			// if the next iteration would push you into a wall vertically, kill this check altogether
			//if place_meeting(x + hspd, y + hclip_test + 1, o_collision_basic) {
				
			//}
		}
		// if you've gone as far as you can, try the other direction
		if hclip_test >= hclip_max {
			hclip_test = 0;
			while (hclip_test < hclip_max and place_meeting(x - hclip_test, y + vspd, o_collision_basic)) {
				hclip_test++;
				// if the next iteration would push you into a wall vertically, kill this check altogether
				//if place_meeting(x + hspd, y + hclip_test + 1, o_collision_basic) {
				
				//}
			}
			// if you've found way in this direction, then nudge over
			if hclip_test < hclip_max {
				x -= hclip_test;
			}
			// if not, then you just hit the wall
		} else {
			// otherwise, you've found a way to clip past and can move
			x += hclip_test;
		}
		
		// if you still couldn't find a way to clip past, be stopped 
		if hclip_test >= hclip_max {
			while !place_meeting(x, y + vdir, v_col) {
				y += vdir;
			}
		
			vspd = 0;
		}
	}

	y += vspd * alt_timestep * charm_run_speed_multiplier;

	//Correction
	get_out_of_wall(8);
	
	
	// Sprites
	
	switch (cur_action) {
		case player_action.none:
			if (hinput == 0 and vinput == 0) or (hspd == 0 and vspd == 0) {
				set_sprite(spr_player_idle);
			} else {
				set_sprite(spr_player_walk);
				var diff = 0.08;
				if is_between(image_index, 1.2, 1.2 + diff) or is_between(image_index, 3.2, 3.2 + diff) {
					if !audio_is_playing(snd_player_walk) {
						var snd = play_sound_random_master([snd_player_walk], 2);
						set_SFX_sound_gain(snd);
					}
				}
			}
			
			
		break;
		
		case player_action.death:
			hold_sprite(spr_player_death);
			
			hinput_lock = true;
			vinput_lock = true;
			tele_lock = true;
			
			// @GLOBAL PLAYER DEATH, DIES
			
			if action_timer <= 1 {
				if room != rm_tutorial {
					global.game_state = game.end_review;
					global.paused_this_frame = true;
					invinciblility_timer = 2;	// guard for time between deactivation
				} else {
					o_camera.fade_timer = 40;
					o_camera.fade = 0;
					hp = hpmax;
					draw_tutorial_banter_timer = 3 * SECOND;
					
					global.death_animation = false;	// in this case we're just resetting the player
				}
			}
			
		break;
		
		case player_action.enter_gate:
			invinciblility_timer = 2;
			var done = hold_sprite(spr_player_death);	//spr_player_enter_portal
		
			hinput_lock = true;
			vinput_lock = true;
			tele_lock = true;
			
			if done {
				cur_action = player_action.enter_gate_ball;
				action_timer = ball_form_time;
				global.transition_timer = action_timer;
				global.death_transition_duration = action_timer;
				global.transition_curve = "cv_animation_exit_gate_transition";
				//with (o_camera) {
				//	follow = o_exit_gate;
				//}
			}
			
		break;
		
		case player_action.enter_gate_ball:
		
			// @GLOBAL GO TO NEXT FLOOR
			
			invinciblility_timer = 2;
			hinput_lock = true;
			vinput_lock = true;
			tele_lock = true;
		
			if action_timer <= 1 {
				global.game_state = game.review;
				global.paused_this_frame = true;
				global.floors_cleared++;
				global.money += floor(((global.floors_cleared+1) ^ 1.5) * 3);
	
				global.difficulty = min(global.difficulty_max, global.difficulty + 1);
				global.player_max_hp = o_player.hpmax;
				global.player_hp = o_player.hp;
				global.player_temp_hp = o_player.temp_hp;
				global.deactivated_hearts = o_player.deactivated_hearts;
				

				invinciblility_timer = 2;	// guard for time between deactivation
			}
		
		break;
	}
	
	action_timer -= alt_timestep * (action_timer > 0);
	if action_timer <= 0 {
		hinput_lock =	false;
		vinput_lock =	false;
		tele_lock =		false;
		
		cur_action = player_action.none;
	}
	 
	// Set-up timers
	tele_lock = teleport_limit_timer > 0;
	teleport_limit_timer -= alt_timestep * (tele_lock);
	
	if teleinput_hold and can_charge {
		teleport_charge_start_timer -= alt_timestep;
	
		// increase range as you charge
		teleport_max_range = teleport_max_range_base * map(0, 1, teleport_charge, 1, teleport_max_range_charge_factor);
	} else {
		// if not holding, reset the time and maximum range
		teleport_charge_start_timer = teleport_charge_start_time;
		teleport_max_range = teleport_max_range_base;
	}
	
	if has_charm(charms.adrenaline_on_a_stick) {
		if has_charm(charms.adrenaline_on_a_stick) == 1 {	
			teleport_max_range *= teleport_max_range_adrenaline_factor;
		} else {
			teleport_max_range *= teleport_max_range_adrenaline_2_charms_factor;
		}
	}
	
	
	if hp - deactivated_hearts <= 0 and cur_action != player_action.death and global.game_state == game.playing {
		cur_action = player_action.death;
		action_timer = death_transition_duration;
		invinciblility_timer = -1;
		global.death_animation = true;
		global.transition_timer = death_transition_duration;
		global.death_transition_duration = death_transition_duration;
		global.transition_curve = "cv_animation_death";
		
		audio_stop_all();
		var snd = audio_play_sound(snd_lose, 5, false);
		set_SFX_sound_gain(snd);
	}
	
}

function player_draw() {
	
	var xx = round(x);
	var yy = round(y);
	var mx = MX;
	var my = MY;

	var ball_form = cur_action == player_action.enter_gate_ball;
	var base_alpha = 0.2;
	var col = c_white;
	
	draw_set_circle_precision(32);
	
	// draw debug hit-graze radius
	if global.debug {
		var has_horns = has_charm(charms.devils_horns);
		var horn_mult = has_horns > 1? devil_horns_dup_range_bonus : 1;
		draw_set_color(c_white);
		draw_circle(x, y + graze_offset_y, graze_radius * horn_mult, true);
	}
	
	var tutorial_teleport_draw = (room != rm_tutorial or (room == rm_tutorial and global.tutorial_player_teleport_active));
	if !global.death_animation and !global.entering_gate and tutorial_teleport_draw {
		var teleport_targ = get_teleport_target(); 
		var teleport_alpha = clamp(base_alpha + teleport_charge, 0, 0.8);

		draw_set_alpha(teleport_alpha);
		draw_set_color(cursor_color);
		draw_circle(xx, yy, teleport_max_range, true);
		draw_line(xx, yy, teleport_targ.x, teleport_targ.y);
		draw_circle(teleport_targ.x, teleport_targ.y, 12, true);

		draw_set_alpha(1);
	}
	
	if !ball_form {
		draw_sprite_ext(sprite_index, image_index, xx, yy, image_xscale, image_yscale,
						image_angle, col, image_alpha);
	} else {
		var r = 8 + sin(current_time/100);
		var maxHeight = 40;
		var percent = map(0, ball_form_time, action_timer, 0, 1);
		// get a "percent of full radius" amount by using the percent
		var curve = animcurve_get_channel(AnimationCurve1, "cv_animation_ball");
		var z = maxHeight * animcurve_channel_evaluate(curve, percent);
		var ball = new Point(lerp(o_exit_gate.x, x, percent), lerp(o_exit_gate.y - 12, y, percent) - z);
		
		draw_set_color(c_player_blue);
		draw_circle(ball.x, ball.y, r, false);
		draw_set_color(c_white);
		draw_circle(ball.x, ball.y, r, true);
		
		if action_timer % 4 == 0 {
			var FX = new fade_FX(ball.x, ball.y, effects.circle, -1, 0, 3);
			FX.width = r;
			FX.image_blend = c_white;
		}
	}
		
	// draw debug movement clip allowance range
	if global.debug {
		draw_set_alpha(0.4);
		draw_set_color(c_red);
		draw_rectangle(	bbox_left + (vspd != 0? hclip_max : 0), bbox_top + (hspd != 0? vclip_max : 0),
						bbox_right - (vspd != 0? hclip_max : 0), bbox_bottom - (hspd != 0? vclip_max : 0), false);
		draw_set_alpha(1);
		draw_set_color(c_white);
	}	
	
}
	
function tutorial_draw() {
	
	draw_set(fnt_HUD_medium, fa_center, fa_center, c_white);
	draw_set_alpha(1);
	
	var sep = string_height("A");
	draw_text_ext(room_width/2, room_height/2, global.tutorial_text, sep, room_width/5);
	
	draw_tutorial_banter_timer -= TIMESTEP;
	if draw_tutorial_banter_timer > 0 {
		draw_set(fnt_HUD_small, fa_center, fa_center, c_white);
		var sep = string_height("A");
		var w = 80;
		var h = sep * 3;
		var cx = RX;
		var cy = RY - 30 - h;
		
		draw_set_color(c_black);
		draw_roundrect(cx - w/2, cy - h/2, cx + w/2, cy + h/2, false); 
		
		draw_set_color(c_white);
		draw_roundrect(cx - w/2, cy - h/2, cx + w/2, cy + h/2, true);
		
		draw_text_ext(cx, cy, "This is the tutorial... Don't go dying now...", sep, w);
	}

}