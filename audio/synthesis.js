const FAUST_DSP_VOICES = 0;
//=================================================================================
//Synthesis Engine
//=================================================================================
function playFaust(freq, nr_neighbours, engine, node, audioContext) {
    if (!node) {
        return;
    }
    if (audioContext.state === 'suspended') {
        audioContext.resume();
    }
    switch(engine) {
        case 'additive':
        playAdditive(freq, nr_neighbours,node)
        break;
        case 'additiveplus':
            playAdditivePlus(freq,nr_neighbours,node)
        break;
        case 'bubbles':
        playBubbles(freq,node)
        break;
    }
}

function stopFaust(){
};

//=================================================================================
//Additive Synthesis
//=================================================================================
function playAdditive(freq, nr_neighbours, node) {
    node.setParamValue('/additive/freq', 100 + freq);
    node.setParamValue('/additive/gate', 1);
    node.setParamValue('/additive/num_partials', nr_neighbours);
}

function playAdditivePlus(freq, nr_neighbours, node) {
    node.setParamValue('/additiveplus/freq', 100 + freq);
    node.setParamValue('/additiveplus/gate', 1);
    node.setParamValue('/additiveplus/num_partials', nr_neighbours);
}
//=================================================================================
//Bubble Sounds
//=================================================================================
function playBubbles(freq, node) {
    node.setParamValue("/bubble/drop", 1);
    node.setParamValue("/bubble/bubble/freq", freq)
    setTimeout(()=> {node.setParamValue("/bubble/drop", 0)}, 10);
}

//=================================================================================
//Concatenative Synthesis
//=================================================================================