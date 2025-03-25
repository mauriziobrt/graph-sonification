function fetchExternalData() {
    return Promise.all([
        fetch("./data/correct_output.json")
    ])
        .then(
            results => Promise.all(
                results.map(result => result.json())
            )
        );
}

// Variables to track state
let selectedNode = null;
let selectedNodes = [];
let shiftKeyPressed = false;
let spaceKeyPressed = false;
let hoverOn = false;
let animationInProgress = false;
let highlightedPath = [];
let animationTimer = null;
let linkStaticColor = 'rgba(104, 100, 100, 0.3)';
