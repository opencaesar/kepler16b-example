import matplotlib.pyplot as plt
import networkx as nx
import matplotlib.pylab as pl

def draw_graph(data, width=500, height=300):
    # Create an empty graph
    graph = nx.Graph()

    # Extract the columns from the data frame
    columns = list(data.columns)

    # Iterate over the rows of the data frame
    for i, row in data.iterrows():
        srcID = row[columns[0]]
        trgtID = row[columns[1]]

        # Add the source and target nodes to the graph
        graph.add_node(srcID)
        graph.add_node(trgtID)

        # Add an edge between the source and target nodes
        graph.add_edge(srcID, trgtID)

    # Set the positions of the nodes using the spring layout algorithm
    pos = nx.spring_layout(graph, seed=42)

    # Draw the graph
    plt.figure(figsize=(width/100, height/100))
    nx.draw_networkx(graph, pos=pos, with_labels=True, node_color='red', node_size=300, font_size=7, font_weight="bold", font_color='black', arrows=True, arrowstyle='->', arrowsize=10)

    # Set the axis limits
    plt.xlim([-1.1, 1.1])
    plt.ylim([-1.1, 1.1])

    # Remove the axis labels
    plt.axis('off')

    # Show the plot
    plt.show()

def draw_tree(data):
    # Create an empty directed graph
    G = nx.DiGraph()

    # Dictionary to hold name of mission or objective
    m_fullname = dict()
    o_fullname = dict()

    # Add nodes and edges to the graph
    for binding in data["results"]["bindings"]:
        m_id = binding["m_id"]["value"]
        m_fullname[m_id] = binding["m_fullname"]["value"]  # Full name of the M node
        o_id = binding["o_id"]["value"]
        o_fullname[o_id] = binding["o_fullname"]["value"]  # Full name of the O node
        G.add_edge(m_id, o_id)

    # Set node positions for better layout
    seed = 2
    pos = nx.spring_layout(G, seed=seed)

    # Draw the missions or objectives
    nx.draw(G, pos, with_labels=True)

    # shift position a little bit
    shift = [-0.7, 0.13]
    shifted_pos = {node: node_pos + shift for node, node_pos in pos.items()}

    # Just some text to print in addition to node ids
    labels = dict()

    # Create the labels for each mission or objective
    for k, v in enumerate(pos.keys()):
        if v in m_fullname:
            labels[v] = m_fullname[v]
        else:
            labels[v] = o_fullname[v]

    # Draw the mission or objectives labels
    nx.draw_networkx_labels(G, shifted_pos, font_color="red", font_size=8, labels=labels, horizontalalignment="left", verticalalignment="center")

    # adjust frame to avoid cutting text, may need to adjust the value
    axis = pl.gca()
    axis.set_xlim([1.75*x for x in axis.get_xlim()])
    axis.set_ylim([1.75*y for y in axis.get_ylim()])

    # turn off frame
    pl.axis("off")

    # Show Tree
    pl.show()