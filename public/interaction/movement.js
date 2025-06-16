//=================================================================================
//Graph Behaviour
//=================================================================================

//=================================================================================
//Attraction
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
//Repulsion
//=================================================================================

//=================================================================================
//User interaction
//=================================================================================
// Function to find the closest node in a specific direction
function findClosestNodeInDirection(currentNode, direction, graph) {
    if (!currentNode) return null;
    // Get all nodes from the graph
    const nodes = graph.graphData().nodes;

    // Use the actual rendered positions (not the data positions)
    // For force-graph, we need to check if the simulation has assigned positions
    const currentX = currentNode.x !== undefined ? currentNode.x : 0;
    const currentY = currentNode.y !== undefined ? currentNode.y : 0;
    
    // Filter nodes based on direction relative to current node
    let candidateNodes = [];
    // left is up, down is left, right is down, up is right
    // Define acceptable angle ranges for each direction
    const angleRanges = {
        'right': [-Math.PI/4, Math.PI/4], // Top quadrant: -45° to 45°
        'down': [Math.PI/4, 3*Math.PI/4], // Right quadrant: 45° to 135°
        'left': [3*Math.PI/4, -3*Math.PI/4], // Bottom quadrant: 135° to -135°
        'up': [-3*Math.PI/4, -Math.PI/4] // Left quadrant: -135° to -45°
    };
    
    candidateNodes = nodes.filter(node => {
        if (node === currentNode) return false;
        
        // Get node position
        const nodeX = node.x !== undefined ? node.x : 0;
        const nodeY = node.y !== undefined ? node.y : 0;
        
        // Calculate angle between current node and this node
        // Note: y-axis is inverted in many canvas implementations (0 is top)
        const dx = nodeX - currentX;
        const dy = nodeY - currentY;
        let angle = Math.atan2(dy, dx);
        
        // Check if angle falls within the range for the specified direction
        const range = angleRanges[direction];
        
        if (range[0] <= range[1]) {
        // Normal range
        return angle >= range[0] && angle <= range[1];
        } else {
        // Range that crosses the -π/π boundary
        return angle >= range[0] || angle <= range[1];
        }
    });
    
    if (candidateNodes.length === 0) return null;
    
    // Find the closest node in that direction
    return candidateNodes.reduce((closest, node) => {
        // Calculate distance
        const nodeX = node.x !== undefined ? node.x : 0;
        const nodeY = node.y !== undefined ? node.y : 0;
        const dx = nodeX - currentX;
        const dy = nodeY - currentY;
        const distance = Math.sqrt(dx * dx + dy * dy);
        
        if (!closest || distance < closest.distance) {
        return { node, distance };
        }
        return closest;
    }, null)?.node;
}

//==================================================

// Function to handle node selection with shift key
function shiftSelection(node, graph,degree) {
  if (shiftKeyPressed) {
    // If an animation is in progress, cancel it
    if (animationInProgress) {
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
      return selectedNodes.includes(n) ? 'red' : 'rgba(141, 185, 185, 0.88)';
    } else {
      // Single selection mode
      return n === selectedNode ? 'red' : 'rgba(141, 185, 185, 0.88)';
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

// Find shortest path between two nodes using DFS with path tracking
function findShortestPath(startNode, endNode, graph) {
    // Get the graph data
    const nodes = graph.graphData().nodes;
    const links = graph.graphData().links;
    
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
    
    let shortestPath = null;
    let shortestLinks = null;
    let minLength = Infinity;
    
    // DFS recursive function to explore all paths
    function dfs(currentNode, targetNode, currentPath, currentLinks, visited) {
        // If we've reached the target
        if (currentNode === targetNode) {
            if (currentPath.length < minLength) {
                minLength = currentPath.length;
                shortestPath = [...currentPath];
                shortestLinks = [...currentLinks];
            }
            return;
        }
        
        // Pruning: if current path is already longer than shortest found, stop
        if (currentPath.length >= minLength) {
            return;
        }
        
        // Explore all neighbors
        adjacencyList[currentNode].forEach(neighbor => {
            if (!visited.has(neighbor.node)) {
                visited.add(neighbor.node);
                dfs(
                    neighbor.node, 
                    targetNode, 
                    [...currentPath, neighbor.node], 
                    [...currentLinks, neighbor.link], 
                    visited
                );
                visited.delete(neighbor.node); // Backtrack
            }
        });
    }
    
    // Start DFS from the start node
    const visited = new Set([startNode.id]);
    dfs(startNode.id, endNode.id, [startNode.id], [], visited);
    
    // Return result
    if (shortestPath) {
        return {
            path: shortestPath,
            links: shortestLinks
        };
    } else {
        return {path: [], links: []};
    }
}

// // Find shortest path between two nodes using BFS
// function findShortestPath(startNode, endNode, graph) {
//   // Get the graph data
//   const nodes = graph.graphData().nodes;
//   const links = graph.graphData().links;
  
//   // Create an adjacency list representation of the graph
//   const adjacencyList = {};
//   nodes.forEach(node => {
//     adjacencyList[node.id] = [];
//   });
  
//   links.forEach(link => {
//     const source = typeof link.source === 'object' ? link.source.id : link.source;
//     const target = typeof link.target === 'object' ? link.target.id : link.target;
//     adjacencyList[source].push({node: target, link: link});
//     adjacencyList[target].push({node: source, link: link}); // For undirected graph
//   });
  
//   // BFS implementation
//   const queue = [{node: startNode.id, path: [], links: []}];
//   const visited = new Set([startNode.id]);
  
//   while (queue.length > 0) {
//     const {node, path, links} = queue.shift();
    
//     if (node === endNode.id) {
//       return {
//         path: [...path, node],
//         links: links
//       };
//     }
    
//     adjacencyList[node].forEach(neighbor => {
//       if (!visited.has(neighbor.node)) {
//         visited.add(neighbor.node);
//         queue.push({
//           node: neighbor.node, 
//           path: [...path, node],
//           links: [...links, neighbor.link]
//         });
//       }
//     });
//   }
  
//   // No path found
//   return {path: [], links: []};
// }

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

// CLAUDE TEST

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
    // console.log("AAAA")
    // Add the next link to the highlighted path
    highlightedPath.push(linkPath[currentStep]);
    
    // Highlight current node in the path
    const currentNodeId = nodePath[currentStep + 1];
    const currentNode = nodeMap[currentNodeId];
    document.getElementById("content").innerText = currentNode["description"];
    
    // Send OSC message
    sendOSCMessage(currentNode, '/additive', degree[currentNode.id]);
    
    // Center on current node
    graph.centerAt(currentNode.x, currentNode.y, 300);
    
    // Update colors
    updateNodeColors(graph);
    
    // Calculate the delay for the next step based on current node's citations
    const nextNodeId = nodePath[currentStep + 1];
    // Maps 100-500 to 0-1 with focus on 100-150 range
    // TODO TOMORROW
    // const nextDelay = mapValue(nodeMap[nextNodeId]["citations"], {
    //   inMin: 0,
    //   inMax: 1000,
    //   outMin: 5000,
    //   outMax: 10000,
    //   focusRangeEnd: 30,
    //   focusRangeOutput: 0.4
    // });
    const nextDelay = mapNumRange(nodeMap[nextNodeId]["citations"], 0,836,5000,10000);
    // const nextDelay = nodeMap[nextNodeId]["citations"];
    console.log("Next Delay:", nextDelay);
    // Move to next step with dynamic timeout
    currentStep++;
    
    // Set the next timeout with dynamic delay
    animationTimer = setTimeout(animateStep, nextDelay);
  }
  
  // Start the animation with the first node's delay
  const firstDelay = mapNumRange(nodeMap[nodePath[0]]["citations"], 0,836,5000,10000);
  // const firstDelay = mapValue(nodeMap[nodePath[0]]["citations"], {
  //   inMin: 0,
  //   inMax: 1000,
  //   outMin: 1000,
  //   outMax: 10000,
  //   focusRangeEnd: 30,
  //   focusRangeOutput: 0.4
  // });
  console.log("First Delay", firstDelay);
  animationTimer = setTimeout(animateStep, firstDelay);
}

//END TEST

// // Function to animate the path traversal
// function animatePathTraversal(nodePath, linkPath, graph, degree) {
//   // Clear any existing animation
//   if (animationTimer) {
//     clearInterval(animationTimer);
//   }
  
//   animationInProgress = true;
//   highlightedPath = [];
//   let currentStep = 0;
  
//   // Get node objects from their IDs
//   const nodeObjects = graph.graphData().nodes;
//   const nodeMap = {};
//   nodeObjects.forEach(node => {
//     nodeMap[node.id] = node;
//   });
//   nodeStep = 0;
//   console.log("miao", nodeMap[nodePath[0]]["citations"])
//   // Animation function
//   animationTimer = setTimeout(() => {
//     if (currentStep >= linkPath.length) {
//       // Animation completed
//       clearInterval(animationTimer);
//       animationInProgress = false;
//       sendOSCStopMessage('/additive');
//       return;
//     }
//     // Add the next link to the highlighted path
//     highlightedPath.push(linkPath[currentStep]);
//     // Highlight current node in the path
//     const currentNodeId = nodePath[currentStep + 1];
//     const currentNode = nodeMap[currentNodeId];
//     document.getElementById("content").innerText = currentNode["description"];
//     // console.log(degree[currentNode.id])
//     // playFaust(220, degree[currentNode.id], "additivefilter", faustNode, audioContext);
//     sendOSCMessage(currentNode, '/additive', degree[currentNode.id]);
//     // Center on current node
//     graph.centerAt(currentNode.x, currentNode.y, 300);
//     nodeStep++;
//     // Update colors
//     updateNodeColors(graph);
//     // Move to next step
//     currentStep++;
//   }, nodeMap[nodePath[nodeStep]]["citations"] * 5); // 1 second interval
// }

//==================================================

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

let activeTimeouts = []; // Array to store all active timeouts

function highlightNeighborsGradually(node, graph, degree, data) {
    // requestFullScreen(elem);
    // console.log(node)
    // Find connected nodes
    // console.log(degree[node.id])
    clearActiveAnimations();
    const connectedNodes = data.links
        .filter(link => link.source.id === node.id || link.target.id === node.id)
        .map(link => link.source.id === node.id ? link.target : link.source);

    // Reset all nodes before applying new highlights
    data.nodes.forEach(n => n.highlighted = false);
    node.highlighted = true; // Highlight the clicked node immediately
    // let previouslyHighlighted = []; // Keep track of past nodes

    graph.nodeColor(n => n === node ? 'yellow' : 'gray'); // Initially set the clicked node to yellow
    
    connectedNodes.forEach((neighbor, index) => {
        const timeoutId = setTimeout(() => {
            neighbor.highlighted = true; // Highlight the node
            graph.nodeColor(n => n.highlighted ? 'red' : 'gray'); // Update color dynamically
            // console.log(2000 - (degree[neighbor.id] * 30));
            // playFaust(2000 - (degree[neighbor.id] * 30), 1, "bubbles", audioNode, audioContext);
            // document.getElementById("content").innerText = neighbor["description"];
            sendOSCMessage(neighbor, '/bubbles', degree[neighbor.id]);
            console.log("HERE", neighbor.id)
        }, (index + 1) * (degree[neighbor.id]) * 10); // 1 second delay per node
        
        activeTimeouts.push(timeoutId); // Store the timeout ID
    });
} 

