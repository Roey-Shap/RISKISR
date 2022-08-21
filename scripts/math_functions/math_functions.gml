// Script assets have changed for v2.3.0 see
// https://help.yoyogames.com/hc/en-us/articles/360005277377 for more information

function in_rectangle(input_x, input_y, left, top, right, bottom) {
	var x_in = (input_x >= left and input_x <= right);
	var y_in = (input_y >= top and input_y <= bottom);
	return (x_in and y_in);
}

function is_between(input, min_bound, max_bound) {
	// in case of silly usage
	if (min_bound > max_bound) {
		var temp = max_bound;
		max_bound = min_bound;
		min_bound = temp;
	}
	return (input >= min_bound and input <= max_bound);
}


function map(oldmin, oldmax, value, newmin, newmax) {
  return ( (value-oldmin)/(oldmax-oldmin)*(newmax-newmin)+newmin );
}

function floor_to_unit(input, nearest_value){
	return (floor(input/nearest_value)*nearest_value);
}

function ceil_to_unit(input, nearest_value){
	return (ceil(input/nearest_value)*nearest_value);
}

function round_to_unit(input, nearest_value){
	return (round(input/nearest_value)*nearest_value);
}


function angle_clamp(angle) {
	if angle >= 360 {
		angle = angle % 360;
	} else if angle < 0 {
		angle = 360 + angle;
	}
	
	return(angle);
}

function cumulative_chance(chance_array) {
	var len = array_length(chance_array);
	if !len return chance_array;
	
	var res = array_create(len);
	res[0] = chance_array[0];
	
	// iterate over chance_array from the second index and add the previous index
	for (var i = 1; i < len; i++) {
		res[i] = chance_array[i] + res[i-1];
	}
	
	return res;
}

function choose_from_cumulative_array(arr) {
	
	// returns the index chosen
	var len = array_length(arr);
	if !len return -1;
	
	var roll = random(1);
	for (var i = 0; i < len; i++) {
		if arr[i] >= roll return i;
	}
	
	return len-1;
}

function parse_number(str) {
	var newS = "";
	var len = string_length(str);
	var neg = false;
	for (var i=1; i <= len; i++) {
	     var c = string_char_at(str, i);
	     newS += string_digits(c);
	     if (c == ".") newS += ".";
		 if (c == "-") neg = true;
	}
	newS = real(newS);
	return(neg? -newS : newS);
}
	
