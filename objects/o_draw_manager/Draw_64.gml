/// @description

switch (global.game_state) {
	case game.main_menu:
		var mid = new Point(SCREEN_W/2, SCREEN_H * 0.2);
		
		var chance = 40;
		if irandom(chance - 1) == 0 {
			var w_range = (title_w/2) * 1.05;
			var h_range = (title_h/2) * 1.05;
			make_sprite_FX_ext(irandom_range(mid.x - w_range, mid.x + w_range), irandom_range(mid.y - h_range, mid.y + h_range), global.circle_sprites,
								10, 1, new Point(0, 0), new Point(0, 0), [0, 0], [-1, -0.25], [0.6, 1], [c_player_blue, c_ltblue, c_spark, c_spark_dark]);
		}
		var offset = 2 * sin(current_time/200);
		title_x1_off = offset * sin(current_time/300);
		title_y1_off = offset * sin(current_time/350);
		title_x2_off = offset * sin(current_time/400);
		title_y2_off = offset * sin(current_time/450);
		title_x3_off = offset * sin(current_time/500);
		title_y3_off = offset * sin(current_time/550);
		title_x4_off = offset * sin(current_time/600);
		title_y4_off = offset * sin(current_time/650);
		

		draw_sprite_pos(spr_RISKISR, 0, mid.x - (title_w/2) + title_x1_off, mid.y - (title_h/2) + title_y1_off,
										mid.x + (title_w/2) + title_x2_off, mid.y - (title_h/2) + title_y2_off,
										mid.x + (title_w/2) + title_x3_off, mid.y + (title_h/2) + title_y3_off,
										mid.x - (title_w/2) + title_x4_off, mid.y + (title_h/2) + title_y4_off, 1);
		
		draw_set(fnt_GUI, fa_center, fa_center, c_white);
		draw_text(mid.x, SCREEN_H - floor(string_height("A")*3/4), "By Roey Shapiro, October 2021");
	
		draw_menu_object(global.main_menu);
	break;
	
	case game.playing:
		
		if !global.tutorial_HUD_active and room == rm_tutorial {
			break;
		}
		
		// Overlays
		
		var player_hurt = false;
		with (o_player) {
			player_hurt = state == stun_state.stun;
		}
		if COUNTDOWN > 0 or player_hurt {
			var a = map(-1, 1, sin(COUNTDOWN/50), 0, 0.35);
			if player_hurt and COUNTDOWN <= 0 a = 0.05;		// limit alpha if it shouldn't already be lit by the UNSTABLE sequence 
			
			draw_set_color(c_hurt);
			draw_set_alpha(a);
			draw_rectangle(0, 0, CAM_W, CAM_H, false);
	
			draw_set_alpha(1);
			draw_set_color(c_white);
		}
		var using_stopwatch = using_ability(charms.stopwatch);
		if using_stopwatch {
			surface_set_target(global.layer_shapes);
			draw_clear_alpha(c_black, 0);
			
			var dup_charm = has_duplicate_charm();
			var color = dup_charm? c_spark_dark : c_spark;
			var stopwatch_a = dup_charm? 0.9 : 0.775;
			var levels = 8;
			var radius_mult = 1.12 * map(-1, 1, sin(current_time/600), 0.95, 1);
			var total_width = (SCREEN_W/2) * radius_mult;
			var total_height = (SCREEN_H/2) * radius_mult;
			var center_x = SCREEN_W/2;
			var center_y = SCREEN_H/2;
			
			draw_set_color(c_white);
			draw_rectangle(0, 0, SCREEN_W, SCREEN_H, false);
			
			gpu_set_blendmode(bm_subtract);
			
			draw_set_color(c_black);
			
			draw_set_circle_precision(64);
			for (var i = 0; i < levels; i++) {
				var inverse_percent = (levels - 1 - i)/levels;
				var width = floor(total_width * inverse_percent);
				var height = floor(total_height * inverse_percent);
				draw_set_alpha(inverse_percent);
				draw_ellipse(center_x - width, center_y - height, center_x + width, center_y + height, false);
			}
			
			draw_set_circle_precision(24);
			gpu_set_blendmode(bm_normal);
			
			draw_set_alpha(1);
			surface_reset_target();
			draw_surface_ext(global.layer_shapes, 0, 0, 1, 1, 0, color, stopwatch_a);
		}
		
		
		// Charm information
			
		var HUD		= global.GUI_HUD;
		var gui_hp	= global.GUI_hp;
		var money	= global.GUI_money;
		var pic		= global.GUI_pic;
		var pic2	= global.GUI_pic2;
		var name	= global.GUI_name;
		var desc	= global.GUI_desc;
		var HUD_min_alpha = 0.2;
		
		var duplicate_charm = has_duplicate_charm();
		
		var hud_interferers = [o_hit_parent, o_bullet_parent, o_activation_module];
		
		player_under_HUD_alpha = lerp(other.player_under_HUD_alpha, 1, 0.1);
		for (var i = 0; i < array_length(hud_interferers); i++) {
			with (hud_interferers[i]) {
				if in_rectangle(get_gui_x(x), get_gui_y(y), 0, 0, 200, 110) {
					other.player_under_HUD_alpha = lerp(other.player_under_HUD_alpha, HUD_min_alpha, 0.1);
				}
			}
		}
		
		draw_set_alpha(player_under_HUD_alpha);
		
		// HUD base
		draw_sprite_ext(spr_player_HUD, 0, HUD.x, HUD.y, 1, 1, 0, c_white, player_under_HUD_alpha);
				
		// HP
		var len = 16, margin = 5;
		with (o_player) {
			var alpha = 1 * other.player_under_HUD_alpha;
						
			for (var i = 0; i < hpmax; i++) {
				var hpx = gui_hp.x + (len * (i+1)) + (margin*(i));
				var hpy = gui_hp.y;
				
				var add_x = 0;
				var add_y = 0;
				var col = c_dkblue;
				var col_BG = merge_color(c_spark, c_spark_dark, 0.2);
				var deac_heart = i < deactivated_hearts;
				var removed_heart = i >= hp and i < hp + hit_effect_hp_add;
				var hp_alpha = alpha;
				
				// decide whether to draw a normal heart or a vacant one
				var filled_heart = i < hp;
				if filled_heart {
					if deac_heart {
						var cur_a = draw_get_alpha();
						draw_set_alpha(cur_a * 3);
						draw_sprite_ext(spr_player_hp_node_cross, 0, hpx, hpy, 1, 1, 0, c_white, draw_get_alpha());
						draw_set_alpha(cur_a);
						var col = c_dkgray;
						var col_BG = c_ltgray;
					}
					draw_sprite_ext(spr_player_hp_node, 0, hpx+1, hpy+1, 1, 1, 0, col_BG, hp_alpha);
					draw_sprite_ext(spr_player_hp_node, 0, hpx, hpy, 1, 1, 0, col, hp_alpha);
					
				} else {
					var col = deac_heart? c_gray : c_white;
					//if !deac_heart draw_sprite_ext(spr_player_hp_node, 0, hpx, hpy, 1, 1, 0, col, alpha * 0.35);
					draw_sprite_ext(spr_player_hp_node_outline, 0, hpx, hpy, 1, 1, 0, col, alpha);
					if deac_heart {
						var cur_a = draw_get_alpha();
						draw_set_alpha(cur_a * 3);
						draw_sprite_ext(spr_player_hp_node_cross, 0, hpx, hpy, 1, 1, 0, col, draw_get_alpha());
						draw_set_alpha(cur_a);
					}
				}
				
				
				// Hit effects
				
				if hit_effect_timer > 0 and removed_heart {
					add_x = irandom_range(-5, 5);
					add_y = irandom_range(-5, 5);
					col = c_white;
					col_BG = c_flame;
					hp_alpha *= map(hit_effect_duration, 0, hit_effect_timer, 1, 0.4);
					var spd = 1.5;
					if irandom(2) == 0 make_sprite_FX_master(hpx, hpy, global.circle_sprites, 10, choose(1, 2), 
										new Point(-1, -1), new Point(1, 1), [-spd, spd], [-spd, 0], [0.85, 1.05], [c_white, c_flame, c_lime, c_hotpink], 0.99, 0.12);
										
					draw_sprite_ext(spr_player_hp_node, 0, hpx+1 + add_x, hpy+1 + add_y, 1, 1, 0, col_BG, hp_alpha);
					draw_sprite_ext(spr_player_hp_node, 0, hpx + add_x, hpy + add_y, 1, 1, 0, col, hp_alpha);
				}
				
			}
			
			var temp_hp_init_p = new Point(gui_hp.x + (len * hpmax) + (margin*(hpmax-1+1)), gui_hp.y);
			for (var i = 0; i < temp_hp; i++) {
				var hpx = temp_hp_init_p.x + (len * (i+1)) + (margin*(i));
				var hpy = temp_hp_init_p.y;
				
				draw_sprite_ext(spr_player_hp_node, 0, hpx+1, hpy+1, 1, 1, 0, merge_color(c_black, c_spark_dark, 0.8), alpha);
				draw_sprite_ext(spr_player_hp_node, 0, hpx, hpy, 1, 1, 0, merge_color(c_white, c_spark, 0.4), alpha);
			}
		}


		draw_set(fnt_GUI, fa_center, fa_center, c_white);
		
		// Money
		if global.money_flash_timer > 0 and is_between(global.money_flash_timer % 8, 0, 4) {
			draw_text_transformed(money.x+1, money.y+1, string(global.money), 1, 1, 0);
			draw_set_color(c_hurt);
		}
		draw_text_transformed(money.x, money.y, string(global.money), 1, 1, 0);
		draw_set_color(c_white);
		
		// Charm
		
		// note the use of 'global.heart_of_gold_uses' despite not knowing what charm they have:
		// this is because no charms use more than one image_index except this one
		var charm_info = global.charm_info[global.player_charm];
		draw_sprite(spr_charm_slot, 0, pic.x, pic.y);
		draw_sprite(charm_info[0], 3 - global.heart_of_gold_uses, pic.x + 20, pic.y + 20);
		
		if global.player_charm_amount == 2 {
			var charm_info = global.charm_info[global.player_charm_2];
			draw_sprite(spr_charm_slot, 0, pic2.x, pic2.y);
			draw_sprite(charm_info[0], 3 - global.heart_of_gold_2_uses, pic2.x + 20, pic2.y + 20);
			
			global.linker_FX.image_alpha = alpha;
			global.linker_FX.image_index = duplicate_charm;
			global.linker_FX.draw();
		}
		
		draw_set_font(fnt_HUD_small);
		
		draw_set_alpha(1);
		
		var mp = get_mouse_pos();
		var draw_charm = -1
		var tooltip_title = "";
		var tooltip = "";
		var tooltip_pos = -1;
		var usage_button = "LSHIFT";
		var info = -1;
		if global.hovering_over_charm_1_timer >= global.tooltip_hover_min_time {
			draw_charm = global.player_charm;
			tooltip_pos = new Point(global.GUI_pic.x, global.GUI_pic.y + 40);
		}
		if global.hovering_over_charm_2_timer >= global.tooltip_hover_min_time {
			draw_charm = global.player_charm_2;
			tooltip_pos = new Point(global.GUI_pic2.x, global.GUI_pic2.y + 40);
			usage_button = "SPACE";
		}		
		if global.hovering_over_linker_timer >= global.tooltip_hover_min_time and global.player_charm_amount > 1 {
			draw_charm = charms.linker;
			tooltip_pos = mp;
		}
		
		var dup = has_duplicate_charm();
		if dup {
			// defaults to flushing this new longer description to the left
			tooltip_pos = new Point(global.GUI_pic.x, global.GUI_pic.y + 40);
		}
		
		if draw_charm != -1 {
			draw_set(fnt_HUD_small, fa_center, fa_center, c_white);
			info = global.charm_info[draw_charm];
			tooltip_title = info[1];
			tooltip = info[2];
			if dup and info[3] != "" {
				tooltip += "\n\nSAME CHARM BONUS:\n" + info[3];
			}
			var sep = string_height("A");
			var title_buffer = sep/2;
			var title_to_text_buffer = sep;
			
			var tip_width_max = 40 * 2.5;
			mp.clamp_to_rectangle(0, 0, SCREEN_W/2, SCREEN_H/2);
			
			var tip_width = string_width_ext(tooltip, sep, tip_width_max);//max(, string_width_ext(usage_button, sep, tip_width_max));
			var tip_height = string_height_ext(tooltip, sep, tip_width_max) + title_buffer + title_to_text_buffer;
			var tip_center = tooltip_pos.x + (tip_width/2);
			
			draw_set_color(c_black);
			draw_rectangle(tooltip_pos.x, tooltip_pos.y, tooltip_pos.x + tip_width, tooltip_pos.y + tip_height, false);
			draw_set_color(c_white);
			draw_rectangle(tooltip_pos.x, tooltip_pos.y, tooltip_pos.x + tip_width, tooltip_pos.y + tip_height, true);
			
			draw_text_ext(tip_center, tooltip_pos.y + title_buffer, tooltip_title, sep, tip_width_max);
//			draw_text_ext(tip_center, tooltip_pos.y + title_buffer + title_to_text_buffer, "Press " + usage_button + " to use", sep, tip_width_max);
			
			
			draw_set_valign(fa_top);
			
			draw_text_ext(tip_center, tooltip_pos.y + title_buffer + title_to_text_buffer, tooltip, sep, tip_width_max);
		}
		
		
		
		// Minimap
		if ds_exists(global.floor_grid, ds_type_grid) and is_point(global.floor_top_corner) {	
			
		var room_cell_w = round(map(2, global.total_floor_w, global.spawned_room_width, 3, 1)) * 8;
		var room_cell_h = round(map(2, global.total_floor_h, global.spawned_room_height, 3, 1)) * 5;
		var buffer = 2;
		
		var add_mystery_buffer_x = (global.spawned_room_width < 3)? 2 : 0;
		var add_mystery_buffer_y = (global.spawned_room_height < 3)? 2 : 0;
		
		var tot_rooms_w = min(global.spawned_room_width + add_mystery_buffer_x, global.total_floor_w);
		var tot_rooms_h = min(global.spawned_room_height + add_mystery_buffer_y, global.total_floor_h);
		var add_to_w = add_mystery_buffer_x > 0;
		var add_to_h = add_mystery_buffer_y > 0;
		
		var total_minimap_HUD_width = (room_cell_w + buffer) * tot_rooms_w;
		var total_minimap_HUD_height = (room_cell_h + buffer) * tot_rooms_h;
		var minimap_corner_x = SCREEN_W - total_minimap_HUD_width - buffer*2;
		var minimap_corner_y = buffer*2;
		
		var player_in_room_col = c_player_blue;
		var filled_room_col = c_dkblue;
		var empty_room_col = merge_color(c_white, c_black, 0.95);
		var player_border_col = c_spark_dark;
		var border_col = c_white;
		var minimap_BG_col = merge_color(c_white, c_black, 0.9);
		 
		var player_room_x = 0, player_room_y = 0;
		with (o_player) {
			player_room_x = (x div ROOM_W) + add_to_w;
			player_room_y = (y div ROOM_H) + add_to_h;
		}
		player_under_minimap_alpha = lerp(player_under_minimap_alpha, 1, 0.1);
		for (var i = 0; i < array_length(hud_interferers); i++) {
			with (hud_interferers[i]) {
				if in_rectangle(get_gui_x(x), get_gui_y(y), SCREEN_W - minimap_corner_x, 0, SCREEN_W, minimap_corner_y + total_minimap_HUD_height) {
					other.player_under_minimap_alpha = lerp(other.player_under_minimap_alpha, HUD_min_alpha, 0.1);
				}
			}
		}

		
		draw_set_alpha(0.5 * player_under_minimap_alpha);
		draw_set_color(minimap_BG_col);
		draw_roundrect(minimap_corner_x - buffer*2, minimap_corner_y - buffer*2, 
						minimap_corner_x + total_minimap_HUD_width, minimap_corner_y + total_minimap_HUD_height, false);
						
		draw_set_alpha(player_under_minimap_alpha);
		
		for (var w = 0; w < tot_rooms_w; w++){
			for (var h = 0; h < tot_rooms_h; h++) {
				var cx = w*(room_cell_w + buffer) + minimap_corner_x; 
				var cy = h*(room_cell_h + buffer) + minimap_corner_y;
				
				var cell = global.floor_grid[# w - add_to_w + global.floor_top_corner.x, h - add_to_h + global.floor_top_corner.y];
				var valid_discovered = cell.discovered and cell.state == room_cell.root;
				
				draw_set_color(valid_discovered? filled_room_col : empty_room_col);
				draw_rectangle(cx, cy, cx + room_cell_w, cy + room_cell_h, false);
				draw_set_color(border_col);
				draw_rectangle(cx, cy, cx + room_cell_w, cy + room_cell_h, true);
								
			}
		}
		
		// Player's current room cell
		// draw the player's current room cell 
		var cx = player_room_x*(room_cell_w + buffer) + minimap_corner_x;
		var cy = player_room_y*(room_cell_h + buffer) + minimap_corner_y;
		draw_set_color(player_in_room_col);
		draw_rectangle(cx, cy, cx + room_cell_w, cy + room_cell_h, false);
		draw_set_color(player_border_col);
		draw_rectangle(cx, cy, cx + room_cell_w, cy + room_cell_h, true);
		
		// update the cell as "discovered"
		global.floor_grid[# player_room_x - add_to_w + global.floor_top_corner.x, player_room_y - add_to_h + global.floor_top_corner.y].discovered = true;
		
			
			
		}	
		
		
	break;
	
	case game.paused:
		if sprite_exists(global.pause_sprite) {
			draw_sprite(global.pause_sprite, 0, 0, 0);
		}
		draw_set_alpha(0.4);
		draw_set_color(c_black);
		draw_rectangle(0, 0, CAM_W, CAM_H, false);
		
		draw_set_alpha(1);
		
		draw_menu_object(global.pause_menu);
	break;
	
	case game.backstory:
		draw_set_alpha(0.8);
		draw_set_color(c_black);
		draw_rectangle(0, 0, SCREEN_W, SCREEN_H, false);
		
		draw_set_alpha(1);
		draw_sprite(spr_tutorial, 0, 0, 0);
		
		//draw_set_font(fnt_GUI);
		//draw_set_halign(fa_center);
		//draw_set_valign(fa_center);
		//draw_set_color(c_white);
		//var h = string_height("A");
		
		//var text = "\n[ESC to return]";
		//text += "\nThis is the mind of an unstable patient. He's comatose because of a risky stunt - he's always looking for risks to take.\n";
		//text += "\nYour goal is to get as many coins as possible.";
		//text += "\nThe gate to the next floor is right where you begin. Reaching a circular exit portal will open it...";
		//text += "\nBut it also triggers the patient's instability.";
		//text += "\nUse WASD to move and LEFT CLICK to teleport quickly (and spawn a bomb that follows you >:] ). Find powerups in chests.";
		
		//draw_text_ext(SCREEN_W/2, SCREEN_H/2, text, h, SCREEN_W*3/4);
		
	break;
	
	case game.explanation:
		draw_set_alpha(0.9);
		draw_set_color(c_black);
		draw_rectangle(0, 0, SCREEN_W, SCREEN_H, false);
		
		draw_set_alpha(1);
		draw_sprite(spr_tutorial_updated, global.tutorial_page, 0, 0);
		
		draw_set(fnt_GUI, fa_left, fa_top, c_white);
		draw_text(12, 12, "ESC to return");
		
	break;
	
	case game.records:
		draw_set(fnt_GUI, fa_left, fa_top, c_white);
		draw_text(24, 24, "Press ESC to return");
		
		draw_set(fnt_GUI, fa_left, fa_center, c_player_blue);
		
		var midx = SCREEN_W/2;
		var midy = SCREEN_H/2;
		var records_init_x = midx - SCREEN_W/4;
		var colon_x = records_init_x + 250;
		var records_init_y = midy - SCREEN_H/4;
		var records_sep = string_height("A") * 2;
		
		draw_set_halign(fa_center);
		draw_text(midx, SCREEN_H/8, "--- RECORDS ---");
		draw_set_color(c_white);			// to add some pop-out and emphasis
		draw_text(midx-1, SCREEN_H/8, "--- RECORDS ---");

		draw_set_halign(fa_left);
		var num_records = array_length(global.records_array);
		for (var r = 0; r < num_records; r++) {
			var cur_y = records_init_y + records_sep*r;
			var rec = global.records_array[r];
			var val = variable_global_get(rec[1]);
			if rec[1] == "best_250_money_time" {
				val = format_time_HHMMSS(val);
			}
			draw_text(records_init_x, cur_y , rec[0]);
			draw_text(colon_x, cur_y, ": " + string(val));
		}


	break;
	
	case game.controls:
		draw_set_alpha(0.8);
		draw_set_color(c_black);
		draw_rectangle(0, 0, SCREEN_W, SCREEN_H, false);
		
		draw_set_alpha(1);
		draw_sprite(spr_starting_tutorial_ground, 0, SCREEN_W/2, SCREEN_H/2);
		
	break;
	
	case game.review:
	
		draw_set_color(c_dkblue);
		draw_rectangle(0, 0, SCREEN_W, SCREEN_H, false);
		
		draw_set_font(fnt_GUI);
		draw_set_halign(fa_center);
		draw_set_valign(fa_center);
		draw_set_color(c_white);
		
		var text = "\"WHAT A RUSH!!! WHEN CAN WE GO BACK IN THERE???\"\n\n";
		text += "You're going on " + string(global.money) + " coins! Continue to floor " + string(global.floors_cleared + 1) + "!";
		
		draw_text(SCREEN_W/2, floor(SCREEN_H/3), text);
		
		draw_menu_object(global.review_menu);
		
	break;
	
	case game.end_review:
	
		draw_set_color(c_dkblue);
		draw_rectangle(0, 0, SCREEN_W, SCREEN_H, false);
		
		draw_set_font(fnt_GUI);
		draw_set_halign(fa_center);
		draw_set_valign(fa_center);
		draw_set_color(c_white);
		
		var text = "\"It's over... Next time, take some better chances, will ya?!\"\n\n";
		text += "You got " + string(global.money) + " coins and got to floor "  + string(global.floors_cleared+1) + " in " + format_time_HHMMSS(global.current_run_time) + "!";;
		
		draw_text(SCREEN_W/2, floor(SCREEN_H/3), text);
		
		draw_menu_object(global.end_review_menu);
		
	
	break; 
	
}

var death_screen_flash_dur = 2;
var player_is_stunned_and_dying = false;
var do_silhouette_after_draw = false;

with (o_player) {
	if hp - deactivated_hearts <= 0 and !global.death_animation {
		player_is_stunned_and_dying = true;
	}
}
if player_is_stunned_and_dying or (global.death_animation and global.transition_timer >= global.death_transition_duration - death_screen_flash_dur) {
	draw_set_color(c_flame);
	draw_set_alpha(1);
	draw_rectangle(0, 0, SCREEN_W, SCREEN_H, false);
	
	do_silhouette_after_draw = true;
	if is_between(global.transition_timer, global.death_transition_duration - death_screen_flash_dur, global.death_transition_duration - death_screen_flash_dur -1) {
		var spd = 3;
		var dis_from_center = 15;	// essentially centered
		var fx = SCREEN_W/2;
		var fy = SCREEN_H/2;
		with (o_player) { 
			fx = get_gui_x(RX); 
			fy = get_gui_y(RY)
		};
		make_sprite_FX_master(fx, fy, global.spark_sprites, 10, irandom_range(25, 30), 
					new Point(-SCREEN_W/dis_from_center, -SCREEN_H/dis_from_center), new Point(SCREEN_W/dis_from_center, SCREEN_H/dis_from_center), 
					[-spd, spd], [-spd, spd], [0.25, 0.5], [c_flame], 0.996, 0);
	}
}



if global.transition_timer > 0 {
	var radius_max = (SCREEN_W+1)/2;
	// get the raw percent value by first mapping total death transition animation time to [0, 1]
	var percent = map(global.death_transition_duration, 0, global.transition_timer, 0, 1);
	// get a "percent of full radius" amount by using the percent
	var curve = animcurve_get_channel(AnimationCurve1, global.transition_curve);
	var radius = radius_max * animcurve_channel_evaluate(curve, percent);
		
	var def_x = SCREEN_W/2;
	var def_y = SCREEN_H/2;
	with (o_camera.follow) {
		def_x -= CAM_X - x;
		def_y -= CAM_Y - y;
	}
	var org = new Point(def_x, def_y);
		
	surface_set_target(global.layer_shapes);
	draw_clear_alpha(c_black, 0);
	draw_set_alpha(1);
	draw_set_color(c_dkblue);
	draw_rectangle(0, 0, SCREEN_W, SCREEN_H, false);
					
	draw_set_circle_precision(64);
	draw_set_color(c_spark);
	draw_circle(org.x, org.y, radius + 2, false);
		
	gpu_set_blendmode(bm_subtract);
	draw_set_color(c_white);
	draw_circle(org.x, org.y, radius, false);
		
	gpu_set_blendmode(bm_normal);
	surface_reset_target();
		
	draw_surface(global.layer_shapes, 0, 0);
	draw_set_color(c_white);
	draw_circle(org.x, org.y, radius, true);
					
	draw_set_circle_precision(24);
}

global.transition_timer -= TIMESTEP * (global.transition_timer > 0);
global.money_flash_timer -= TIMESTEP* (global.money_flash_timer > 0);

// Additional effects

draw_from_list(global.sprite_FX_list_GUI_over);


if do_silhouette_after_draw {
	with (o_hit_parent) {
		var factor = 1.1;
		draw_sprite_ext(sprite_index, image_index, get_gui_x(RX), get_gui_y(RY), image_xscale*factor, image_yscale*factor, image_angle, c_black, 1);
	}
}



// Debug window

if global.debug {
	var debug_right = 12, debug_top = 12;
	var text = "Debug";
	text += "\nState Manager: " + string(instance_exists(o_state_manager));
	text += "\nDifficulty: " + string(global.difficulty);
	text += "\nTime: " + format_time_HHMMSS(global.current_run_time);
	with (o_player) {
		text += "\nX: " + string(x) + ", Y: " + string(y);
	}
	
	draw_set_color(c_white);
	draw_set_halign(fa_right);
	draw_set_valign(fa_top);
	draw_set_font(fnt_debug);
	draw_text_ext(SCREEN_W - debug_right, debug_top, text, string_height("A"), SCREEN_W/5);
}

//if instance_exists(o_player) {
//	with (o_player) {
//		scr_player_GUI();
//	}
//}


