/**
 * create a D3 based Tree table
 */
function transform(tableData){
	var transformed = {};
	var columns = data.head.vars;
	transformed.roots = [];
	transformed.columns = columns;
	var rootsMap = [];
	tableData.forEach(item => {
	  var parentID = item[columns[0]].value;
	  var parentName = item[columns[1]].value;
	  var childID = item[columns[2]].value;
	  var childName = item[columns[3]].value;
	  var parent = rootsMap[parentID];
	  if (!parent){
		parent = {}
		parent[columns[0]] = parentID;
		parent[columns[1]] = parentName;
		transformed.roots.push(parent);
		rootsMap[parentID] = parent;
		parent.children = [];
	  }
	  var child = {};
	  child[columns[2]] = childID;
	  child[columns[3]] = childName;
	  parent.children.push(child);
	});
	return transformed;
}

function treeTable(data, containerID) {
	var treeData = transform(data.results.bindings);
	var container = d3.select(containerID);
	var mainDiv = container.append('div');
	var columns = treeData.columns;

	var sections = mainDiv
		.selectAll('details').data(treeData.roots).enter().append('details')
		.classed("collapsible", true)
		.attr("open", true);
	
	sections.append('summary').text(function (d) { 
		return d[columns[1]];
	 });

	groups = sections.selectAll('ul')
		.data(function (row) {
			return  [row];
		}).enter().append('ul').classed("content",true);
		
	content = groups.selectAll('li')
		.data(function (row) { 
			return row.children; 
		}).enter().append('li').text(function (d) {
			 return "        " + d[columns[3]]; 
		}).classed("content",true);
 
  	return table;
}


