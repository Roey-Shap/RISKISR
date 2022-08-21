/// @description


// Management keys

var unpause = false;
global.paused_this_frame = false;
global.left_click_locked = false

if !global.left_click_locked global.lmb_buffer -= TIMESTEP * LMB_PRESS;
global.lmb_release_buffer -= TIMESTEP * LMB_RELEASE;
global.rmb_buffer -= TIMESTEP * (global.rmb_buffer > 0);

if mouse_check_button_pressed(mb_left) {
	global.lmb_buffer = global.mouse_buffer_time;
}
if mouse_check_button_released(mb_left) {
	global.lmb_release_buffer = global.mouse_buffer_time;
}

if mouse_check_button_pressed(mb_right) {
	global.rmb_buffer = global.mouse_buffer_time;
}

// Surfaces
if !surface_exists(global.layer_shapes) {
	global.layer_shapes = surface_create(SCREEN_W, SCREEN_W);
}




if DEVELOPER_MODE {
	if keyboard_check_pressed(vk_tab) global.debug = !global.debug;
	if keyboard_check_pressed(ord("R")) game_restart();
}


if ds_exists(global.sprite_FX_list, ds_type_list) {
	for (var i = 0; i < ds_list_size(global.sprite_FX_list); i++) {
		var cur = global.sprite_FX_list[| i];
		if (is_fade_FX(cur)) cur.update_alpha();
		// if one died this frame then move i backwards one to account for that
		i -= (cur.step());

	}
}

switch (global.game_state) {
	
	case game.main_menu:
	
		if instance_exists(o_collision_basic) {
			destroy_non_meta();
		}
		do_menu_object_step(global.main_menu);
		if keyboard_check_pressed(vk_escape) safe_close_game();
	break;
	
	//case game.options:
	//	do_menu_object_step(global.options);
	//break;
	
	#region playing state
	case game.playing:	
	
	
		// Achievements
		
		global.current_run_time += 1;		// something something fps_real... don't care THAT much
		
		if room != rm_tutorial {
			if global.money >= 250 and global.current_run_time < global.best_250_money_time {
				global.best_250_money_time = global.current_time;
			}
			global.best_kill_count = max(global.best_kill_count, global.current_kill_count);
			global.best_floors = max(global.best_floors, global.floors_cleared+1);
			global.best_money = max(global.best_money, global.money);
		}		
		
		// Pausing
		global.enemy_find_target_timer -= TIMESTEP;
		
		if keyboard_check_pressed(vk_escape) and !global.death_animation {
			global.game_state = game.paused;
			global.paused_this_frame = true;
			if !surface_exists(global.pause_surf) {
				global.pause_surf = surface_create(SCREEN_W, SCREEN_H);
			}
			global.pause_sprite = sprite_create_from_surface(global.pause_surf, 0, 0, CAM_W, CAM_H, false, false, 0, 0);
			
			break;
		}

		// Update game speed
		global.player_using_slowmo = using_ability(charms.stopwatch) and !global.death_animation and !(global.transition_timer > 0);
		if global.player_using_slowmo {
			global.timeDelta = global.player_slowmo;
		} else {
			global.timeDelta = 1;
		}
		
		var using_HOG = using_ability_pressed(charms.heart_of_gold);
		if using_HOG {
			with (o_player) {
				if global.money >= global.money_needed_for_heart_of_gold {
					//if global.money <= global.money_needed_for_heart_of_gold*3 {	
					//	global.money -= global.money_needed_for_heart_of_gold;
					//} else {
					//	global.money *= 2/3;
					//}
					global.money -= global.money_needed_for_heart_of_gold;
					if using_HOG > 1 {
						global.heart_of_gold_2_uses--;
					
						if global.heart_of_gold_2_uses <= 0 {
							global.player_charm_2 = charms.none;
						
							make_sprite_FX_ext(global.GUI_pic2.x, global.GUI_pic2.y, global.circle_sprites, 10, irandom_range(12, 15), 
												new Point(-5, 0), new Point(5, 5), [-1.5, 1.5], [-1, 2], [0.8, 1], [c_ltgray, c_gray, c_spark]);
						}
					} else {
						global.heart_of_gold_uses--;
						if global.heart_of_gold_uses <= 0 {
							// if they have 1 charm, this'll scootch 2 over to 1 and erase 2
							// if they have 2 charms, this'll scootch 2's EMPTINESS over to 1 and erase it needlessly
							if global.player_charm == charms.heart_of_gold {
								global.player_charm = global.player_charm_2;
								global.heart_of_gold_uses = global.heart_of_gold_2_uses;
							
								make_sprite_FX_ext((global.GUI_pic.x + global.GUI_pic2.x)/2, (global.GUI_pic.y + global.GUI_pic2.y)/2, global.circle_sprites, 10, irandom_range(12, 15), 
												new Point(-5, 0), new Point(5, 5), [-1.5, 1.5], [-1, 2], [0.8, 1], [c_ltgray, c_gray, c_spark]);
							}
							global.player_charm_2 = charms.none;
							global.heart_of_gold_2_uses = 0;	// if it wasn't already... for some reason
						}
					}
					
					var hp_pickup = instance_create_layer(x, y, LAYER_UNDER, o_health_temp_pickup);
				
					var ang = irandom(359);
					hp_pickup.hspd = lengthdir_x(3.5, ang);
					hp_pickup.vspd = lengthdir_y(3.5, ang);
				} else if global.money_flash_timer <= 0 {
					global.money_flash_timer = global.not_enough_money_for_heart_of_gold_duration;
				}
			}
		}

		// Update structs
		if ds_exists(global.hitboxes, ds_type_list) {
			for (var i = 0; i < ds_list_size(global.hitboxes); i++) {
				var cur = global.hitboxes[| i];
				// if one died this frame then move i backwards one to account for that
				i -= (cur.step());
			}
		}



		// Gameplay
		
		
		// Tutorial
		
		// run a custom function that checks for certain conditions to be met to continue the tutorial
		if tutorial_function != -1 {
			if tutorial_function() {
				tutorial_function = -1;
				
				global.tutorial_function_index++;
				// run the next function
				exec(global.tutorial_functions[global.tutorial_function_index]);
			}
		}
		
		
			// Charms
		var mp = get_mouse_pos();
		
		global.hovering_over_linker = in_rectangle(mp.x, mp.y, global.linker_FX.x - (global.linker_FX.width/2) + 1, global.linker_FX.y + 1,
										global.linker_FX.x + (global.linker_FX.width/2), global.linker_FX.y + global.linker_FX.height);
		global.hovering_over_charm_1 = in_rectangle(mp.x, mp.y, global.GUI_pic.x, global.GUI_pic.y, global.GUI_pic.x + 40, global.GUI_pic.y + 40);
		global.hovering_over_charm_2 = in_rectangle(mp.x, mp.y, global.GUI_pic2.x, global.GUI_pic2.y, global.GUI_pic2.x + 40, global.GUI_pic2.y + 40);
		if global.hovering_over_linker {
			//if global.player_charm_amount > 1 {
			//	global.player_must_release_lmb = true;		// prevent accidental teleport
			//}
			global.hovering_over_linker_timer += 1;//TIMESTEP;
		} else global.hovering_over_linker_timer = 0;
		
		if global.hovering_over_charm_1 {
			//global.player_must_release_lmb = true;		// prevent accidental teleport
			global.hovering_over_charm_1_timer += 1;//TIMESTEP;
		} else global.hovering_over_charm_1_timer = 0;
		
		if global.hovering_over_charm_2 {
			//global.player_must_release_lmb = true;		// prevent accidental teleport
			global.hovering_over_charm_2_timer += 1;//TIMESTEP;
		} else global.hovering_over_charm_2_timer = 0;

		
		// removing charms or the Linker
		var double_clicked = RMB_PRESS and mouse_check_button_pressed(mb_right);
		if double_clicked and instance_exists(o_player) {
			var px = o_player.x;
			var py = o_player.y;
			var charm_spd = 3;
			
			if global.player_charm_amount > 1 and global.hovering_over_linker {
				global.player_charm_amount = 1;
				with (o_player) {
					deactivated_hearts--;
				}
				
				if global.player_charm_2 != charms.none {
					var dir = irandom(359);
					var charm = instance_create_layer(px, py, LAYER_UNDER, o_charm);
					charm.charm_type = global.player_charm_2;
					charm.hspd = lengthdir_x(charm_spd, dir);
					charm.vspd = lengthdir_y(charm_spd, dir);
					global.player_charm_2 = charms.none;
					global.heart_of_gold_2_uses = 0;
				}
				
				var p = global.linker_FX;
				repeat(2) {
					make_sprite_FX_ext(p.x, p.y, global.circle_sprites, 10, irandom_range(12, 15), 
											new Point(-5, 0), new Point(5, 5), [-1.5, 1.5], [-1, 2], [0.8, 1], [c_white, c_ltgray, c_gray, c_black]);
					p = new Point(global.GUI_pic2.x + 20, global.GUI_pic2.y + 10);
				}
			} else {
				// don't risk overlap of button presses
			
				if global.hovering_over_charm_1 {
					if global.player_charm != charms.none {					
						var dir = irandom(359);
						var charm = instance_create_layer(px, py, LAYER_UNDER, o_charm);
						charm.charm_type = global.player_charm;
						charm.hspd = lengthdir_x(charm_spd, dir);
						charm.vspd = lengthdir_y(charm_spd, dir);
						charm.uses = global.heart_of_gold_uses;
					}
				
					global.player_charm = global.player_charm_2;
					global.heart_of_gold_uses = global.heart_of_gold_2_uses;
					
					global.player_charm_2 = charms.none;
					global.heart_of_gold_2_uses = 0;
					
				} else if global.hovering_over_charm_2 {
					if global.player_charm_2 != charms.none and global.player_charm_amount > 1 {
						var dir = irandom(359);
						var charm = instance_create_layer(px, py, LAYER_UNDER, o_charm);
						charm.charm_type = global.player_charm_2;
						charm.hspd = lengthdir_x(charm_spd, dir);
						charm.vspd = lengthdir_y(charm_spd, dir);
						charm.uses = global.heart_of_gold_2_uses;
					}
				
					global.player_charm_2 = charms.none;
					global.heart_of_gold_2_uses = 0;
				}
			}
		}

		// Countdown timer for falling rocks
		if COUNTDOWN <= 0 {
			if COUNTDOWN != -1 and false {
				show_message("Death!");
			}
			if COUNTDOWN == -1 {
				if audio_is_playing(snd_rocks_crumbling_loop_1) {
					audio_stop_sound(snd_rocks_crumbling_loop_1);
				}
			}
			
		} else {
			
			
			// loops in current design!!
			
			if COUNTDOWN <= 2 COUNTDOWN = global.countdown_time_init;
			
			// !!!!
			
			
			if !audio_is_playing(snd_rocks_crumbling_loop_1) {
				play_sound_random_master([snd_rocks_crumbling_loop_1], 5);
			}
			global.opened_gate = true;
			COUNTDOWN -= TIMESTEP;
			ROCK_TIMER -= TIMESTEP;
			if ROCK_TIMER <= 0 {
				// reset timer
				ROCK_TIMER = floor(map(global.difficulty_min, global.difficulty_max, global.difficulty, 3.5 * SECOND, 1 * SECOND) * random_range(0.85, 1.2));
				// spawn a rock
				var ran_x = CAM_X + floor(((CAM_W/2) * random_range(-0.4, 0.4)));
				var ran_y = CAM_Y + floor(((CAM_H/2) * random_range(-0.4, 0.4)));
		
				var rock = instance_create_layer(ran_x, ran_y, LAYER_BULLET, o_bomb);
				rock.z = -global.spawn_falling_object_height;
			}
		}
		
	break;
	#endregion
	
	case game.paused:
		if keyboard_check_pressed(vk_escape) {
			unpause = true;
		} else {
			do_menu_object_step(global.pause_menu);
		}
	break;
	
	case game.controls:
		if keyboard_check_pressed(vk_escape) {
			global.game_state = global.return_state;
		}
	break;
	
	case game.backstory:
		if keyboard_check_pressed(vk_escape) {
			global.game_state = global.return_state;
		}
	break;
	
	case game.records:
		if keyboard_check_pressed(vk_escape) {
			global.game_state = global.return_state;
		}
	break;
	
	case game.explanation:
		var hinput = keyboard_check_pressed(ord("D")) - keyboard_check_pressed(ord("A"));
		if global.tutorial_page + hinput < 0 global.tutorial_page = sprite_get_number(spr_tutorial_updated) - 1;
		else global.tutorial_page = (global.tutorial_page + hinput) % sprite_get_number(spr_tutorial_updated);
		if keyboard_check_pressed(vk_escape) {
			global.game_state = global.return_state;
		}
	break;
	
	case game.review:
		do_menu_object_step(global.review_menu);
	break;
	
	case game.end_review:
		do_menu_object_step(global.end_review_menu);
	break;
	
}

if global.game_state != game.playing {
	if audio_is_playing(snd_rocks_crumbling_loop_1) {
		audio_stop_sound(snd_rocks_crumbling_loop_1);		
	}
}

if unpause {
	global.pause_menu.resume_button.clicked_function();
}









