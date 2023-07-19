# Objectives # {#Objectives}

The Kepler13b project is pursuing multiple objectives shown in the table below. This is a test.

<div id='figure1'></div>
<script type="text/javascript" src="json/objectives1.json"></script>
<script>tabulate(data, '#figure1');</script>
<figcaption>Kepler16b Objectives</figcaption>

Those objectives aggregate each other as depicted in the graph below.

<div id='figure2'></div>
<script type="text/javascript" src="json/objectives2.json"></script>
<script>drawGraph(data, '#figure2', 500, 200)</script>
<figcaption>Kepler16b Objective Aggregation</figcaption>

# Missions # {#Missions}

ُThe Kepler16b project delivers the following missions, each of which pursues a subset of the objectives above.

<div id='figure3'></div>
<script type="text/javascript" src="json/missions2.json"></script>
<script>drawTree(data, '#figure3', "Missions", false, 960, 300, 150)</script>
<figcaption>Kepler16b Missions Pursuing Objectives</figcaption>

# Components # {#Components}

Each of the Kelper16 missions deploy a number of important components as shown below.

<div id='figure4'></div>
<script type="text/javascript" src="json/components2.json"></script>
<script>treeTable(data, '#figure4')</script>

Those components have the following physical decomposition.

<div id='figure5'></div>
<script type="text/javascript" src="json/components1.json"></script>
<script>drawTree(data, '#figure5', "Components", true, 960, 350, 250)</script>
<figcaption>Kepler16b Component Decomposition</figcaption>

# Masses # {#Masses}

The Kepler16b components have the following mass characterizations in (kg) rolled up for each composite component.

<div id='figure6'></div>
<script type="text/javascript" src="json/masses.json"></script>
<script>drawTree(rollup(data, ["c1_id", "c1_fullname", "c2_id", "c2_fullname", "c1_mass"]), '#figure6', "Mass Rollup", true, 960, 350, 250)</script>
<figcaption>Kepler16b Mass Characterization and Rollup</figcaption>

# Interfaces # {#Interfaces}

Several of Kepler16b components present interfaces as follows.

<div id='figure7'></div>
<script type="text/javascript" src="json/interfaces.json"></script>
<script>treeTable(data, '#figure7')</script>

# Junctions # {#Junctions}

The Kepler16b components' interfaces are joined together with the following junctions.

<div id='figure8'></div>
<script type="text/javascript" src="json/junctions.json"></script>
<script>tabulate(data, '#figure8')</script>

# Requirements # {#Requirements}

The Kepler16b project specifies the following requirements.

<div id='figure9'></div>
<script type="text/javascript" src="json/requirements1.json"></script>
<script>tabulate(data, '#figure9')</script>

Some of the requirements specify that some components shall present interfaces as follows.

<div id='figure10'></div>
<script type="text/javascript" src="json/requirements2.json"></script>
<script>tabulate(data, '#figure10')</script>

Some of the requirements refine others as follows.

<div id='figure11'></div>
<script type="text/javascript" src="json/requirements3.json"></script>
<script>drawGraph(data, '#figure11', 500, 300)</script>
<figcaption>Kepler16b Requirement Refinement</figcaption>
