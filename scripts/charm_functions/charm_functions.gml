// Script assets have changed for v2.3.0 see
// https://help.yoyogames.com/hc/en-us/articles/360005277377 for more information

function set_charm_defaults() {
	global.player_can_charge = false;
	global.player_slowmo = 1;
}

// https://help.yoyogames.com/hc/en-us/articles/360005277377 for more information
function has_charm(charm_type){
	var num = 0;
	if global.player_charm == charm_type	num++;
	if global.player_charm_2 == charm_type	num++;
	return num; 
}

function has_duplicate_charm() {
	return (global.player_charm == global.player_charm_2 
								and global.player_charm != charms.none);
}

function using_ability(charm_type) {	
	if keyboard_check(global.charm_ability_button_1) {
		if global.player_charm == charm_type return 1;
	}
	
	if keyboard_check(global.charm_ability_button_2) {
		if global.player_charm_2 == charm_type return 2;
	}
	
	return false;
}


function using_ability_pressed(charm_type) {	
	if keyboard_check_pressed(global.charm_ability_button_1) {
		if global.player_charm == charm_type return 1;
	}
	
	if keyboard_check_pressed(global.charm_ability_button_2) {
		if global.player_charm_2 == charm_type return 2;
	}
	
	return false;
}