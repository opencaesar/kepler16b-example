

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
		var columns = data.head.vars;
		data.results.bindings.forEach(item => {
			var parent_id = "-1";
			for (let i = 0; i < columns.length/2; i++) {
				if (item[columns[2*i]]) {
					var childId = (!unique ? parent_id+"." : "") +item[columns[2*i]].value;
					addNode(parent_id, childId, item[columns[2*i+1]].value, idToNode);
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