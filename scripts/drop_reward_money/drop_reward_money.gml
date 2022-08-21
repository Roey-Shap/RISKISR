// Script assets have changed for v2.3.0 see
// https://help.yoyogames.com/hc/en-us/articles/360005277377 for more information
function drop_reward_money(_x, _y, reward) {
	var has_money = has_charm(charms.money_magnet);
	var money_magnet_bonus = (has_money? 1.5 : 1);
	if has_money > 1 money_magnet_bonus = 1.8;
	
	var open_gate_bonus = (COUNTDOWN > 0)? 2 : 1;
	var final = reward * money_magnet_bonus * open_gate_bonus;
	repeat(floor(final)) {
		var coin = instance_create_layer(_x, _y, LAYER_BULLET, o_money);
		coin.hspd = random_range(-3, 3);
		coin.vspd = random_range(-3, 3);
	}
}