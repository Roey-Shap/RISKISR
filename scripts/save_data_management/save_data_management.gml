// Script assets have changed for v2.3.0 see
// https://help.yoyogames.com/hc/en-us/articles/360005277377 for more information
function load_save_data(){
	
	var extra_data = -1;
	
	if file_exists(global.save_data_file_name){
		ini_open(global.save_data_file_name);
		
		global.SFX_volume				= ini_read_real("Settings", "SFX_level", 1);
		global.music_volume				= ini_read_real("Settings", "Music_level", 1);
		audio_set_master_gain(0,		  ini_read_real("Settings", "Master_level", 1));
		
		global.best_money				= ini_read_real("Record_Runs", "best_money", 0);
		global.best_floors				= ini_read_real("Record_Runs", "best_floors", format_time_HHMMSS(0));
		global.best_250_money_time		= ini_read_real("Record_Runs", "best_250_money_time", infinity);
		global.best_kill_count			= ini_read_real("Record_Runs", "best_kill_count", 0);
		
		ini_close();
	}
	
	return (extra_data);
}

function save_data() {
	
	if file_exists(global.save_data_file_name) {
		file_delete(global.save_data_file_name);
	}
	
	ini_open(global.save_data_file_name);	
	
	ini_write_real("Settings", "SFX_level", global.SFX_volume);
	ini_write_real("Settings", "Music_level", global.music_volume);
	ini_write_real("Settings", "Master_level", audio_get_master_gain(0));
		
	ini_write_real("Record_Runs", "best_money", global.best_money);
	ini_write_real("Record_Runs", "best_floors", global.best_floors);
	ini_write_real("Record_Runs", "best_250_money_time", global.best_250_money_time);
	ini_write_real("Record_Runs", "best_kill_count", global.best_kill_count);
	
	ini_close();
}

function safe_close_game() {
	save_data();
	game_end();
}