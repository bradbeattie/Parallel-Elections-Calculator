// Place your application-specific JavaScript functions and classes here
// This file is automatically included by javascript_include_tag :defaults

$(document).ready(function(){
	$('.slider').each(function(i,div){$(div).slider()});
	$('#scenarios').bind('tabsshow', function(event, ui) { load_scenario(ui.tab.id.substring(9));	});
	$("#scenarios").tabs();
				  
    $('#initial-values thead th').click(function(){rename_header($(this), "demographic");});
    $('#initial-values tbody th').click(function(){rename_header($(this), "candidate");});
	$('#actions a').hover(
	    function() { $(this).addClass('ui-state-hover'); },
		function() { $(this).removeClass('ui-state-hover'); }
	); 
});

function rename_header(header, title) {
	new_name = prompt("Rename "+title, header.html());
	if (new_name != "" && new_name != null && new_name != header.html()) {
		header.html(new_name);
		generate_results();
	}
}

function load_scenario(scenario) {
    scenarios = new Array;
    scenarios["splitting"] = new Array( 80,20,20,
										50,75,65,
										70,70,75,
										34,33,33);
	
    scenarios["tactical"] = new Array( 80,20,10,
									   20,80,20,
									   40,40,80,
									   80,60,30);
	
    scenarios["ignored"] = new Array( 80,10,10,
									  10,80,30,
									  30,20,80,
									  85,60,30);
	
    $('.slider').unbind('slidechange', generate_results);
    if (scenario != "random") {
        $('.slider').each(function(i,div){
            $(div).slider('value', scenarios[scenario][i]);
        });
    } else {
        $('.slider').each(function(i,div){
            $(div).slider('value', Math.floor(Math.random()*100+1));
        });    
    }
    $('.slider').bind('slidechange', generate_results);

	if (arguments.length == 1) {
		generate_results();
	}
}

function generate_results() {

	// Parse the demographics
	var demographics = Array();
	var preferences = Array();
	var demographicSizes = Array();
	$("#initial-values thead tr th").each(function(column,demographic){
		demographics[column] = $(demographic).html();
		demographicSizes[column] = $("#initial-values tfoot tr td:nth-child("+(column+2)+") div.slider").slider('value');
		preferences[column] = Array();
	});

	// Parse the candidates
	var candidates = Array();
	var preferencesByCandidate = Array();
	$("#initial-values tbody tr th").each(function(row,candidate){
		candidates[row] = $(candidate).html();
		preferences[candidates[row]] = Array();
	});

	// Parse the preferences into a more readable form
	$("#initial-values tbody tr").each(function(row,candidate){
		candidateName = $("#initial-values tbody tr:nth-child("+(row+1)+") th").html();
		$(candidate).find("td div.slider").each(function(column,preference){
			demographicName = $("#initial-values thead tr th:nth-child("+(column+2)+")").html();
			preferences[column][row] = $(preference).slider('value');
		});
	});

	// Call each voting system in turn
	var params = {};
	params["demographic_sizes[]"] = demographicSizes;
	params["demographics[]"] = demographics;
	params["candidates[]"] = candidates;
	for (var i in demographics) {
		params["preferences["+i+"][]"] = preferences[i];
	}
	if (systems != undefined) {
		params["systems[]"] = systems;
	}
	$.post("elections/results", params,
		function(data) {
			$("#results").html(data);
		}
	);
	return false;
}
