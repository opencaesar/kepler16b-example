/**
 * create a D3 based Tree table
 */

function treeTable(data, containerID) {
	var container = d3.select(containerID);
	var mainDiv = container.append('div');
	var columns = data.columns;

	var sections = mainDiv.selectAll('details').data(data.roots).enter().append('details')
					.classed("collapsible", true);
	
	sections.append('summary').text(function (d) {
	  			 		return d[columns[1]];
	  					});

	groups = sections.selectAll('ul').data(function (row) {
					return  [row];
	  			}).enter().append('ul').classed("content",true);
	groups.selectAll('li')
				.data(function (row) {
	    			return row.children;
	  			}).enter().append('li').text(function (d) {
	  			 	return "        " + d[columns[3]] + " : " + d[columns[2]] ;
	  		}).classed("content",true);
 
  	return table;
}


