function rollup(data, columns) {
    var id1 = columns[0];
    var name1 = columns[1];
    var id2 = columns[2];
    var name2 = columns[3];
    var value = columns[4];

    const nodes = {};
    data.results.bindings.forEach((item) => {
        if (!nodes[item[id1].value]) {
            nodes[item[id1].value] = {value: 0, parent: null, children: [] };
        }
        if (item[value]) {
            nodes[item[id1].value].value = parseInt(item[value].value);
        }
        if (item[id2]) {
            nodes[item[id2].value] = {value: 0, parent: null, children: [] };
            nodes[item[id2].value].parent = nodes[item[id1].value];
            nodes[item[id1].value].children.push(nodes[item[id2].value]);
        }
    });
    Object.values(nodes).forEach((node) => {
        if (node.parent == null) {
            visit(node);
          }
    });
    data.head.vars = data.head.vars.filter(item => item !== value);
    data.results.bindings.forEach(item => {
        if (item[value]) {
            delete item[value];
        }
        item[name1].value += " ("+nodes[item[id1].value].value+")";
        if (item[name2]) {
            item[name2].value += " ("+nodes[item[id2].value].value+")";
        }
    });
    return data;
}

function visit(node) {
    if (node.children.length !== 0) {
        node.children.forEach((child) => visit(child));
        node.value = node.children.reduce((acc, child) => acc + child.value, 0);
    }
}