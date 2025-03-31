
//================================================================================================================================================
// SYNTHESIS
//================================================================================================================================================
//TODO: openaccess -> shape of the sound -- citation impact -> transition duration
Synth("help-KlankOverlapTexture")
//================================================================================================================================================
// BUBBLES FIXFIXFIX
(
SynthDef("help-KlankOverlapTexture",
{|out = 0, freqs = #[0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0], rings = #[0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0], atk = 5, sus = 8, rel = 5, pan = 0|
    var e = EnvGen.kr(Env.linen(atk, sus, rel, 1, 4), doneAction: Done.freeSelf);
    var i = Decay.ar(Impulse.ar(Rand(0.8, 2.2)), 0.0, ClipNoise.ar(0.01));
    var z = Klank.ar(
        `[freqs, nil, rings],     // specs
        i                    // input
    );
    Out.ar(out, Pan2.ar(z*e, pan));
}).add;

(
OSCdef(\bubbleControl, {|msg, time, addr, recvPort|
	var sustain = 8, transition = 3, overlap = 4;
    var period = transition * 2 + sustain / overlap;
	// {SinOsc.ar(Rand(500, 1500),0, EnvGen.kr(Env.perc, doneAction: Done.freeSelf) * 0.1)}.play;
	Synth("help-KlankOverlapTexture", [
            \atk, transition,
            \sus, sustain,
            \rel, transition,
            \pan, 1.0.rand2,
            \freqs, {200.0.rrand(4000)}.dup(12),
            \rings, {0.1.rrand(2)}.dup(12)
        ]);
}, '/bubbles');
);

//================================================================================================================================================
// TRANSITION
(
l = 0;
OSCdef(\transitionControl, {|msg, time, addr, recvPort|
	var my_time = msg[3]*10/100;
	"MYTIME".postln;
	my_time.postln;
	a = Scale.major;
	"looo".postln;
	l.postln;
	(
		Ndef(\resControlled, {
			var fund = ((msg[4] + 1) * 30);// * a.ratios.choose;
			// var env = Env.new(levels: [0, 1, 0.4, 0], times: [0.1, 1, 15], curve: [-5, 0, -5]);
			var sig = DynKlank.ar(`[Array.series(msg[3]+1, fund, 3 * fund * a.ratios[4]), nil, [1, 1, 1, 1]], PinkNoise.ar([0.007, 0.007])) * 0.3;
			sig = sig + PitchShift.ar(Dust.ar([msg[4]+0.1,msg[4]+0.11]), pitchRatio: [0.12,0.2]);
			// Pan2.ar(sig)// stereo output
		});
	);
	if ( msg[1] == 0,
		{l.postln; Ndef(\resControlled).fadeTime_(l*20); Ndef(\resControlled,{});},    // true function
		{ Ndef(\resControlled).play; Ndef(\resControlled).fadeTime_(l);l = my_time;}    // false function
	);
}, '/additive');
);
//================================================================================================================================================
// WASD
// Array.series(13+1, 80, 4 * 80 * a.ratios[2])
(
(
OSCdef(\wasdControl, {|msg, time, addr, recvPort|
	var cit = msg[3].linlin(0, 1000, 1, 100).postln;
	var myfreq = (msg[4]*30);
	(
		SynthDef(\miaoControlled, {|out, fund= 80|
			var freq = myfreq;
			var env = Env.new(levels: [0, 1, 0.4, 0], times: [0.1, 0.2, freq/100], curve: [-5, 0, -5]);
			var arraySeries = `[Array.series(cit, freq, 2 * freq * a.ratios[2]), nil, [1, 1, 1, 1]];
			var sig = DynKlank.ar(arraySeries, PinkNoise.ar([0.007, 0.007])) * 0.3;
			sig = sig +
			(sig * Pulse.ar(Rand(1,20),mul:0.1) * Saw.ar(0.5)) * 0.2 +
			SinOsc.ar([freq, freq*a.ratios[3]], mul: 0.2);
			sig = sig * EnvGen.ar(env, doneAction: Done.freeSelf);
			Out.ar(out, Pan2.ar(sig))// stereo output
		}).play;
	);
}, '/wasd');
)
)
)

//================================================================================================================================================
// EXPERIMENTS
//================================================================================================================================================


//================================================================================================================================================
// Create an Ndef with a synth that will be controlled via OSC
(Ndef(\oscControlled, {
    var freq = \freq.kr(440);
    var amp = \amp.kr(0.5);
    var sig = SinOsc.ar(freq) * amp;
    sig ! 2 // stereo output
});)
a.ratios[3]
// I want to dynamically change the size of the array.
(
Ndef(\resControlled, {
	var fund = 80;// * a.ratios.choose;
	var env = Env.new(levels: [0, 1, 0.4, 0], times: [0.1, 1, 15], curve: [-5, 0, -5]);
	var sig = DynKlank.ar(`[Array.series(10, fund, 3 * fund * a.ratios[2]), nil, [1, 1, 1, 1]], PinkNoise.ar([0.007, 0.007])) * 0.3;
	sig = sig +
	(sig * Pulse.ar(Rand(1,20),mul:0.1) * Saw.ar(0.5)) * 0.2 +
	SinOsc.ar([fund, fund*a.ratios.choose, fund, fund*a.ratios.choose], mul: 0.2) +
	GVerb.ar(Pluck.ar(WhiteNoise.ar(0.1), Dust.kr([Rand(0.1,5),Rand(0.1,5)]), [fund.reciprocal, (fund*a.ratios.choose).reciprocal], [fund.reciprocal, (fund*a.ratios.choose).reciprocal], mul:0.1),drylevel:0.0,taillevel:1) +
	PitchShift.ar(Dust.ar([10,9]), pitchRatio: [0.12,0.2]);
	sig = sig * EnvGen.ar(env, doneAction: Done.freeSelf);
	Pan2.ar(sig)// stereo output
});
)
Array.series(10)
(
SynthDef(\miaoControlled, {|out, fund= 80, size = 10|
	var env = Env.new(levels: [0, 1, 0.4, 0], times: [0.1, 0.2, fund/100], curve: [-5, 0, -5]);
	var sig = DynKlank.ar(`[Array.series(, fund, 3 * fund * a.ratios[2]), nil, [1, 1, 1, 1]], PinkNoise.ar([0.007, 0.007])) * 0.3;
	sig = sig +
	(sig * Pulse.ar(Rand(1,20),mul:0.1) * Saw.ar(0.5)) * 0.2 +
	SinOsc.ar([fund, fund*a.ratios.choose], mul: 0.2);
	sig = sig * EnvGen.ar(env, doneAction: Done.freeSelf);
	Out.ar(out, Pan2.ar(sig))// stereo output
}).add;
)
Synth(\miaoControlled)
Ndef(\resControlled).fadeTime_(2)
Ndef(\resControlled).play;
Ndef(\resControlled).free;



// -- overlap texture
(
SynthDef("help-KlankOverlapTexture",
{|out = 0, freqs = #[0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0], rings = #[0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0], atk = 5, sus = 8, rel = 5, pan = 0|
    var e = EnvGen.kr(Env.linen(atk, sus, rel, 1, 4), doneAction: Done.freeSelf);
    var i = Decay.ar(Impulse.ar(Rand(0.8, 2.2)), 0.03, ClipNoise.ar(0.01));
    var z = Klank.ar(
        `[freqs, nil, rings],     // specs
        i                    // input
    );
    Out.ar(out, Pan2.ar(z*e, pan));
}).add;

r = Routine{
    var sustain = 8, transition = 3, overlap = 4;
    var period = transition * 2 + sustain / overlap;
    0.5.wait;            // wait for the synthdef to be sent to the server
    inf.do{
        Synth("help-KlankOverlapTexture", [
            \atk, transition,
            \sus, sustain,
            \rel, transition,
            \pan, 1.0.rand2,
            \freqs, {200.0.rrand(4000)}.dup(12),
            \rings, {0.1.rrand(2)}.dup(12)
        ]);
        period.wait;
    }
};
r.play;
)

r.stop;    // stop spawning new synths

((1)*30).cpsmidi%12
a.degrees.indexIn(((msg[4]+1)).cpsmidi%12)
[2, 3, 5, 6].indexIn(5.2);

a = Scale.major;
a.degrees;        // [ 0, 2, 4, 5, 7, 9, 11 ]
a.semitones;        // [ 0, 2, 4, 5, 7, 9, 11 ]
a.cents;        // [ 0, 200, 300, 500, 700, 900, 1100 ]
a.ratios;        // [ 1, 1.1224620483089, 1.2599210498937, 1.3348398541685, etc. ]
a.ratios.choose
Prand(a.ratios, 1)

Array.series(10, 100, 100 * a.ratios.choose)


// Start playing the Ndef
Ndef(\oscControlled).play;

// Create an OSC responder that will update the Ndef parameters
(
OSCdef(\aaControl, {|msg, time, addr, recvPort|
	{SinOsc.ar(Rand(500, 1500),0, EnvGen.kr(Env.perc, doneAction: Done.freeSelf) * 0.1)}.play;
}, '/bubbles');
)

)
s.boot;
(
b = Buffer.alloc(s,2048,1);
c = Buffer.alloc(s,2048,1);
//d = Buffer.read(s,"sounds/a11wlk01.wav");
d = Buffer.read(s, Platform.resourceDir +/+ "sounds/a11wlk01.wav");

)

(
SynthDef("help-morph", { arg out=0, bufnumA=0, bufnumB=1;
    var inA, chainA, inB, chainB, chain;
    inA = Pulse.ar(180, LFCub.kr(1, 0, 0.1, 0.3), 0.5);
    inB = VarSaw.ar(190, 0, LFCub.kr(0.8, 0, 0.4, 0.5), 0.5);
    chainA = FFT(bufnumA, inA);
    chainB = FFT(bufnumB, inB);
    chain = PV_Morph(chainA, chainB, MouseX.kr);
    Out.ar(out, IFFT(chain).dup);
}).play(s,[\out, 0, \bufnumA, b.bufnum, \bufnumB, c.bufnum ]);
)

(
SynthDef("help-morph2", { arg out=0, bufnumA=0, bufnumB=1, soundBufnum=2;
    var inA, chainA, inB, chainB, chain;
    inA = Mix(Formant.ar([120, 180], [1200, 2000], [240, 360], 0.2));
    inB = PlayBuf.ar(1, soundBufnum, BufRateScale.kr(soundBufnum), loop: 1);
    chainA = FFT(bufnumA, inA);
    chainB = FFT(bufnumB, inB);
    chain = PV_Morph(chainA, chainB, MouseX.kr);
    Out.ar(out,  IFFT(chain).dup);
}).play(s,[\out, 0, \bufnumA, b.bufnum, \bufnumB, c.bufnum, \soundBufnum, d.bufnum]);
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