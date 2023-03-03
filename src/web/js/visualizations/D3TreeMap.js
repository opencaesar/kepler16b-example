

function drawTreeMap(data, containerID, nameSeperators = [],WIDTH = 800, HEIGHT=800) {

	function getOrCreateNode(id, name, dict){
		var node = dict[id];
		if (!node){
			node = {}
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
			if (!parent.children){
				parent.children = [];
			}
			parent.children.push(node);
		}
		return node;
	}

	function getName(name, nameSeperators){
		var newName = name;
		for (const nameSeperator of nameSeperators){
			var index = newName.lastIndexOf(nameSeperator);
			if (index!=-1){
				return name.substring(index+1);
			}
		}
		return newName;
	}
	
	function transform(data,nameSeperators){
		var idToNode = [];
		var root = getOrCreateNode("-1","root",idToNode);
		var columns = data.head.vars;
		data.results.bindings.forEach(item => {
			var containerID = item[columns[4]] ? item[columns[4]].value : "-1";
			var containerName = getName(item[columns[3]] ? item[columns[3]].value : "root",nameSeperators) ;
			var childID = item[columns[1]].value;
			var childeName = getName(item[columns[0]] ? item[columns[0]].value : "",nameSeperators);
			var mass = item[columns[2]]?item[columns[2]].value : "0";
			addNode("-1",containerID,containerName,idToNode);
			var child = addNode(containerID,childID,childeName,idToNode);
			child.value = parseInt(mass);
		});	
		return root;
	}
	
	function getVal(d){
		return d.value + (d.children ? d.data.value : 0);
	}
	
	var treeData = transform(data, nameSeperators);
	
	var margin = {top: 10, right: 10, bottom: 10, left: 10},
  		width = WIDTH - margin.left - margin.right,
  		height = HEIGHT - margin.top - margin.bottom;

	// append the svg object to the container
	var svg = d3.select(containerID).append("svg");
	
	svg.style('font-family', 'sans-serif')
	   .attr('width', width)
       .attr('height', height)

  	const g = svg.append('g').attr('class', 'treemap-container')
	
	var root = d3.hierarchy(treeData)
    			.sum(d => d.value)
    			.sort((a, b) => b.value - a.value)
	
	colorScale = d3.scaleOrdinal( d3.schemeSet2 )

	d3.treemap()
    .size([ width, height ])
    .padding(2)
    .paddingTop(10)
    .round(true)(root);

    // Place the labels for our Root elements (if they have children)
   g.selectAll('text.title')
    // The data is the first "generation" of children
    .data( root.children.filter(function(d){return d.children!=null}) )
    .join('text')
      .attr('class', 'title')
      // The rest is just placement/styling
      .attr('x', d => d.x0)
      .attr('y', d => d.y0)
      .attr('dy', '0.6em')
      .attr('dx', 3)
      .style('font-size', 12)
    // Remember, the data on the original node is available on node.data (d.data here)
    .text(d => d.data.name + " (" +  getVal(d) + ")")

 // Now, we place the groups for all of the leaf nodes
  const leaf = g.selectAll('g.leaf')
    // root.leaves() returns all of the leaf nodes
    .data(root.leaves())
    .join('g')
      .attr('class', 'leaf')
      // position each group at the top left corner of the rect
      .attr('transform', d => `translate(${ d.x0 },${ d.y0 })`)
      .style('font-size', 10)

  // A title element tells the browser to display its text value
  // in a popover when the cursor is held over a rect. This is a simple
  // way to add some interactivity
  leaf.append('title')
    .text(d => `${ d.parent.data.name }-${ d.data.name }\n${ d.value.toLocaleString()}`)

  // Now we append the rects. Nothing crazy here
  leaf.append('rect')
      .attr('fill', d => colorScale(d.parent.data.name))
      .attr('opacity', 0.7)
      // the width is the right edge position - the left edge position
      .attr('width', d => d.x1 - d.x0)
      // same for height, but bottom - top
      .attr('height', d => d.y1 - d.y0)
      // make corners rounded
      .attr('rx', 3)
      .attr('ry', 3)

  // This next section checks the width and height of each rectangle
  // If it's big enough, it places labels. If not, it doesn't.
  leaf.each((d, i, arr) => {
    // The current leaf element
    const current = arr[i]
    
    const left = d.x0,
          right = d.x1,
          // calculate its width from the data
          width = right - left,
          // calculate its height from the data
          height = d.y1 - d.y0

    // too small to show text
    const tooSmall = width < 34 || height < 25
    
    const text = d3.select( current ).append('text')
        // If it's too small, don't show the text
        .attr('opacity', tooSmall ? 0 : 0.9)
      .selectAll('tspan')
      .data(d => [ d.data.name, d.value.toLocaleString() ])
      .join('tspan')
        .attr('x', 3)
        .attr('y', (d,i) => i ? '2.5em' : '1.15em')
        .text(d => d)

 	 });

	svg.call(d3.zoom()
      .extent([[0, 0], [width, height]])
      .scaleExtent([1, 8])
      .on("zoom", zoomed));

	function zoomed({transform}) {
	   g.attr("transform", transform);
	}
}