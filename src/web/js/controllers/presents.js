/**
 * Aggregates visualsations
 */

// render the table(s)
tabulate(data,'#tableViz');

function getOrCreateNode(id, name,nodes, dict){
	var node = dict[id];
	if (!node){
		node = {}
		node.id  = id;
		node.name = name;
		nodes.push(node);
		dict[id] = node;
	}
	return node;
}

function toGraphData(data){
	var graph = {};
	var nodes = graph.nodes = [];
	var links = graph.links = [];
	var idToNode = [];
	var columns = data.head.vars;
	data.results.bindings.forEach(item => {
		var srcID = item[columns[0]].value;
		var trgtID = item[columns[1]].value;
		var src = getOrCreateNode(srcID,srcID,nodes,idToNode);
		var trgt = getOrCreateNode(trgtID,trgtID,nodes,idToNode);
		var link = {};
		link.source = src.id;
		link.target = trgt.id;
		links.push(link);
	});	
	return graph;
}

var graphData = toGraphData(data);
drawGraph(graphData,"#graphViz",false);



