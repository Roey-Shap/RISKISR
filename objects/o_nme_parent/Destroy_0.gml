/// @description

drop_reward_money(x, y, reward);
if irandom(global.enemy_drop_hp_chance) == 0 {
	var hp_pickup = instance_create_layer(x, y, LAYER_UNDER, o_health_pickup);
	
	var ang = irandom(359);
	hp_pickup.hspd = lengthdir_x(3.5, ang);
	hp_pickup.vspd = lengthdir_y(3.5, ang);
}

global.current_kill_count++;