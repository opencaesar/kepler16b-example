/**
 * Aggregates visualsations
 */

// render the table(s)
tabulate(data,'#tableViz');

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


var treeData = transform(data.results.bindings);
treeTable(treeData,"#treeTableViz");
drawGraph(data,"#graphViz");



