// Set to > 0 if the DSP is polyphonic
const FAUST_DSP_VOICES = 0;

(async () => {
    const { createFaustNode } = await import("./create-node.js");

    // Create audio context
    const AudioCtx = window.AudioContext || window.webkitAudioContext;
    const audioContext = new AudioCtx({ latencyHint: 0.00001 });
    audioContext.suspend();

    // Create audio context activation button
    /** @type {HTMLButtonElement} */
    // const $buttonDsp = document.getElementById("button-dsp");

    // const play = (node) => {
    //     node.setParamValue('/additive/gate', 1);
    //     setTimetout(() =>  node.setParamValue('/additive/gate', 0), 1000)
    // }
    // 
    // Function to activate audio context
    // $buttonDsp.disabled = true;
    $buttonDsp.onclick = async () => {
        if (audioContext.state === "running") {
            $buttonDsp.textContent = "Suspended";
            await audioContext.suspend();
        } else if (audioContext.state === "suspended") {
            $buttonDsp.textContent = "Running";
            await audioContext.resume();
            // if (FAUST_DSP_VOICES) play(faustNode);
            faustNode.setParamValue('/additive/gate', 1);
            faustNode.setParamValue('/additive/freq', 440);
            setTimeout(() => faustNode.setParamValue('/additive/freq', 20), 1000);
        }
    }

    // Create Faust node
    const { faustNode, dspMeta: { name } } = await createFaustNode(audioContext, "additive", FAUST_DSP_VOICES);
    if (!faustNode) throw new Error("Faust DSP not compiled");

    // Connect the Faust node to the audio output
    faustNode.connect(audioContext.destination);

    // Connect the Faust node to the audio input
    if (faustNode.getNumInputs() > 0) {
        const { connectToAudioInput } = await import("./create-node.js");
        await connectToAudioInput(audioContext, null, faustNode, null);
    }

    // Create Faust node activation button
    // $buttonDsp.disabled = false;

    // Set page title to the DSP name
    // document.title = name;
})();
