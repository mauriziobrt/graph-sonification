const FAUST_DSP_VOICES = 16;
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
        // case 'additiveplus':
        //     playAdditivePlus(freq,nr_neighbours,node)
        // break;
        case 'additivefilter':
            playAdditiveFilter(freq,nr_neighbours, node)
        break;
        case 'bubbles':
            playBubbles(freq,node)
        break;
        case 'sampler':
            playSampler(freq,node)
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
    // node.setParamValue('/additive/gate', 1);
    node.setParamValue('/additive/num_partials', nr_neighbours);
}

function playAdditivePlus(freq, nr_neighbours, node) {
    node.setParamValue('/additiveplus/freq', 100 + freq);
    node.setParamValue('/additiveplus/gate', 1);
    node.setParamValue('/additiveplus/num_partials', nr_neighbours);
}

function playAdditiveFilter(freq, nr_neighbours, node) {
    node.keyOn(0, 100, 100);
    setTimeout(() => node.keyOff(0, 100, 0), 5000);
    // node.setParamValue('/additivefilter/freq', 100 + freq);
    // node.setParamValue('/additiveplus/gate', 1);
    // node.setParamValue('/additiveplus/num_partials', nr_neighbours);
}
//=================================================================================
//Bubble Sounds
//=================================================================================
function playBubbles(freq, node) {
    node.keyOn(0, 100, 100);
    node.setParamValue("/bubble/drop", 1);
    // node.setParamValue("/bubble/bubble/freq", freq)
    setTimeout(()=> {node.setParamValue("/bubble/drop", 0)}, 10);
    setTimeout(()=> {node.keyOff(0, freq, 100);}, 100);
}

//=================================================================================
//Concatenative Synthesis
//=================================================================================
function playSampler(freq, node) {
    console.log(freq)
    node.keyOn(0, freq, 100);
    // setTimeout(() => node.keyOn(0, 64, 100), 1000);
    // setTimeout(() => node.keyOn(0, 67, 100), 2000);
    setTimeout(() => node.allNotesOff(), 5000);
    // setTimeout(() => playSampler(node), 7000);
}