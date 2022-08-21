/// @description

#macro DEVELOPER_MODE false
#macro DEVELOPER:DEVELOPER_MODE true


// Meta control
global.debug = DEVELOPER_MODE;
global.FPS = game_get_speed(gamespeed_fps);
global.timeDelta = 1;
global.cam_x = 0;
global.cam_y = 0;
global.cam_w = 0;
global.cam_h = 0;
global.cam_scale = 1;

global.paused_this_frame = false;
global.pause_surf = -1;
global.pause_sprite = -1;

global.layer_shapes = -1;

global.music_volume = 1;
global.SFX_volume = 1;

global.save_data_file_name = "save.ini";
global.best_money = 0;				
global.best_floors = 0;			
global.best_250_money_time = 0;		
global.best_kill_count = 0;

global.records_array = [
	["Highest Money", "best_money"],
	["Highest Floor Reached", "best_floors"],
	["Fastest time to reach 250 coins", "best_250_money_time"],
	["Highest Kill Count", "best_kill_count"],

]

// Make necessary overrides for global variables from files
load_save_data();


// Generating levels
global.scanned_rooms = ds_list_create();
global.available_enemies = ds_list_create();
ds_list_add(global.available_enemies, 
	o_nme_basic,
	o_nme_lunge,
	o_nme_lunge_bomb,
	o_nme_radial_spin,
	o_nme_shoot_charge,
	o_nme_shoot_bomb,
	o_nme_tank_shockwave,
);
global.available_consumables = ds_list_create();
global.room_generated = false;

global.cur_room_extra_enemy_count = 0;

// Controls
global.charm_ability_button_1	= vk_shift;
global.charm_ability_button_2	= vk_space;

global.lmb_buffer = 0;
global.lmb_release_buffer = 0;
global.rmb_buffer = 0;
global.mouse_buffer_time = 7;
global.left_click_locked = false;
global.player_using_slowmo = false;
global.player_must_release_lmb = false;

global.double_click_left_duration = 8;
global.left_click_locked = false;

// Gameplay and room control variables
global.difficulty_min = 1;
global.difficulty_max = 10;
global.difficulty = global.difficulty_min;
global.floor_grid = -1;
global.spawned_room_width = 0;
global.spawned_room_height = 0;
global.floor_top_corner = -1;
global.chest_has_linker_chance = 20;

global.enemy_drop_hp_chance = 20 - 1; // is 1/x chance for an extra heart
global.enemy_find_target_timer = 0;
global.enemy_find_target_frequency = 10;


global.countdown_timer = -1;
global.countdown_time_init = 2 * pi * 10 * global.FPS;
global.rock_falling_timer = 0;
global.spawn_falling_object_height = 400;

global.hitboxes = ds_list_create();

global.player_max_hp = 5;
global.player_hp = global.player_max_hp;
global.player_max_temp_hp = 3;
global.player_temp_hp = 0;
global.deactivated_hearts = 0;

global.money = 0;
global.floors_cleared = 0;
global.opened_gate = false;
global.current_run_time = 0;
global.current_kill_count = 0;

global.death_animation = false;
global.death_transition_duration = false;
global.entering_gate = false;
global.transition_curve = "cv_animation_death";
global.transition_timer = 0;


// Tutorial Room
global.tutorial_text = "";
global.tutorial_available_enemies = ds_list_create();
ds_list_add(global.tutorial_available_enemies, 
	o_nme_basic,
	o_nme_lunge
);
global.tutorial_HUD_active = false;
global.tutorial_player_teleport_active = false;
global.tutorial_player_bomb_active = false;

global.tutorial_functions = [
	function() { set_tutorial_text("It's so boring in here...\n[WASD]"); 
				tutorial_button_rand();},
	function() { set_tutorial_text("Let's add some new rules to spice things up!"); 
				tutorial_button_rand();
				global.tutorial_HUD_active = true;
				},
	function() { set_tutorial_text("It'll be just like those old arcade games: beat up goons to get points and try not to die!"); 
					// spawn some coins
					with (o_player) {
						drop_reward_money(room_width/2, room_height/2, irandom_range(9, 12));	
					}
					tutorial_button_rand();
				},
	function() { set_tutorial_text("I guess I need a weapon, too? But that's so basic..."); 
				tutorial_button_rand();},
	function() { set_tutorial_text("Got it! How about this? I'm real slow normally, so I can teleport with LEFT CLICK!"); 
					// activate the player's bombs
					global.tutorial_player_teleport_active = true;
					o_state_manager.tutorial_function = function() {
						var player_teleported = false;
						with (o_player) {
							player_teleported = teleport_limit_timer > 0;
						}
						return (player_teleported);
					}
				},
	function() { set_tutorial_text("But it spawns a bomb behind me! Now THAT'S why they call me the RISK KISSER! Hahaha!"); 
				tutorial_button_rand();},
	function() { set_tutorial_text("The only way to clobber the goons and get coins is by putting myself in danger! BRILLIANT!"); 
				var pack_origin = get_temp_spot(true);
					repeat(2) {
						var nme_origin = pick_point_on_circle(pack_origin.x, pack_origin.y, 32);
						var ran_nme = global.tutorial_available_enemies[| irandom(ds_list_size(global.tutorial_available_enemies)-1)];
						var nme = instance_create_layer(nme_origin.x, nme_origin.y, LAYER_ENEMY, ran_nme);
					}
					o_state_manager.tutorial_function = function() {
						return (instance_number(o_nme_parent) == 0);
					}
				},
	function() { set_tutorial_text("Ooh... and it'll be like a dungeon with floors! I start next to the door and need to go find an activator..."); 
					// spawn the activator
					var p = get_temp_spot(true);
					var activator = instance_create_layer(p.x, p.y, LAYER_COLLISION, o_activation_module);
					
					p = get_temp_spot(false);
					var door = instance_create_layer(p.x, p.y, LAYER_COLLISION, o_exit_gate);
				},
				// this vvv is activated by entering the door
	function() { set_tutorial_text("It opens the door, but it makes the place really unstable!"); 
				tutorial_button_rand();},
	function() { set_tutorial_text("How about this:\nI also get more money while the floor is crumbling! Now I can decide whether to keep enemies around for extra cash or get 'em out of my face early..."); 
				tutorial_button_rand();},
	function() { set_tutorial_text("Needs one more thing..."); 
				tutorial_button_rand();},
	function() { set_tutorial_text("Powerups!!"); 
				// spawn the chest
				var p = get_temp_spot(false);
				var chest = instance_create_layer(p.x, p.y, LAYER_BULLET, o_chest);
				chest.charm_type = irandom_range(1, charms.LAST-1);
				tutorial_button_rand();
				},
	function() { set_tutorial_text("Some'll have passive abilities and others will have ones to activate with LSHIFT."); 
				tutorial_button_rand();},
	function() { set_tutorial_text("If I ever forget what one does, I should hover over the HUD to find out."); 
				tutorial_button_rand();},
	function() { set_tutorial_text("I can get rid of one I don't like by RIGHT CLICKing it."); 
				tutorial_button_rand();},
	function() { set_tutorial_text("I guess that's all... LET'S DO THIS!"); 
				var p = get_temp_spot(true);
				var door = instance_create_layer(p.x, p.y, LAYER_COLLISION, o_exit_gate);
				global.opened_gate = true;
				},
]
global.tutorial_functions_num = array_length(global.tutorial_functions);
global.tutorial_function_index = 0;


enum charms {
	none,
	money_magnet,	
	devils_horns,
	deux_balls,
	big_balls,
	stopwatch,
	running_shoes,
	heart_of_gold,
	adrenaline_on_a_stick,
	
//	heart_breaker,
	LAST,
	linker
}

	//sprite, name, description, on_equip_global_variable_set_function, 
global.charm_info = [
	[spr_charm_none, "None", "No charm", "No charm", -1],
	[spr_charm_money_magnet, "Money Magnet", "Better enemy money drops", "Even better money drops", -1],
	[spr_charm_devils_horns, "Devil's Horns", "Take risks and get money! Get close to enemy projectiles for cash!", "Larger graze bonus radius", -1],
	[spr_charm_deux_balls, "Deux Balls", "Two times the danger, two times the fun!!", "3 projectiles", -1],
	[spr_charm_big_balls, "Big Balls", "Hold teleport to charge for bigger bombs and teleport range", "Faster Charge", function() { global.player_can_charge = true }],
	[spr_charm_stopwatch, "Stopwatch", "Use ability for slow-mo effect. You take +1 damage while in this state", "More slightly more quickly while in slowmo" ,function() { global.player_slowmo = 0.45 }],
	[spr_charm_running_shoes, "Running Shoes", "SPEED SPEED SPEED!!", "Even more speed", -1],
	[spr_charm_heart_of_gold, "Heart of Gold", "Use ability to exchange 30 coins for temporary health. Only 3 uses!", "No extra bonus", -1],
	[spr_charm_adrenaline, "Adrenaline", "Shortens teleport cooldown, but also radius", "No teleport radius penalty", -1],	
	
	[],
	[spr_charm_linker, "Linker", "Allows for two charms to be active at once, but one heart will not be active. To restore the heart and permanently break the Linker, right click this.", "", -1],	
]

global.player_charm = charms.none;
global.player_charm_2 = charms.none;
global.player_charm_amount = 1;

global.hovering_over_charm_1_timer = 0;
global.hovering_over_charm_2_timer = 0;
global.hovering_over_linker_timer = 0;
global.tooltip_hover_min_time = 0.5 * SECOND;

global.tutorial_page = 0;


global.money_needed_for_heart_of_gold = 30;
global.money_flash_timer = 0;
global.not_enough_money_for_heart_of_gold_duration = 1.4 * SECOND;
global.heart_of_gold_uses = 0;
global.heart_of_gold_2_uses = 0;
global.heart_of_gold_max_uses = 3;

set_charm_defaults();

// Convenience
global.color_hurt = merge_color(c_red, c_yellow, 0.45);
global.color_light_blue = scribble_rgb_to_bgr(0x77CFCC);
global.color_spark = scribble_rgb_to_bgr(0xE9C46A);
global.color_spark_dark = scribble_rgb_to_bgr(0xF4A261);
global.color_flame = scribble_rgb_to_bgr(0xE76F51);
global.color_player_blue = scribble_rgb_to_bgr(0x35B2A3);
global.color_dark_blue = scribble_rgb_to_bgr(0x264653);
global.color_hot_pink = scribble_rgb_to_bgr(0xED008C);

global.spark_sprites = [spr_teleport_spark_1, spr_teleport_spark_2, spr_teleport_spark_3];
global.circle_sprites = [spr_FX_circle_1, spr_FX_circle_2];
global.explosion_sounds = [snd_explosion_1, snd_explosion_4];//[snd_explosion_1, snd_explosion_2, snd_explosion_3];
global.click_sounds = [snd_menu_click_1, snd_menu_click_2, snd_menu_click_3, snd_menu_click_4, snd_menu_click_5];
global.bullet_sounds = [snd_bullet_1, snd_bullet_2];

global.sqrt_2 = sqrt(2);


enum game {
	main_menu,
	playing,
	paused,
	options,
	review,
	controls,
	backstory,
	explanation,
	end_review,
	records,
	exit_game,
	LAST
}

enum main_menu_options {
	start_run,
	options,
	exit_game,
	LAST
}

enum options_menu {
	
}

enum button_gui {
	unselected,
	selected,
}

// Menus
global.game_state = game.main_menu;
global.return_to_state = game.main_menu;
global.review = false;



enum room_cell {
	empty,
	taken,
	root,
	potential,
	LAST
}

enum hitbox_shape {
	rectangle,
	ellipse,
}

enum stun_state {
	none,
	stun,
	LAST,
}

enum player_action {
	none,
	death,
	enter_gate,
	enter_gate_ball,
}

enum enemy_action {
	none,
	roaming,
	shot_charge,
	shooting,
	shot_recoil,
	approach,
	lunge,
	lunge_cooldown,
	wait,
	death,
	LAST
}

// Macros

// Time
#macro TIMESTEP global.timeDelta
#macro SECOND global.FPS

// Controls
#macro LMB_PRESS (global.lmb_buffer > 0)
#macro LMB_RELEASE (global.lmb_release_buffer > 0)
#macro RMB_PRESS (global.rmb_buffer > 0)

// Screen sizes and positions
#macro MX round(mouse_x)
#macro MY round(mouse_y)

#macro SCREEN_W 640
#macro SCREEN_H 360

#macro CAM_X global.cam_x
#macro CAM_Y global.cam_y
#macro CAM_W global.cam_w
#macro CAM_H global.cam_h
#macro CAM_SCALE global.cam_scale


// colors
#macro c_hurt global.color_hurt
#macro c_ltblue global.color_light_blue
#macro c_spark global.color_spark
#macro c_spark_dark global.color_spark_dark
#macro c_flame global.color_flame
#macro c_dkblue global.color_dark_blue
#macro c_hotpink global.color_hot_pink
#macro c_player_blue global.color_player_blue

// rooms
#macro TILE_W 32
#macro TILE_H 32
#macro ROOM_W 960 
#macro ROOM_H 576

#macro NORTH 1
#macro WEST 2
#macro EAST 4
#macro SOUTH 8


#macro LAYER_COLLISION "Collision"
#macro LAYER_ENEMY "Instances"
#macro LAYER_BULLET "Under_Instances"
#macro LAYER_META "Meta"
#macro LAYER_UNDER "Under_Instances"

#macro LAYER_ASSET "Assets_Extra"
#macro LAYER_TILES_COLLISION "Collision_Tiles"

#macro COUNTDOWN global.countdown_timer
#macro ROCK_TIMER global.rock_falling_timer

// math
#macro RX (round(x))
#macro RY (round(y))
#macro SQRT2 global.sqrt_2


// Set-up Imported Packages
init_constructors();
randomize();
randomize();
window_set_fullscreen(true);


var scanner = instance_create_layer(x, y, layer, o_room_scanner);



