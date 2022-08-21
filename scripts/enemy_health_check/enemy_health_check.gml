// Script assets have changed for v2.3.0 see
// https://help.yoyogames.com/hc/en-us/articles/360005277377 for more information
function enemy_health_check(){
	if hp <= 0 {
		instance_destroy(id);
	}
}