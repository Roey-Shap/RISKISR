/// @description

if room == rm_generated {
	// spawn a random enemy
	var options = ds_list_size(global.available_consumables);
	var index = irandom(options-1);
	var nme = instance_create_layer(offx + x + sprite_width/2, offy + y + sprite_height/2,
									LAYER_ENEMY, global.available_enemies[| index]);
									
	instance_destroy(id);
}