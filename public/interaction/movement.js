let onHover = false;
let onWasd = false;
let onTransition = false;
let onSpace = true;
let currentWeight = 0;
let currentWeightTime = 1000;
let maxWeight = 100;
let maxDegree = 100;
let maxCit = 800;
let repulsionVal = 20;
//=================================================================================
//Graph Behaviour
//=================================================================================

//=================================================================================
//Attraction TODO NOT IN USE
//=================================================================================
function attractNeighbors(node, graph) {
    // Find connected nodes
    const connectedNodes = new Set(
    data.links
        .filter(link => link.source.id === node.id || link.target.id === node.id)
        .map(link => (link.source.id === node.id ? link.target : link.source))
    );

    // Apply force to attract neighbors to the clicked node
    graph
    .d3Force('attract', d3.forceManyBody()
        .strength(n => (connectedNodes.has(n) ? 50 : 0)) // Only attract neighbors
    );
    graph
        .d3Force('x', d3.forceX(n => (n.highlighted ? node.x : n.x)).strength(0.2))
        .d3Force('y', d3.forceY(n => (n.highlighted ? node.y : n.y)).strength(0.2));

    graph
    .d3Force('x', d3.forceX(n => (connectedNodes.has(n) ? node.x : n.x)).strength(2))
    .d3Force('y', d3.forceY(n => (connectedNodes.has(n) ? node.y : n.y)).strength(2));

    // graph.restart(); // Restart simulation with new forces
}
//=================================================================================
//Repulsion TODO
//=================================================================================

//=================================================================================

//User interaction

//=================================================================================

//==================================================

// WASD

//==================================================

function findClosestNodeInDirection(currentNodeId, direction, graph) {
  if (!onWasd)return null;
  if (!currentNodeId || !direction || !graph) return null;
  if (!['up', 'down', 'left', 'right'].includes(direction)) return null;
  
  const nodes = graph.graphData().nodes;
  if (!nodes || nodes.length === 0) return null;

  // Find the current node by ID instead of using stale reference
  const currentNode = nodes.find(node => node.id === currentNodeId);
  // console.log("CURRENT NODE IS", currentNode)
  if (!currentNode) {
    console.warn(`Current node with ID ${currentNodeId} not found in graph data`);
    return null;
  }
  // Ensure we have valid coordinates (force simulation might still be running)
  if (currentNode.x === undefined || currentNode.y === undefined) {
      console.warn('Current node coordinates not yet available');
      return null;
  }

  const currentX = currentNode.x ?? 0;
  const currentY = currentNode.y ?? 0;

  function isInDirection(angle, targetDirection) {
  // Normalize angle to range [0, 2π)
  const a = (angle + 2 * Math.PI) % (2 * Math.PI);

  const ranges = {
    'right': [7 * Math.PI / 4, Math.PI / 4],      // 315°–45°
    'up': [Math.PI / 4, 3 * Math.PI / 4],         // 45°–135°
    'left': [3 * Math.PI / 4, 5 * Math.PI / 4],   // 135°–225°
    'down': [5 * Math.PI / 4, 7 * Math.PI / 4],   // 225°–315°
  };

  const [start, end] = ranges[targetDirection];

  if (start < end) {
    return a >= start && a <= end;
  } else {
    // Handles wrap-around (e.g., right: 315°–45°)
    return a >= start || a <= end;
  }
}

  const MIN_DISTANCE_SQUARED = 0;
  let closest = null;
  let closestDistanceSquared = Infinity;

  for (const node of nodes) {
    // console.log("Node count:", nodes.length, "Unique IDs:", new Set(nodes.map(n => n.id)).size);

    if (node.id === currentNodeId) continue; // Compare by ID, not reference

    const nodeX = node.x ?? 0;
    const nodeY = node.y ?? 0;
    
    const dx = nodeX - currentX;
    const dy = nodeY - currentY;
    
    const distanceSquared = dx * dx + dy * dy;
    if (distanceSquared < MIN_DISTANCE_SQUARED) continue;

    const angle = Math.atan2(-dy, dx);
    
    if (isInDirection(angle, direction) && distanceSquared < closestDistanceSquared) {
      closest = node;
      closestDistanceSquared = distanceSquared;
    }
  }
  // console.log('WASD triggered with current node:', currentNodeId);
  // console.log('Available nodes:', nodes.map(n => ({ id: n.id, x: n.x, y: n.y })));
  // console.log('Direction:', direction);
  // console.log('Current position:', { x: currentX, y: currentY });
  // console.log('Next node', closest)

  // Allora la posizione è quella del nodo giusto ma ne seleziona un'altro sbagliato,
  // sembra quasi che faccia più di uno step
  // console.log('END --------')
  return closest; // Returns the fresh node object from current graph data
}

//==================================================

// Transition

//==================================================
// Function to handle node selection with shift key
function shiftSelection(node, graph,degree) {
  if (!onTransition) return null;
  if (shiftKeyPressed) {
    // console.log("WELA")
  // If an animation is in progress, cancel it
  if (animationInProgress) {
    selectedNodes = [];
    selectedNode = null;
    highlightedPath = [];
    clearActiveAnimations();
    clearTransitionAnimations();
    clearTimeout(animationTimer);
    animationInProgress = false;
    highlightedPath = [];
  }

  // If node is already selected, deselect it
  const index = selectedNodes.indexOf(node);
  if (index !== -1) {
    selectedNodes.splice(index, 1);
  } else {
    // Add node to selection (max 2 nodes)
    if (selectedNodes.length < 2) {
      selectedNodes.push(node);
    } else {
      // Replace the second node
      selectedNodes[1] = node;
    }
  }
  
  // Update node colors based on selection
  updateNodeColors(graph);
  
  // If exactly 2 nodes are selected, trigger your function
  if (selectedNodes.length === 2) {
    connectSelectedNodes(selectedNodes, graph, degree);
  }
  } else {
        // console.log("AZZ")
    // Regular selection behavior (single node)
    selectNode(node, true, graph);
  }
}

// Function to select a single node
function selectNode(node, centerView = false, graph) {
  // If an animation is in progress, cancel it
  if (animationInProgress) {
    clearTimeout(animationTimer);
    animationInProgress = false;
    highlightedPath = [];
  }
  // Clear multi-selection
  selectedNodes = [];
  // Set single selected node
  selectedNode = node;
  // Update colors
  updateNodeColors(graph);
  // Only center if explicitly requested
  if (centerView) {
    graph.centerAt(node.x, node.y, 300);
  }
}

// Function to update node colors based on selection state
function updateNodeColors(graph) {
  graph.nodeColor(n => {
    if (selectedNodes.length > 0) {
      // Multi-selection mode
      return selectedNodes.includes(n) ? 'red' : 'gray';
    } else {
      // Single selection mode
      return n === selectedNode ? 'red' : 'gray';
    }
  });
  
  // Update link colors based on highlighted path
  graph.linkColor(link => {
    return highlightedPath.some(pathLink => 
      (pathLink.source === link.source && pathLink.target === link.target) || 
      (pathLink.source === link.target && pathLink.target === link.source)
    ) ? 'rgba(236, 131, 139, 0.5)' : linkStaticColor;
  });
}

// Find shortest path between two nodes using BFS
function findShortestPath(startNode, endNode, graph) {
  // Get the graph data
  const nodes = graph.graphData().nodes;
  const links = graph.graphData().links;
  console.log(links)
  
  // Create an adjacency list representation of the graph
  const adjacencyList = {};
  nodes.forEach(node => {
    adjacencyList[node.id] = [];
  });
  
  links.forEach(link => {
    const source = typeof link.source === 'object' ? link.source.id : link.source;
    const target = typeof link.target === 'object' ? link.target.id : link.target;
    adjacencyList[source].push({node: target, link: link});
    adjacencyList[target].push({node: source, link: link}); // For undirected graph
  });
  
  // BFS implementation
  const queue = [{node: startNode.id, path: [], links: []}];
  const visited = new Set([startNode.id]);
  
  while (queue.length > 0) {
    const {node, path, links} = queue.shift();
    
    if (node === endNode.id) {
      return {
        path: [...path, node],
        links: links
      };
    }
    
    adjacencyList[node].forEach(neighbor => {
      if (!visited.has(neighbor.node)) {
        visited.add(neighbor.node);
        queue.push({
          node: neighbor.node, 
          path: [...path, node],
          links: [...links, neighbor.link]
        });
      }
    });
  }
  
  // No path found
  return {path: [], links: []};
}

// Function that triggers when two nodes are selected
function connectSelectedNodes(nodes, graph, degree) {
  console.log("Two nodes selected:", nodes);
  
  // Find the shortest path between selected nodes
  const {path, links} = findShortestPath(nodes[0], nodes[1], graph);
  
  if (path.length === 0) {
    console.log("No path found between selected nodes");
    return;
  }
  
  console.log("Shortest path:", path);
  sendOSCMessage(nodes[0], '/additive', degree[nodes[0].id]);
  console.log("Path links:", links);
  
  // Start animation
  animatePathTraversal(path, links, graph, degree);
}

// Function to animate the path traversal
function animatePathTraversal(nodePath, linkPath, graph, degree) {
  // Clear any existing animation
  if (animationTimer) {
    clearTimeout(animationTimer); // Change clearInterval to clearTimeout
  }
  
  animationInProgress = true;
  highlightedPath = [];
  let currentStep = 0;
  
  // Get node objects from their IDs
  const nodeObjects = graph.graphData().nodes;
  const nodeMap = {};
  nodeObjects.forEach(node => {
    nodeMap[node.id] = node;
  });
  
  // Animation function that calls itself recursively with dynamic timeout
  function animateStep() {
    if (currentStep >= linkPath.length) {
      // Animation completed
      animationInProgress = false;
      sendOSCStopMessage('/additive');
      return;
    }
    
    // Add the next link to the highlighted path
    highlightedPath.push(linkPath[currentStep]);
    
    // Highlight current node in the path
    // It's actually the next node but I have to light up that one
    const currentNodeId = nodePath[currentStep + 1];

    const currentNode = nodeMap[currentNodeId];
    document.getElementById("content").innerText = currentNode["description"];
    document.getElementById("currentCluster").innerText = currentNode["cluster"];
    currentWeight = getWeightBetweenNodesWithDefault(graph.graphData(), nodePath[currentStep], currentNodeId);
    currentWeightTime = mapNumRange(currentWeight, 0, maxWeight, 500, 20000);
    // console.log("The weight is: ", currentWeight);
    // Send OSC message
    sendOSCMessage(currentNode, '/additive', degree[currentNode.id]);
    
    // Center on current node
    graph.centerAt(currentNode.x, currentNode.y, 300);
    selectedNodes.push(currentNode);
    // Update colors
    updateNodeColors(graph);
    
    // Calculate the delay for the next step based on current node's citations
    // const nextNodeId = nodePath[currentStep + 1];

    // const nextDelay = mapNumRange(currentWeight, 0, maxWeight,500,10000);
    const nextDelay = currentWeightTime;
    // Move to next step with dynamic timeout
    currentStep++;
    
    // Set the next timeout with dynamic delay
    animationTimer = setTimeout(animateStep, nextDelay);
  }
  
  // First weight  
  const firstWeight = getWeightBetweenNodesWithDefault(graph.graphData(), nodePath[0], nodePath[1]);

  // Start the animation with the first node's delay
  const firstDelay = mapNumRange(firstWeight, 0, maxWeight, 500, 20000);

  console.log("First Delay", firstDelay);
  animationTimer = setTimeout(animateStep, firstDelay);
}

//==================================================

// Bubbles

//==================================================

// Function to Higlight the Neighbors of a node (Not in use)
function highlightNeighbors(node, graph) {
    // Find connected nodes
    const connectedNodes = new Set(
        data.links
        .filter(link => link.source.id === node.id || link.target.id === node.id)
        .map(link => (link.source.id === node.id ? link.target : link.source))
    );
    
    // Update node properties for highlighting
    data.nodes.forEach(n => {
        n.highlighted = n.id === node.id || connectedNodes.has(n);
    });

    graph.nodeColor(node => node.highlighted ? 'red' : 'gray'); // Change color dynamically
    // graph.refresh(); // Refresh the graph
}

let activeTimeouts = []; // Array to store all active timeouts

// Function to Higlight the Neighbors of a node in time
function highlightNeighborsGradually(node, graph, degree, data) {
    if (!onSpace)return null;
    // Find connected nodes
    // console.log(degree[node.id])
    clearActiveAnimations();

    const connectedLinks = data.links
  .filter(link => link.source.id === node.id || link.target.id === node.id);

    const connectedNodes = connectedLinks
      .map(link => link.source.id === node.id ? link.target : link.source);

    const tmpMaxWeight = Math.max(...connectedLinks.map(link => link.weight));

    // const connectedNodes = data.links
    //     .filter(link => link.source.id === node.id || link.target.id === node.id)
    //     .map(link => link.source.id === node.id ? link.target : link.source);

    // // Get minimum weight among connected links
    // const minWeight = Math.min(...data.links
    //   .filter(link => link.source.id === node.id || link.target.id === node.id)
    //   .map(link => link.weight)
    // );
    // console.log(minWeight)

    console.log("the max weight is:", tmpMaxWeight)
    // Reset all nodes before applying new highlights
    data.nodes.forEach(n => n.highlighted = false);
    node.highlighted = true; // Highlight the clicked node immediately
    // let previouslyHighlighted = []; // Keep track of past nodes
// (1- (Math.log((getWeightBetweenNodesWithDefault(graph.graphData(), node.id, neighbor.id))) / Math.log(maxWeight))) * 1000); // 1 second delay per node
    graph.nodeColor(n => n === node ? 'yellow' : 'gray'); // Initially set the clicked node to yellow
    // ((index + 1)) + 
    connectedNodes.forEach((neighbor, index) => {
        const timeoutId = setTimeout(() => {
            neighbor.highlighted = true; // Highlight the node
            graph.nodeColor(n => n.highlighted ? 'red' : 'gray'); // Update color dynamically
            
            sendOSCMessage(neighbor, '/bubbles', degree[neighbor.id], getWeightBetweenNodesWithDefault(graph.graphData(), node.id, neighbor.id));
            //it should be a contextual maxweight, meaning that it's mapped according to the contextual value, so the first is always the closest and the rest slowly decays cause the connection
            // is less strong
            console.log("WEIGHT:", getWeightBetweenNodesWithDefault(graph.graphData(), node.id, neighbor.id));
            console.log("Logarithmic Scaling", (1-(Math.log((getWeightBetweenNodesWithDefault(graph.graphData(), node.id, neighbor.id))) / Math.log(tmpMaxWeight))));
            console.log("Exponential Scaling:", (Math.pow(1-((getWeightBetweenNodesWithDefault(graph.graphData(), node.id, neighbor.id)) / tmpMaxWeight),5)*10));
            // Math.pow(value / 106, 0.3) * 10
        }, (Math.pow(1-((getWeightBetweenNodesWithDefault(graph.graphData(), node.id, neighbor.id)) / tmpMaxWeight),3.2)*5000));
        // scaled_value = (Math.log(10) / Math.log(maxWeight)) * 10;
        // console.log("scaaala", scaled_value)
        // need to pass it through a log function
        activeTimeouts.push(timeoutId); // Store the timeout ID
    });
} 

//==================================================

// Utilities

//==================================================

function clearTransitionAnimations() {
    if (animationTimer) {
      clearTimeout(animationTimer);
      sendOSCStopMessage('/additive');
    }
}

function clearActiveAnimations() {
    // Clear all active timeouts
    activeTimeouts.forEach(timeoutId => clearTimeout(timeoutId));
    activeTimeouts = []; // Reset the array
}

// Find weight between nodes
function getWeightBetweenNodesWithDefault(data, sourceId, targetId) {
  // console.log("OMADON", data.links)
  const link = data.links.find(link => 
    (link.source.id === sourceId && link.target.id === targetId) ||
    (link.source.id === targetId && link.target.id === sourceId)
  );
  // console.log(link)
  return link ? link.weight : 0;
}