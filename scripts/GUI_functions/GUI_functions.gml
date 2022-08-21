// Script assets have changed for v2.3.0 see
// https://help.yoyogames.com/hc/en-us/articles/360005277377 for more information
function do_menu_object_step(obj){
	var buttons = variable_struct_get_names(obj);
	var num_buttons = array_length(buttons);
	for (var i = 0; i < num_buttons; i++) {
		var b = variable_struct_get(obj, buttons[i]);
		b.step();
	}
}

function draw_menu_object(obj){
	var buttons = variable_struct_get_names(obj);
	var num_buttons = array_length(buttons);
	for (var i = 0; i < num_buttons; i++) {
		var b = variable_struct_get(obj, buttons[i]);
		b.draw();
	}
}
