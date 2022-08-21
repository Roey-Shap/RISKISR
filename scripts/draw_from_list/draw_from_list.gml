// Script assets have changed for v2.3.0 see
// https://help.yoyogames.com/hc/en-us/articles/360005277377 for more information
function draw_from_list(list){
	var len = ds_list_size(list);
	for (var i = 0; i < len; i++) {
		var cur = list[| i];
		cur.draw();
	}
}