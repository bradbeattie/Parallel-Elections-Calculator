scenarios = new Array;
scenarios["splitting"] = new Array;
scenarios["splitting"]["systems"] = ["Plurality", "RankedPairs"];
scenarios["splitting"]["candidates"] = ["Yellow Candidate", "Teal Candidate", "Aqua Candidate"];
scenarios["splitting"]["demographics"] = ["People living on the north side", "People living on the south side", "People living in the city centre"];
scenarios["splitting"]["demographic_sizes"] = [34,33,33];
scenarios["splitting"]["preferences"] = [80,10,10,
										 30,80,70,
										 40,70,80];

scenarios["tactical"] = new Array;
scenarios["tactical"]["systems"] = ["Plurality", "RankedPairs"];
scenarios["tactical"]["candidates"] = ["Turn back before it's too late", "Keep sailing across the Atlantic", "Search for a nearby habitable island"];
scenarios["tactical"]["demographics"] = ["Crew", "Passengers", "Adventurous passengers"];
scenarios["tactical"]["demographic_sizes"] = [80,70,15];
scenarios["tactical"]["preferences"] = [90,10,10,
										10,90,50,
										50,50,90];

scenarios["ignored"] = new Array;
scenarios["ignored"]["systems"] = ["InstantRunoff", "RankedPairs"];
scenarios["ignored"]["candidates"] = ["Chocolate", "Vanilla", "Strawberry"];
scenarios["ignored"]["demographics"] = ["Economists", "Actuaries", "Jugglers"];
scenarios["ignored"]["demographic_sizes"] = [80,50,35];
scenarios["ignored"]["preferences"] = [90,10,10,
									   10,90,50,
									   50,50,90];

scenarios["ties"] = new Array;
scenarios["ties"]["systems"] = ["Plurality", "InstantRunoff", "RankedPairs"];
scenarios["ties"]["candidates"] = ["Costa Rica", "Vancouver", "Berne"];
scenarios["ties"]["demographics"] = ["Alice", "Bob", "Christine", "Dave"];
scenarios["ties"]["demographic_sizes"] = [1,1,1,1];
scenarios["ties"]["preferences"] = [90,10,10,90,
                                    90,50,50,50,
                                    50,50,90,10];


$(document).ready(function(){
	$('#scenarios').bind('tabsshow', function(event, ui) { load_scenario(ui.tab.id.substring(9));	});
	$('#scenarios').tabs();

	$('#action-add-demographic').click(function(){add_entity("demographic")});
	$('#action-add-candidate').click(function(){add_entity("candidate")});
	
	$('.generate-results').live("click",function(){generate_results()});
	
    $('#initial-values thead th').live("click",function(){rename_entity("demographic",$(this));});
    $('#initial-values tbody th').live("click",function(){rename_entity("candidate",$(this));});
	$('#actions a').hover(
	    function() { $(this).addClass('ui-state-hover'); },
		function() { $(this).removeClass('ui-state-hover'); }
	); 
});

function rename_entity(title, header) {
	new_name = prompt("New name for "+title, header.html());
	if (new_name == "") {
		remove_entity(title, header);
	} else if (new_name != null && new_name != header.html()) {
		header.html(new_name);
		generate_results();
	}
}

function remove_entity(title, header) {
	if (title == "candidate") {

	} else if (title == "demographic") {
			 
	}
}

function add_entity(title) {
	new_name = prompt("Name for new "+title);
	if (new_name != null && new_name != "") {
		if (title == "candidate") {
			columns = $("#initial-values tbody tr:first-child td").length;
			html_segment = "<tr><th>"+new_name+"</th>";
			for (i=0;i<columns;i++)	html_segment += "<td><div class='slider'></div></td>";
			html_segment += "</tr>";
			$("#initial-values tbody").append(html_segment);
			$("#initial-values tbody tr:last-child .slider").each(function(i,div){ $(div).slider({range: "min", min: 1, max: 100, value: Math.floor(Math.random()*100+1)}) });
		} else if (title == "demographic") {
			$("#initial-values thead tr").append("<th>"+new_name+"</th>");
			$("#initial-values tbody tr").append("<td><div class='slider'></div></td>");
			$("#initial-values tfoot tr").append("<td><div class='slider'></div></td>");
			$("#initial-values tr td:last-child .slider").each(function(i,div){ $(div).slider({range: "min", min: 1, max: 100, value: Math.floor(Math.random()*100+1)}) });

		}
		generate_results();
	}
	return false;
}



function load_scenario(scenario) {
	
	$("#initial-values").html("<thead><tr><td></td></tr></thead><tbody></tbody><tfoot><tr><th>Demographic size</th></tr></tfoot>");
	
	for (var i in scenarios[scenario]["candidates"]) {
		$("#initial-values tbody").append("<tr><th>"+scenarios[scenario]["candidates"][i]+"</th></tr>");
	}
	for (var i in scenarios[scenario]["demographics"]) {
		$("#initial-values thead tr").append("<th>"+scenarios[scenario]["demographics"][i]+"</th>");
		$("#initial-values tbody tr").append("<td><div class='slider'></div></td>");
		$("#initial-values tfoot tr").append("<td><div class='slider'></div></td>");
	}
	
	$('.slider').each(function(i,div){$(div).slider({range: "min", min: 1, max: 100})});
    $('#initial-values tbody .slider').each(function(i,div){ $(div).slider('value', scenarios[scenario]["preferences"][i]); });
    $('#initial-values tfoot .slider').each(function(i,div){ $(div).slider('value', scenarios[scenario]["demographic_sizes"][i]); });
	generate_results(scenarios[scenario]["systems"]);
}


function generate_results(systems) {
	$('.slider').unbind('slidechange', generate_results);


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
	if (systems_override != undefined) {
		params["systems[]"] = systems_override;
	} else if (systems != undefined && systems instanceof Array) {
		params["systems[]"] = systems;
	}
	
	timeout = setTimeout(function() {
	   $("#accordion").accordion('destroy');
	   $("#accordion").html('<div class="ui-widget-overlay ui-corner-all" /><p class="waiting"><img src="images/ajax.gif" /></p>');
	}, 300); 
	$.post("elections/results", params,
		function(data) {
		   clearTimeout(timeout);
		    $("#accordion").accordion('destroy');
		    $("#accordion").html(data);
			$("#accordion").accordion({ header: "h3", autoHeight: false, collapsible: true, active: false });
		}
	);
	
	$('.slider').bind('slidechange', generate_results);
	return false;
}
