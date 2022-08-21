/// @description

//display_set_gui_size(SCREEN_W, SCREEN_H);


function state_reset() {
	draw_manager = instance_create_layer(0, 0, LAYER_META, o_draw_manager);
	camera = instance_create_layer(0, 0, LAYER_META, o_camera);
	if layer_get_name(layer) != LAYER_META {
		layer = layer_get_id(LAYER_META);
	}

	reset_FX_lists();
	reset_hitbox_list();
	
	if sprite_exists(global.pause_sprite) {
		sprite_delete(global.pause_sprite);
	}
	if surface_exists(global.pause_surf) {
		surface_free(global.pause_surf);
	}
	global.pause_surf = -1;
	global.pause_sprite = -1;

	global.timeDelta = 1;
	global.countdown_timer = -1;
	
	global.opened_gate = false;
	global.death_animation = false;
	global.entering_gate = false;
}



function deactivate() {
	instance_deactivate_layer(LAYER_BULLET);
	instance_deactivate_layer(LAYER_COLLISION);
	instance_deactivate_layer(LAYER_ENEMY);		// includes player
	instance_deactivate_layer(LAYER_UNDER);
	
}

function destroy_non_meta() {
	var layers = [
		LAYER_BULLET,
		LAYER_COLLISION,
		LAYER_ENEMY,
		LAYER_UNDER,
	]
	var num_layers = array_length(layers);
	for (var i = 0; i < num_layers; i++) {
		layer_destroy_instances(layers[i]);
	}
	
}

GUI_HUD = new Point(4, 4);
global.GUI_HUD = GUI_HUD;
global.GUI_hp = new Point(14 + GUI_HUD.x, 14 + GUI_HUD.y)
global.GUI_money = new Point(126 + GUI_HUD.x, 38 + GUI_HUD.y);
global.GUI_pic = new Point(1 + GUI_HUD.x, 29 + GUI_HUD.y);
global.GUI_pic2 = new Point(1 + 40 + 1 + GUI_HUD.x, 29 + GUI_HUD.y);
global.GUI_name = new Point(37 + GUI_HUD.x, 12 + GUI_HUD.y);
global.GUI_desc = new Point(111 + GUI_HUD.x, 42 + GUI_HUD.y);

global.GUI_linker = new Point(global.GUI_pic2.x - 1, global.GUI_pic.y + 40 + 1);
global.linker_FX = new sprite_FX(global.GUI_linker.x, global.GUI_linker.y, spr_linker_slot, 10);
global.linker_FX.image_speed = 0;

// so we can just draw it in the GUI call and not automatically in the master list
ds_list_delete(global.sprite_FX_list_GUI_over, ds_list_find_index(global.sprite_FX_list_GUI_over, global.linker_FX));


tutorial_function = -1;

var sw = SCREEN_W;
var sh = SCREEN_H;
var midx = sw/2;
var midy = sh/2;

var button_w = SCREEN_W * 0.8;
var button_h = SCREEN_H * 0.09;

var button_gap_w = SCREEN_W * 0.3;
var button_gap_h = button_h * 1.35;

var button_init_h = SCREEN_H * 0.15;
var counter = 0;

global.main_menu = {
	start_button: new ButtonGUI(midx, button_init_h + (button_gap_h*(2)), 
								(function() {										
									global.game_state = game.playing; 
									room = rm_generated; 
									global.difficulty = global.difficulty_min;
									global.money = 0;
									global.player_hp = global.player_max_hp;
									global.player_temp_hp = 0;
									global.deactivated_hearts = 0;
									
									global.current_run_time = 0;
									global.floors_cleared = 0;
									global.current_kill_count = 0;
									
									global.player_charm = charms.none;
									global.player_charm_2 = charms.none;
									global.player_charm_amount = 1;
									global.opened_gate = false;
									global.review = false;
									
									
									set_charm_defaults(); }), 
									"Start Attempt", button_w, button_h),
												
	first_time_button: new ButtonGUI(midx, button_init_h + (button_gap_h*(3)), 
								(function() { global.game_state = game.playing;
											  room = rm_tutorial; 
											 
											global.tutorial_text = "";
											global.tutorial_function_index = 0;
											global.tutorial_HUD_active = false;
											global.tutorial_player_teleport_active = false;
											global.tutorial_player_bomb_active = false;
											
											// upon completing the tutorial (just starting it...) add the shortened tutorial button to the home menu)
											var sw = SCREEN_W;
											var sh = SCREEN_H;
											var midx = sw/2;
											var midy = sh/2;

											var button_w = SCREEN_W * 0.8;
											var button_h = SCREEN_H * 0.09;

											var button_gap_w = SCREEN_W * 0.3;
											var button_gap_h = button_h * 1.35;

											var button_init_h = SCREEN_H * 0.15;
											var counter = 0;
											
											global.main_menu.first_time_button.updateCoords(midx - button_gap_w*2/3, button_init_h + (button_gap_h*(3)));
											
											variable_struct_set(global.main_menu, "explain_button",	new ButtonGUI(midx + button_gap_w*2/3, button_init_h + (button_gap_h*(3)), 
												(function() { global.game_state = game.explanation;
															  global.tutorial_page = 0;
															  global.return_state = game.main_menu; }), 
																"How to Play", button_w/2, button_h)); 
								}), 
								"First Time Playing?", button_w/2, button_h),
								
	records_button: new ButtonGUI(midx, button_init_h + (button_gap_h*(4)), 
								(function() { global.game_state = game.records
											  global.return_state = game.main_menu; }), "Records", button_w*2/3, button_h),
								
	sound_effects_button: new ButtonGUI(midx - button_gap_w, button_init_h + (button_gap_h*(5)), 
								(function() { global.SFX_volume = !global.SFX_volume; }), "Toggle SFX", button_w/3, button_h),
								
	music_button: new ButtonGUI(midx, button_init_h + (button_gap_h*(5)), 
								(function() { global.music_volume = !global.music_volume; }), "Toggle Music", button_w/3, button_h),
								
	master_sound_button: new ButtonGUI(midx + button_gap_w, button_init_h + (button_gap_h*(5)), 
										(function() { audio_set_master_gain(0, 1-audio_get_master_gain(0)); }), "Toggle Master Sound", button_w/3, button_h),
								
	exit_button: new ButtonGUI(midx, button_init_h + (button_gap_h*(6)), 
								(function() { safe_close_game(); }), "Exit game", button_w, button_h),
}


global.pause_menu = {
	resume_button: new ButtonGUI(midx, button_init_h + (button_gap_h*(1)), 
								(function() {	global.game_state = game.playing; 
												global.lmb_buffer = 3;
												global.lmb_release_buffer = 10;
												global.left_click_locked = true;
												global.player_must_release_lmb = true;
												instance_activate_all(); }), "Resume", button_w, button_h),
												
	main_menu_button: new ButtonGUI(midx, button_init_h + (button_gap_h*(2)), 
								(function() {	global.game_state = game.main_menu;
												instance_activate_all();
												room = rm_main_menu; }), "Main Menu", button_w, button_h),
								
	explain_button: new ButtonGUI(midx, button_init_h + (button_gap_h*(3)), 
								(function() { global.game_state = game.explanation;
											  global.tutorial_page = 0;
											  global.return_state = game.paused; }), 
												"How to Play", button_w, button_h),
								
	sound_effects_button: new ButtonGUI(midx - button_gap_w, button_init_h + (button_gap_h*(4)), 
								(function() { global.SFX_volume = !global.SFX_volume; }), "Toggle SFX", button_w/3, button_h),
								
	music_button: new ButtonGUI(midx, button_init_h + (button_gap_h*(4)), 
								(function() { global.music_volume = !global.music_volume; }), "Toggle Music", button_w/3, button_h),
								
	master_sound_button: new ButtonGUI(midx + button_gap_w, button_init_h + (button_gap_h*(4)), 
										(function() { audio_set_master_gain(0, 1-audio_get_master_gain(0)); }), "Toggle Master Sound", button_w/3, button_h),
										
	exit_button: new ButtonGUI(midx, button_init_h + (button_gap_h*(5)), 
								(function() { safe_close_game(); }), "Exit game", button_w, button_h),
}

global.review_menu = {
	continue_button: new ButtonGUI(midx, button_init_h + (button_gap_h*(3)), 
								(function() {	global.game_state = game.playing;
												with (o_state_manager) { state_reset(); };
												room_restart(); }), "Continue", button_w, button_h),
												
	main_menu_button: new ButtonGUI(midx, button_init_h + (button_gap_h*(4)), 
								(function() {	global.game_state = game.main_menu;
												room = rm_main_menu; }), "Main Menu", button_w, button_h),
												
	exit_button: new ButtonGUI(midx, button_init_h + (button_gap_h*(5)), 
								(function() { safe_close_game(); }), "Exit game", button_w, button_h),
}

global.end_review_menu = {
	main_menu_button: new ButtonGUI(midx, button_init_h + (button_gap_h*(3)), 
								(function() {	global.game_state = game.main_menu;
												reset_GUI_FX_lists();
												room = rm_main_menu; }), "Main Menu", button_w, button_h),
												
	exit_button: new ButtonGUI(midx, button_init_h + (button_gap_h*(4)), 
								(function() { safe_close_game(); }), "Exit game", button_w, button_h),	
}

//global.options = {
//	sound_effects_button: new ButtonGUI(midx - button_gap_h, button_init_h + (button_gap_h*(counter++)), 
//								function() { global.SFX_volume = !global.SFX_volume; }, "Toggle SFX", button_w/3, button_h),
								
//	music_button: new ButtonGUI(midx - button_gap_h, button_init_h + (button_gap_h*(counter++)), 
//								function() { global.music_volume = !global.music_volume; }, "Toggle Music", button_w/3, button_h),
								
//	master_sound_button: new ButtonGUI(midx - button_gap_h, button_init_h + (button_gap_h*(counter++)), 
//										function() { audio_set_master_gain(0, 1-audio_get_master_gain(0)); }, "Toggle Master Sound", button_w/3, button_h),
//}


if room == rm_main_menu {
	var draw_manager = instance_create_layer(0, 0, layer, o_draw_manager);
	var cam  = instance_create_layer(room_width/2, room_height/2, layer, o_camera);
}
