/**
 * 
 */

seperators = ['#','/'];
tabulate(data,'#tableViz');
drawTreeMap(data,'#treeMapViz',['#','/']);
drawTree(massTransForm(data,seperators),'#treeViz',seperators,false);

function massTransForm(data, nameSeperators){
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

	function transform(data,nameSeperators){
		var idToNode = [];
		var root = getOrCreateNode("-1","Root",idToNode);
		root.parent = null;
		var columns = data.head.vars;
		data.results.bindings.forEach(item => {
			var parentID = item[columns[4]] ? item[columns[4]].value : "-1";
			var parentName = getName(item[columns[3]] ? item[columns[3]].value : "root",nameSeperators);
			var elementID = item[columns[1]].value;
			var elementName = getName(item[columns[0]].value,nameSeperators);
			var mass = item[columns[2]] ? item[columns[2]].value : "0";
			getOrCreateNode(parentID,parentName,idToNode);
			var node = addNode(parentID,elementID,elementName,idToNode);
			node.value = parseInt(mass);
		});	
		return root;
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
	return transform(data,nameSeperators);
}
