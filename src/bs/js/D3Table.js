/**
 * create a D3 based table
 */

function tabulate(data, containerID) {
	var container = d3.select(containerID);
	var table = container.append('table');
	table.attr("id","table");
	var thead = table.append('thead');
	var	tbody = table.append('tbody');
	var columns = data.head.vars;

	// append the header row
	thead.append('tr')
	  .selectAll('th')
	  .data(columns).enter()
	  .append('th')
	    .text(function (column) { return column; });

	// create a row for each object in the data
	var rows = tbody.selectAll('tr')
	  .data(data.results.bindings)
	  .enter()
	  .append('tr');

	// create a cell in each row for each column
	var cells = rows.selectAll('td')
	  .data(function (row) {
	    return columns.map(function (column) {
	      return {column: column, value: row[column] ? row[column].value : ""};
	    });
	  })
	  .enter()
	  .append('td')
	    .text(function (d) { return d.value; });

  return table;
}


