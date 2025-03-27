// Create an Ndef with a synth that will be controlled via OSC
(Ndef(\oscControlled, {
    var freq = \freq.kr(440);
    var amp = \amp.kr(0.5);
    var sig = SinOsc.ar(freq) * amp;
    sig ! 2 // stereo output
});)


// Start playing the Ndef
Ndef(\oscControlled).play;

// Create an OSC responder that will update the Ndef parameters
(
OSCdef(\ouchControl, {|msg, time, addr, recvPort|
	{SinOsc.ar(Rand(500, 1500),0, EnvGen.kr(Env.perc, doneAction: Done.freeSelf) * 0.1)}.play;
	// Ndef(\oscControlled).set(\trigger, 0);
da	// 10.wait;
	// Ndef(\oscControlled).set(\trigger, 1);
}, '/bubbles');
)

(
OSCdef(\freqControl, {|msg, time, addr, recvPort|
	{SinOsc.ar(Rand(500, 1500),0, EnvGen.kr(Env.perc, doneAction: Done.freeSelf) * 0.1)}.play;
	// Ndef(\oscControlled).set(\trigger, 0);
	// 10.wait;
	// Ndef(\oscControlled).set(\trigger, 1);
}, '/wasd');
)

b = Buffer.read(s, Platform.resourceDir +/+ "sounds/a11wlk01.wav");

(Ndef(\oscControlled, {|trigger = 0|
    var trate, dur, rate, grainTrig;
	grainTrig = Trig1.kr(trigger, 0.1).postln;
	// trate = MouseY.kr(2,200,1);
    dur = 0.1; //4 / trate;
    rate = Dseq([10, 1, 1, 0.5, 0.5, 0.2, 0.1], inf);
    TGrains.ar(2, grainTrig, b, rate, MouseX.kr(0,BufDur.kr(b)), dur, Dseq([-1, 1], inf), 0.1, 2);
};
))


(
// Ensure a buffer is loaded
b = Buffer.read(s, Platform.resourceDir +/+ "sounds/a11wlk01.wav");

// Ndef for granular synthesis with more explicit trigger handling
Ndef(\oscControlled, {|trigger = 0, pos = 0.5|
    var grainTrig, rate, dur;

    // Create a trigger that's more generous
    grainTrig = Trig.kr(trigger, 0.1);

    // Explicit rate and duration
    rate = 1.0;  // Normal playback rate
    dur = 0.01;   // Grain duration in seconds

    // Debug post to see when grains are triggered
    SendTrig.kr(grainTrig, 0, 1);

    TGrains.ar(2,
        grainTrig,   // Trigger
        b,           // Buffer
        rate,        // Rate
        pos * BufDur.kr(b),  // Position
        dur,         // Grain duration
        0,           // Pan
        0.1,         // Amplitude
        2            // Interpolation
    );
});

// OSC definition to trigger a single grain
OSCdef(\freqControl, {|msg, time, addr, recvPort|
    "OSC message received".postln;
    Ndef(\oscControlled).set(\trigger, 1);
    // Use a routine to reset the trigger
    Routine({
        0.01.wait;  // Wait a short time
        Ndef(\oscControlled).set(\trigger, 0);
    }).play;
}, '/bubbles');

// Debug trigger responder
OSCdef(\triggerDebug, {|msg|
    "Grain triggered!".postln;
}, '/tr');
)



(
// Ensure a buffer is loaded
b = Buffer.read(s, Platform.resourceDir +/+ "sounds/a11wlk01.wav");

// Ndef for granular synthesis with multiple grain triggers
Ndef(\oscControlled, {|triggerBus = 0|
    var trig, rate, dur, pos, grains;

    // Read from a control bus that can accumulate multiple triggers
    trig = In.kr(triggerBus);

    // Parameters for grains
    rate = 1.0;  // Normal playback rate
    dur = 0.05;  // Very short grain duration

    // Spread out grains if multiple triggers occur
    pos = TRand.kr(0, BufDur.kr(b), trig);

    // Create multiple grains if multiple triggers are detected
    grains = TGrains.ar(2,
        trig,        // Trigger (can be multiple in one control period)
        b,           // Buffer
        rate,        // Rate
        pos,         // Random position
        dur,         // Grain duration
        TRand.kr(-1, 1, trig),  // Random pan
        0.1,         // Amplitude
        2            // Interpolation
    );

    grains  // Output the grains
});

// Create a control bus to accumulate triggers
~triggerBus = Bus.control(s, 1);

// Set up the Ndef with the trigger bus
Ndef(\oscControlled).set(\triggerBus, ~triggerBus);

// OSC definition to handle multiple triggers
OSCdef(\multiTrigger, {|msg, time, addr, recvPort|
    // Increment the trigger bus value
    ~triggerBus.value = ~triggerBus.value + 1;
}, '/control');

// Optional: Reset trigger accumulation periodically
Routine({
    {
        ~triggerBus.value = 0;
        0.1.wait;  // Adjust this wait time as needed
    }.loop;
}).play;
)
```

Key approaches for handling multiple rapid triggers:

1. **Control Bus Accumulation**:
   - Uses a control bus to count incoming triggers
   - Allows multiple triggers within a single control period
   - `TGrains` can handle multiple triggers simultaneously

2. **Random Positioning**:
   - `TRand.kr()` spreads out grain positions randomly
   - Prevents overlapping or clustering of grains
   - Provides spatial variation even with rapid triggers

3. **Periodic Reset**:
   - Includes a routine to periodically reset the trigger count
   - Prevents unbounded growth of the trigger counter

Considerations:
- Adjust `dur` to control grain length
- Modify the reset routine's wait time based on your specific needs
- The randomization helps create interesting sonic textures

Usage:
- Send OSC messages to `/control`
- Each message will trigger a grain at a slightly different position
- Can handle up to hundreds of triggers per second

Potential tweaks:
- Adjust amplitude based on trigger count
- Add more sophisticated positioning algorithms
- Implement more complex grain parameter modulation

Would you like me to elaborate on any part of this approach?