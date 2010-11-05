var available_moves = false;
var arrows = {
	nw: '&#8598;',
	ne: '&#8599;',
	se: '&#8600;',
	sw: '&#8601;'
};

function addArrow(square,direction) {
	var arrow = arrows[direction];
	var arrow_node = $("<span class='" + direction + "_arrow dir_arrow'>" + arrow + "</span>");
	arrow_node.data('dir', direction);
	square.append(arrow_node);
}

$(document).ready(function() {

	$.getJSON(game_id + "/available_moves", function(data,text) {
		available_moves = data;
	});

	$('.dir_arrow').live('click', function() {
		var direction = $(this).data('dir');
		alert(direction);
	});
	
	$("td.move_square").click(function() {
		if($(this).hasClass("selected")) return undefined;
		$('td.move_square .dir_arrow').detach();
		$("td.selected").removeClass("selected");
		$(this).addClass("selected");
		key = '[' + $(this).data('rank') + ', ' + $(this).data('file') + ']';
		for (index in available_moves[key]) {
			addArrow($($(this).children()[0]),available_moves[key][index]);
		}		
	});
	
});