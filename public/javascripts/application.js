// Place your application-specific JavaScript functions and classes here
// This file is automatically included by javascript_include_tag :defaults

$(document).ready(function(){
	$('.slider').each(function(i,div){$(div).slider({range: "min", min: 1, max: 100})});
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
	alert("To do: remove specified entity");
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
		$('.slider').unbind('slidechange', generate_results);
		$('.slider').bind('slidechange', generate_results);
		generate_results();
	}
	return false;
}



function load_scenario(scenario) {
	
	scenarios = new Array;
    scenarios["splitting"] = new Array;
	scenarios["splitting"]["candidates"] = ["Candidate A", "Candidate B", "Candidate C"];
	scenarios["splitting"]["demographics"] = ["Demographic X", "Demographic Y", "Demographic Z"];
	scenarios["splitting"]["demographic_sizes"] = [34,33,33];
	scenarios["splitting"]["preferences"] = [80,20,20,
											 50,75,65,
											 70,70,75];
	
	scenarios["tactical"] = new Array;
	scenarios["tactical"]["candidates"] = ["Candidate A", "Candidate B", "Candidate C"];
	scenarios["tactical"]["demographics"] = ["Demographic X", "Demographic Y", "Demographic Z"];
	scenarios["tactical"]["demographic_sizes"] = [80,50,35];
	scenarios["tactical"]["preferences"] = [80,20,10,
											20,80,20,
											40,40,80];

	scenarios["ignored"] = new Array;
	scenarios["ignored"]["candidates"] = ["Candidate A", "Candidate B", "Candidate C"];
	scenarios["ignored"]["demographics"] = ["Demographic X", "Demographic Y", "Demographic Z"];
	scenarios["ignored"]["demographic_sizes"] = [80,50,35];
	scenarios["ignored"]["preferences"] = [80,20,20,
										   20,80,50,
										   50,50,80];
	
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
    $('.slider').unbind('slidechange', generate_results);
    $('#initial-values tbody .slider').each(function(i,div){ $(div).slider('value', scenarios[scenario]["preferences"][i]); });
    $('#initial-values tfoot .slider').each(function(i,div){ $(div).slider('value', scenarios[scenario]["demographic_sizes"][i]); });
    $('.slider').bind('slidechange', generate_results);
	generate_results();
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
