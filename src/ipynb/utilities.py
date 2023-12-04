import json
import pandas as pd
from plantuml import PlantUML
from IPython.display import Markdown, HTML
from string import Template
import igraph as ig

def dataframe(fileName):
    data = json.load(open("../../build/results/"+fileName))
    columns = data["head"]["vars"]
    rows = data['results']['bindings']
    df = pd.DataFrame(rows)
    df = df.map(lambda x: x["value"] if not pd.isna(x) else x)
    return df

def todict(df, column1, column2):
    result = df.set_index(column1)[column2].to_dict()
    return {key: value for (key, value) in result.items() if not pd.isna(value)}

def tolist(df, column):
    return df[column].tolist()

def tolists(df, *columns):
    result = df[list(columns)].values.tolist()
    return list(filter(lambda x: not any(filter(lambda y: pd.isna(y), x)), result))

def union(dict1, dict2):
    result = dict1.copy()
    for key, value in dict2.items():
        if key not in result:
            result[key] = value
    return result

def objects(objects, relations, type, stereotype=None):
    uml = "set separator none\n"
    for key, value in objects.items():
        uml += 'object "'+key+': '+value+'" as '+key+(' <<'+stereotype+'>>' if stereotype is not None else '')+'\n'
    for row in relations:
        uml += row[0]+' '+type+' '+row[1]+'\n'
    return uml

def diagram(str):
    url = PlantUML("http://www.plantuml.com/plantuml/img/").get_url(str)
    return Markdown("![Alt text]({})".format(url))

def graph(nodes, relations, property, values):
	edges = [(nodes.index(x), nodes.index(y)) for x, y in relations]
	graph = ig.Graph(n=len(nodes), edges=edges, directed=True)
	graph.vs[property] = values
	return graph

def rollup_vertex(graph, vertex_id, property):
    vertex = graph.vs[vertex_id]
    
    # If it's a leaf node, return its mass
    if graph.outdegree(vertex_id) == 0:
        return vertex["mass"]
    
    # Calculate mass recursively for children
    total_mass = 0
    for child_id in graph.successors(vertex_id):
        total_mass += rollup_vertex(graph, child_id, property)
    
    # Update the vertex's mass and return the accumulated mass
    vertex[property] += total_mass
    return total_mass

def rollup(nodes, relations, property, values):
	g = graph(nodes, relations, property, values)
	root_ids = g.vs.select(_indegree=0).indices
	for root_id in root_ids:
		rollup_vertex(g, root_id, property)
	return g

tree = Template('''
<style>
.node circle {
fill: #fff;
stroke: steelblue;
stroke-width: 3px;
}
.node text {
font: 12px sans-serif;
}
.link {
fill: none;
stroke: #ccc;
stroke-width: 1px;
}
</style>
<div id='figure3'></div>
<script type="module">
import * as d3 from "https://cdn.jsdelivr.net/npm/d3@7/+esm";
function drawTree(data, containerID, root_name, unique=true, _width=960, _height=500, depthMultiplier=180) {

	function getOrCreateNode(id, name, dict){
		var node = dict[id];
		if (!node){
			node = {}
			node.id  = id;
			node.name = name;
			dict[id] = node;
		}
		return node;
	}
	
	function addNode(parentid, id, name, dict){
		var parent = dict[parentid];
		var node = dict[id];
		if (!node){
			node = getOrCreateNode(id,name,dict);
			node.parent = parent.id;
			if (!parent.children){
				parent.children = [];
			}
			parent.children.push(node);
		}
		return node;
	}
	
	function transform(data){
		var idToNode = [];
		var root = getOrCreateNode("-1",root_name,idToNode);
		root.parent = "null";
		var columns = [ "m_id" , "m_name" , "o_id" , "o_name" ];
		data.forEach(row => {
			var parent_id = "-1";
			for (let i = 0; i < columns.length/2; i++) {
				if (row[columns[2*i]]) {
					var childId = (!unique ? parent_id+"." : "") +row[columns[2*i]];
					addNode(parent_id, childId, row[columns[2*i]]+" "+row[columns[2*i+1]], idToNode);
					parent_id = childId;
				}
			}
		});	
		return root;
	}
	
	function getVal(d){
		return d.value + (d.children ? d.data.value : 0);
	}

	
	var treeData = transform(data);

	// ************** Generate the tree diagram	 *****************
	var margin = {top: 20, right: 120, bottom: 20, left: 120},
		width = _width - margin.right - margin.left,
		height = _height - margin.top - margin.bottom;
		
	var i = 0,
		root;
		
		
	var root = d3.hierarchy(treeData)
			.sum(d => d.value)
			.sort((a, b) => b.value - a.value)
			
	var tree = d3.tree();
	tree.size([height, width]); 
	var diagonal = d3.linkHorizontal().x(d => d.y).y(d => d.x)
	
	var svg = d3.select(containerID).append("svg")
		.attr("width", width + margin.right + margin.left)
		.attr("height", height + margin.top + margin.bottom)
	  .append("g")
		.attr("transform", "translate(" + margin.left + "," + margin.top + ")");


  	const gLink = svg.append("g")
      .attr("fill", "none")
      .attr("stroke", "#555")
      .attr("stroke-opacity", 0.4)
      .attr("stroke-width", 1.5);

	root.x0 = height / 2;
	root.y0 = 0;

	function update(source) {
	    const duration = d3.event && d3.event.altKey ? 2500 : 250;
	    const nodes = root.descendants().reverse();
	    const links = root.links();
	
	    // Compute the new tree layout.
	    tree(root);
	
	    let left = root;
	    let right = root;
	    root.eachBefore(node => {
	      if (node.x < left.x) left = node;
	      if (node.x > right.x) right = node;
	    });

		// Normalize for fixed-depth.
	    nodes.forEach(function(d) { d.y = d.depth * depthMultiplier; });

	
	    const height = right.x - left.x + margin.top + margin.bottom;
	
	    const transition = svg.transition()
	        .duration(duration);
	
	 	// Update the nodes…
	  	var node = svg.selectAll("g.node")
		  .data(nodes, function(d) { return d.id || (d.id = ++i); });

	
	    // Enter any new nodes at the parent's previous position.
	    const nodeEnter = node.enter().append("g")
	        .attr("transform", function(d) { return "translate(" + source.y0 + "," + source.x0 + ")"; })
		  	.attr("class", "node")
	        .on("click", click);
	
	    nodeEnter.append("circle")
 		  .attr("r", 1e-6)
		  .style("fill", function(d) { return d._children ? "lightsteelblue" : "#fff"; });

	
	    nodeEnter.append("text")
	        .attr("dy", "0.35em")
	        .attr("x", function(d) { return d.children || d._children ? -13 : 13; })
	        .attr("text-anchor", function(d) { return d.children || d._children ? "end" : "start"; })
	        .text(function(d){
				return d.data.name;
			});
	
	    // Transition nodes to their new position.
	    const nodeUpdate = node.merge(nodeEnter).transition(transition)
		  	.attr("transform", function(d) { return "translate(" + d.y + "," + d.x + ")"; });

		nodeUpdate.select("circle")
		  .attr("r", 10)
		  .style("fill", function(d) { return d._children ? "lightsteelblue" : "#fff"; });

		nodeUpdate.select("text")
		  .style("fill-opacity", 1);
	    
		// Transition exiting nodes to the parent's new position.
	    const nodeExit = node.exit().transition(transition)
		  .attr("transform", function(d) { return "translate(" + source.y + "," + source.x + ")"; })
		  .remove();

		nodeExit.select("circle")
		  .attr("r", 1e-6);
	
	  	nodeExit.select("text")
		  .style("fill-opacity", 1e-6);
	
	    // Update the links…
	    const link = gLink.selectAll("path")
	      .data(links, d => d.target.id);
	
	    // Enter any new links at the parent's previous position.
	    const linkEnter = link.enter().append("path")
			.attr("class", "link")
	        .attr("d", d => {
	          const o = {x: source.x0, y: source.y0};
	          return diagonal({source: o, target: o});
	        });
	
	    // Transition links to their new position.
	    link.merge(linkEnter).transition(transition)
	        .attr("d", diagonal);
	
	    // Transition exiting nodes to the parent's new position.
	    link.exit().transition(transition).remove()
	        .attr("d", d => {
	          const o = {x: source.x, y: source.y};
	          return diagonal({source: o, target: o});
	        });
	
	    // Stash the old positions for transition.
	    root.eachBefore(d => {
	      d.x0 = d.x;
	      d.y0 = d.y;
	    });
	 }

  	update(root);

	// Toggle children on click.
	function click(event, d) {
	  if (d.children) {
		d._children = d.children;
		d.children = null;
	  } else {
		d.children = d._children;
		d._children = null;
	  }
	  update(d);
	}
}
var data = $data
drawTree(data, '#figure3', "Missions", false, 960, 300, 150)
</script>
''')
