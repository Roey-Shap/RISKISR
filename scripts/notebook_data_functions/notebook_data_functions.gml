// Script assets have changed for v2.3.0 see
// https://help.yoyogames.com/hc/en-us/articles/360005277377 for more information

function save_notebook_data() {
	// save basic notebook data
	
	var rawData = {
		page_count: pages, 
		page_data: page_array
	}
	show_debug_message("local page_array");
	show_debug_message(page_array);
	
	//variable_struct_set(rawData, "page_count", pages);
	//variable_struct_set(rawData, "page_data", page_array);
	
	
	var json = json_stringify(rawData);	 
	
	var buffer = buffer_create(string_byte_length(json) + 1, buffer_fixed, 1); 
	buffer_write(buffer, buffer_string, json); 
	buffer_save(buffer, global.notebook_save_file_name);
	buffer_delete(buffer);
	
	
	// save each drawing elements' image data
	for (var p = 0; p < pages; p++) { 
		with(page_array[p]) { 
			for (var e = 0; e < num_elements; e++) {
				var cur_element = elements[e];
				if cur_element.type == pageElements.drawing and cur_element.content != -1 {
					var filename = "ID_" + string(cur_element.id) + "_drawing_page_element_sprite.png";
					
					sprite_save(cur_element.content, 0, filename);
					//sprite_delete(cur_element.content);
				}
			}
		}
	}
}

function load_notebook_data() {
	if !file_exists(global.notebook_save_file_name) {
		show_debug_message("Couldn't find notebook file.");
		return(-1);
	}
	
	var buffer = buffer_load(global.notebook_save_file_name);
	var json = buffer_read(buffer, buffer_string);
	buffer_delete(buffer);

	var rawData = json_parse(json);	
	return(rawData);
}
