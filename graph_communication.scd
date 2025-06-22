Array.series(10, 50, 20)
//================================================================================================================================================
// SYNTHESIS
//================================================================================================================================================
((
SynthDef("help-KlankOverlapdTexture",
	{|out = 0, amp = 1, freqs = #[0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0], rings = #[0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0], atk = 5, sus = 8, rel = 5, pan = 0, filterfreq=440|
		var e = EnvGen.kr(Env.linen(atk, sus, rel, 1, -50), doneAction: Done.freeSelf);
		// var i = Decay.ar(Impulse.ar(Rand(0.8, 2.2)), 0.0, ClipNoise.ar(0.01));
		var z = Klank.ar(
			`[freqs, nil, rings],     // specs
			ClipNoise.ar(0.01) * e                    // input
		);

		Out.ar(out, Pan2.ar(LPF.ar(z*e*amp, filterfreq), pan));
}).add;
);
)
//TODO: openaccess -> shape of the sound -- citation impact -> transition duration
Synth("help-KlankOverlapTexture")
{Decay.ar(Impulse.ar(Rand(0.8, 2.2)), 0.0, ClipNoise.ar(0.01))}.play;
(
(
OSCdef(\hoverControl, {|msg, time, addr, recvPort|
	var cit = msg[3].linlin(0, 1000, 1, 100).postln;
	var myfreq = (msg[4]).linlin(0, 60, 50, 1300);
	var x = DC.ar(msg[7]/2500);
	var y = DC.ar(msg[8]/2500);
	(
		SynthDef(\hoverControlled, {|out, fund= 80|
			var freq = myfreq;
			var env = Env.new(levels: [0, 1, 0.4, 0], times: [0.1, 0.2, freq/100], curve: [-5, 0, -5]);
			var arraySeries = `[Array.series(cit, freq, 2 * freq * a.ratios[2]), nil, [1, 1, 1, 1]];
			var sig = DynKlank.ar(arraySeries, PinkNoise.ar([0.007, 0.007])) * 0.3;
			sig = sig +
			(sig * Pulse.ar(Rand(1,20),mul:0.1) * Saw.ar(0.5)) * 0.2 +
			SinOsc.ar([freq, freq*a.ratios[3]], mul: 0.2);
			sig = sig * EnvGen.ar(env, doneAction: Done.freeSelf);
			#w, x, y, z = BFEncode2.ar(sig,x,y, 0, 0.6);
			BFDecode1.ar(w, x, y, z, [7pi/6, 5pi/6, 2pi/3, pi/3, pi/6, 11pi/6, 5pi/3, 4pi/3], 0);
			// Out.ar(out, sig)// stereo output
		});
	);
}, '/control');
)
)

(
OSCdef(\transitionControl, {|msg, time, addr, recvPort|
	var x = (msg[7]/2500);
	var y = (msg[8]/2500);
	// #w, x, y, z = BFEncode2.ar(WhiteNoise.ar, MouseX.kr(-1, 1), MouseY.kr(1, -1), 0, 0.03);
	var cit = msg[3].linlin(0, 1000, 1, 100);
	var freq = (msg[4]).linlin(0, 60, 50, 1300);
	var env = Env.new(levels: [0, 1, 0.4, 0], times: [0.1, 0.2, freq/100], curve: [-5, 0, -5]);
	var arraySeries = `[Array.series(cit, freq, 2 * freq * a.ratios[2]), nil, [1, 1, 1, 1]];
	// var sig = DynKlank.ar(arraySeries, PinkNoise.ar([0.007, 0.007])) * 0.3;
	// sig = sig +(sig * Pulse.ar(Rand(1,20),mul:0.1) * Saw.ar(0.5)) * 0.2 + SinOsc.ar([freq, freq*a.ratios[3]], mul: 0.2);
	// sig = sig * EnvGen.ar(env, doneAction: Done.freeSelf);
	var sig = SinOsc.ar(440);
	#w, x, y, z = BFEncode2.ar(sig,x,y, 0, 0.6);
    //decode for 4 channels
	// x -> 1 right, -1 left
	// y -> 1 back, -1 front
    BFDecode1.ar(w, x, y, z, [7pi/6, 5pi/6, 2pi/3, pi/3, pi/6, 11pi/6, 5pi/3, 4pi/3], 0);
}, '/control');
)
Ndef(\ciao).play

//================================================================================================================================================
// BUBBLES FIXFIXFIX
(
(
SynthDef("help-KlankOverlapTexture",
	{|out = 0, amp = 1, freqs = #[0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0], rings = #[0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0], atk = 5, sus = 8, rel = 5, pan = 0, filterfreq=440|
		var e = EnvGen.kr(Env.linen(atk, sus, rel, 1, -50), doneAction: Done.freeSelf);
		// var i = Decay.ar(Impulse.ar(Rand(0.8, 2.2)), 0.0, ClipNoise.ar(0.01));
		var z = Klank.ar(
			`[freqs, nil, rings],     // specs
			ClipNoise.ar(0.01) * e                    // input
		);

		Out.ar(out, Pan2.ar(LPF.ar(z*e*amp, filterfreq), pan));
}).add;
);
a = Scale.major;

(
OSCdef(\bubbleControl, {|msg, time, addr, recvPort|
	var bell1 = [ 3958.2691669464, 2219.5205450058, 3720.8760738373, 3930.4407596588, 827.31196880341, 3670.5682277679, 550.56445598602, 3677.7821779251, 581.56654834747, 3224.8901605606, 2330.4237604141, 756.98308944702 ];
	var bell2 = [ 223.22008609772, 1996.9875097275, 3631.1988592148, 753.74145507812, 659.04550552368, 953.89244556427, 612.56682872772, 426.58507823944, 1644.7909116745, 875.82595348358, 1946.9505548477, 3229.9587249756 ];
	var bell3 = [ 3901.8504142761, 3278.7544727325, 3938.3745193481, 1065.1204586029, 3879.1404008865, 3816.3529872894, 2989.7552490234, 1730.3744077682, 678.00426483154, 2374.1246700287, 2525.9301900864, 3549.2574453354 ];
	var bell4 = [ 2657.4152469635, 912.29071617126, 1286.7574691772, 3869.4250106812, 1136.3956451416, 2689.750957489, 459.87751483917, 2751.2355566025, 3400.4847288132, 1524.5981216431, 2834.7212314606, 2828.8508653641 ];
	var bell5 = [ 1328.7076234818, 456.14535808563, 643.3787345886, 1934.7125053406, 568.1978225708, 1344.8754787445, 229.93875741958, 1375.6177783012, 1700.2423644066, 762.29906082155, 1417.3606157303, 1414.4254326821 ];

	// msg[].postln;
	// (msg[3].linlin(0,200,0,1)).postln;
	// {SinOsc.ar(Rand(500, 1500),0, EnvGen.kr(Env.perc, doneAction: Done.freeSelf) * 0.1)}.play;
	Synth("help-KlankOverlapTexture", [
		\atk, 0,
		\sus, 0,
		\rel, 4,
		\pan, 1.0.rand2,
		\amp, (msg[3].linlin(0,200,-10,0).dbamp),
		\freqs, [bell1, bell2, bell3, bell4, bell5].choose,
		\rings, {0.1.rrand(msg[3]/10.0)}.dup(12),
		\rel, (msg[4].linlin(0,60,100,1300)/50)
		// \filterfreq, msg[4].linlin(0,55, 60, 20000)
        ]);
}, '/bubbles');
);

//================================================================================================================================================
// TRANSITION
(
l = 0;
OSCdef(\transitionControl, {|msg, time, addr, recvPort|
	var my_time = msg[5] /1000;
	if( l == 0,
		{l = my_time; Ndef(\resControlled).fadeTime_(l/4); "Start".postln},
		{}
	);
	"TIME:".postln;
	(msg[5]/1000).postln;
	/*"MYTIME".postln;
	my_time.postln;*/
	a = Scale.major;
/*	"looo".postln;
	l.postln;*/
	// NodeProxy
	// a = NodeProxy.new.play; // play to hardware output.
	// a.source = { Pulse.ar([350, 351.3] / 4, 0.4) * 0.2 };
	(
		Ndef(\resControlled, {
			var fund = ((msg[3] + 1).linlin(0,850,100, 800));// * a.ratios.choose;
			// var env = Env.new(levels: [0, 1, 0.4, 0], times: [2*l/10, 6*l/10, my_time], curve: [-5, 0, -5]);
			var sig = DynKlank.ar(`[Array.series(msg[4]+1, fund,fund * a.ratios[4]), nil, [1, 1, 1, 1]], PinkNoise.ar([0.007, 0.007]));
			sig = sig * SinOsc.ar([msg[3].linlin(0,860,0.0, 0.02), msg[3].linlin(0,860,0.0, 0.03)]).abs;
			//+ PitchShift.ar(Dust.ar([msg[4]+0.1,msg[4]+0.11],0.1), pitchRatio: [0.12,0.2]);// + SinOsc.ar(fund!2) ;
			sig = sig; //* EnvGen.kr(env);
			// Pan2.ar(sig)// stereo output
		});
	);
	if ( msg[1] == 0,
		{Ndef.clear(20); l = 0; "END".postln;},    // true function
		{Ndef(\resControlled).play; Ndef(\resControlled).fadeTime_(l/2);l = my_time;"Continue".postln}    // false function
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
	var myfreq = (msg[4]).linlin(0, 60, 50, 1300);
	(
		SynthDef(\miaoControlled, {|out, fund= 80|
			// Sweep da basso a alto e da alto a basso
			var freq = XLine.kr(myfreq);
			// var freq = myfreq;
			var env = Env.new(levels: [0, 1, 0.4, 0], times: [0.1, 0.2, freq/100], curve: [-5, 0, -5]);
			var arraySeries = `[Array.series(cit, freq, 2 * freq * a.ratios[2]), nil, [1, 1, 1, 1]];
			var sig = DynKlank.ar(arraySeries, PinkNoise.ar([0.007, 0.007])) * 0.3;
			sig = sig +
			(sig * Pulse.ar(Rand(1,20),mul:0.1) * Saw.ar(0.5)) * 0.2 +
			SinOsc.ar([freq, freq*a.ratios[3]], mul: 0.2);
			sig = sig * EnvGen.ar(env, doneAction: Done.freeSelf)*0.5;
			Out.ar(out, Pan2.ar(sig * 0.5))// stereo output
		}).play;
	);
}, '/wasd');
)
);

//================================================================================================================================================
// HOVER
// Array.series(13+1, 80, 4 * 80 * a.ratios[2])
(
(
OSCdef(\hoverControl, {|msg, time, addr, recvPort|
	var cit = msg[3].linlin(0, 1000, 1, 100).postln;
	var myfreq = (msg[4]).linlin(0, 60, 50, 1300);
	(
		SynthDef(\hoverControlled, {|out, fund= 80|
			var freq = myfreq;
			var env = Env.new(levels: [0, 1, 0.4, 0], times: [0.1, 0.2, freq/100], curve: [-5, 0, -5]);
			var arraySeries = `[Array.series(cit, freq, 2 * freq * a.ratios[2]), nil, [1, 1, 1, 1]];
			var sig = DynKlank.ar(arraySeries, PinkNoise.ar([0.007, 0.007])) * 0.3;
			sig = sig +
			(sig * Pulse.ar(Rand(1,20),mul:0.1) * Saw.ar(0.5)) * 0.2 +
			SinOsc.ar([freq, freq*a.ratios[3]], mul: 0.2);
			sig = sig * EnvGen.ar(env, doneAction: Done.freeSelf);
			Out.ar(out, Pan2.ar(sig * 0.25))// stereo output
		}).play;
	);
}, '/control');
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
	SinOsc.ar([XLine.ar(fund, fund/10,300), fund*a.ratios.choose, fund, fund*a.ratios.choose], mul: 0.2 * SinOsc.kr(0.01).abs) +
	GVerb.ar(Pluck.ar(WhiteNoise.ar(0.1), Dust.kr([Rand(0.1,5),Rand(0.1,5)]), [fund.reciprocal, (fund*a.ratios.choose).reciprocal], [fund.reciprocal, (fund*a.ratios.choose).reciprocal], mul:0.1),drylevel:0.0,taillevel:1) +
	PitchShift.ar(Dust.ar([1,4]), pitchRatio: [0.12,0.2]);
	sig = GVerb.ar(sig*0.5+PitchShift.ar(sig,pitchRatio: Rand(1,20)));// * EnvGen.ar(env, doneAction: Done.freeSelf);
	Pan2.ar(sig)// stereo output
});
)
Array.series(10)
(
SynthDef(\miaoControlled, {|out, fund= 80, size = 10|
	var env = Env.new(levels: [0, 1, 0.4, 0], times: [0.1, 0.2, fund/100], curve: [-5, 0, -5]);
	var sig = DynKlank.ar(`[Array.series(10, fund, 3 * fund * a.ratios[2]), nil, [1, 1, 1, 1]], PinkNoise.ar([0.007, 0.007])) * 0.3;
	sig = sig + (sig * Pulse.ar(Rand(1,20),mul:0.1) * Saw.ar(0.5)) * 0.2 + SinOsc.ar([fund, fund*a.ratios.choose], mul: 0.2);
	sig = sig * EnvGen.ar(env, doneAction: Done.freeSelf);
	Out.ar(out, Pan2.ar(sig))// stereo output
}).add;
)
(
r = Routine({
	  // Wait a short time
	inf.do{Synth(\miaoControlled);
		0.25.wait;
	};
}).play;
)
Synth(\miaoControlled)
Ndef(\resControlled).fadeTime_(20)
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

//================================================================================================================================================
// A Spectralist Supercollider, experiments on timbre
//================================================================================================================================================


// Function to distort a spectrum in SuperCollider
// Equivalent to the Lisp dist-freq function

// Helper function equivalent to hqf (assuming it calculates a harmonic frequency)
~hqf = {|fund, n| fund * n};
(
~distFreq = {|accord, fund, nhq1, nhq2, dfq1, dfq2|
    var minin = ~hqf.(fund, nhq1);
    var maxin = ~hqf.(fund, nhq2);
    var minout = minin + dfq1;
    var maxout = maxin + dfq2;

    // Convert frequencies to MIDI notes for scaling
    var freqsAsMidi = accord.cpsmidi;

    // Scale using SuperCollider's linlin function (equivalent to om-scale)
    var scaledMidi = freqsAsMidi.linlin(minin.cpsmidi, maxin.cpsmidi, minout.cpsmidi, maxout.cpsmidi);

    // Convert back to frequency (equivalent to f->mc/tm and mc->f operations)
    scaledMidi.midicps;
};
)
// Example usage:
~distFreq.([220, 440, 660], 110, 1, 6, 50, -100);

(
// Equivalent to dist-proc function in SuperCollider
~distProc = {|chord, steps, minout, maxout, minin=nil, maxin=nil, output='excluded', unit='midic'|
    var results, chordFreqs, minInVal, maxInVal;

    // Convert chord to frequencies if needed
    chordFreqs = case
        {unit == 'midic'} {chord.midicps}
        {unit == 'hz'} {chord}
        {true} {chord}; // Default case

    // Find min/max values if not provided
    minInVal = if(minin.isNil) {chordFreqs.minItem} {minin};
    maxInVal = if(maxin.isNil) {chordFreqs.maxItem} {maxin};

    // Initialize results array
    results = if(output == 'included') {[chordFreqs]} {[]};

    // Generate each distorted version
    (steps + (output == 'excluded').asInteger).do {|i|
        var step = i + (output == 'excluded').asInteger;
        var interpolation = step / steps;
        var currentMin = minInVal.blend(minout, interpolation);
        var currentMax = maxInVal.blend(maxout, interpolation);

        // Scale frequencies
        var scaledFreqs = chordFreqs.collect {|freq|
            freq.linlin(minInVal, maxInVal, currentMin, currentMax);
        };

        results = results.add(scaledFreqs);
    };

    // Convert back to original unit if needed
    if(unit == 'midic') {
        results = results.collect {|freqs| freqs.cpsmidi};
    };

    results;
};
)

{SinOsc.ar([200,400])}.play
s.options.numOutputBusChannels = 10;
s.options.device = "MADIface Pro (79251090)"; // Make sure device name matches exactly
s.reboot;

// Documentation for the function
/*
~distProc - Progressively distorts a chord until specified distortion is reached

Arguments:
- chord: The chord to distort (array of values)
- steps: Number of intermediate distortions to produce
- minout: Minimum output value for final distortion
- maxout: Maximum output value for final distortion
- minin: Minimum input value (optional, defaults to min value in chord)
- maxin: Maximum input value (optional, defaults to max value in chord)
- output: Whether to include original chord ('included' or 'excluded')
- unit: Unit of input/output values ('midic' for midicents or 'hz' for hertz)

Returns:
A nested array of progressively distorted chords

Example usage:
~distProc.([60, 64, 67], 3, 72, 84, nil, nil, 'excluded', 'midic');
*/
~chordarray = ~distProc.(~weird, 30, 40, 15000, nil, nil, 'included', 'hz');
~chordarray[30]
(
Ndef(\mina, {
	var sig=SinOsc.ar(~chordarray[0],
		mul: ~vol * EnvGen.kr(
            Env.new(levels: [0, 1, 0.9, 0], times: [10, 15, 20], curve: [-5, 0, -5])
        ));
	Splay.ar(sig *0.5)
	}
)
)

PlayBuf

Ndef(\mina).play;
Ndef(\mina).fadeTime_(1)

~weird = [1514.740967,1385.596191,962.326599,896.825378,799.505249,758.861206, 644.865723,593.230164 , 533.841675,458.443481,406.707855 , 327.700256,283.225922 ,251.38092,169.954132,76.895821];
~weird = [3244.458984,1415.318481,999.23291,937.08075,738.910645,660.467102,592.979675,458.360535,416.733612,332.467133,290.876251,248.837631,166.802063,82.8,540.253174,125.353729,1248.581665,1942.106567,374.46817,1349.984131,627.387451,3210.588623,207.962158,1666.172607,4877.073242,1046.370483,2774.630859,1179.544189,12017.223633,1873.422119,499.832672,8533.022461,3104.227051,9248.060547,5951.356934,6489.701172,1988.934814,4727.666504,2825.40625,3503.43,7901.629395,1548.740479,3652.716797,7247.925293,2408.406982,2225.326904,11802.966797,4420.947266,6096.904785,4904.258789,9261.949219,1124.491455]
~vol = [0.001097,0.029582,0.015263,0.129007,0.032971,0.012219,0.021535,0.014781,0.050153,0.01081,0.099383,0.044204,0.058381,0.074245,0.011431,0.035825,0.042264,0.003957,0.008473,0.00192,0.003399,0.00106,0.00443,0.027487,0.003262,0.036532,0.002234,0.007606,0.000179,0.017956,0.029404,0.001007,0.002936,0.000366,0.003402,0.000549,0.007424,0.001161,0.004531,0.001361,0.000101,0.007071,0.007342,0.000368,0.001683,0.009346,0.000638,0.012051,0.002206,0.000907,0.000216,0.003729]
~weird.size
~vol = [0.009013,0.015846,0.00165,0.001193,0.030116,0.007759,0.004115, 0.026975,0.016474 ,0.010245,0.0031,0.005714,0.000887,0.012167,0.002842, 0.002842]


b = SoundFile.collect(~sample, s);
(

// SoundFile.collect(~audioFolder ++ "*").do { |f| f.path.postln };
// ~buffers = SoundFile.collect(~audioFolder ++ "*.wav").collect ;
~buffers = SoundFile.collect(~sample).collect { |sf|
	var data = FloatArray.newClear(sf.numFrames * sf.numChannels);
	sf.openRead;
	sf.readData(data);
	sf.close;
// 	// Optional data manipulation can go here: data = data.normalize;
	Buffer.loadCollection(s, data);
	};
)
k = Buffer.loadCollection(s, ~sample)
k.play
k.play

(
// 1. Load all buffers
~buffers = ~chords.collect({ |path|
  Buffer.read(s, path);
});
)
(
// 2. Create a SynthDef to play a sample
SynthDef(\playSample, { |out=0, bufnum, amp=0.5, pan=0|
  var sig = PlayBuf.ar(1, bufnum, BufRateScale.kr(bufnum),loop:1, doneAction: 2);
	Out.ar(out,VSTPlugin.ar(Pan2.ar(sig, pan, amp),2));
}).add;
)
// 3. Play all samples simultaneously (like a chord)
// ~playChord = {
b.source = {
  ~buffers[15..26].do({ |buf, i|
    Synth(\playSample, [
      \bufnum, buf,
      \amp, 0.5,
			// \pan, i * 0.3 - 0.5  // spread samples across stereo field
    ]);
  });
};

// Execute this function to play all samples at once
// ~playChord.value;
)}
(
SynthDef(\insert, { arg bus;
    ReplaceOut.ar(bus, VSTPlugin.ar(In.ar(bus, 2), 2));
}).add;
)


// Create a NodeProxy
p = NodeProxy.audio(s, 2);
522-52
470

52*9
(
// Set the source to play all samples at once
p.source = {
	var signals = ~buffers[420..430].collect({ |buf, i|
		var sig = PlayBuf.ar(
			numChannels: buf.numChannels,
			bufnum: buf,
			rate: 1 * BufRateScale.kr(buf),// * XLine.kr(1,Rand(0.5,2),30),
			trigger: Dust2.ar(XLine.kr(1,1, 30).postln),
			startPos: 9.5 * BufDur.kr(buf)/10,
			loop: 0,
			doneAction: 0  // No doneAction inside NodeProxy
		);

		// Pan mono samples, pass stereo through
		if(buf.numChannels == 1) {
			Pan2.ar(sig, i%2)
		} {
			sig
		};

	});

  // Mix all signals together and apply overall amplitude
  Mix.new(signals) * 0.5;
};
)
// I should have something like a python script that generates the specific notes according to my requirements and I access it through a file in supercollider for choosing the sample to play, instead of having this wall of text

// I need the code to build the database and to assign the samples based on the couple chords + volume. it would be nice to include microtonal support as well
// Basically I want to have faster tools
// I want to call the functions from supercollider. I want to have the possibility of choosing according to audio features, like starting note vs continuous note.
// Start playing
p.play;
p.fadeTime_(5);
p.end(2); // Fade out over 2 seconds
~buffers.size
~chords.size
~sample.size
(~sample= ["/Volumes/CrucialX8/Musica/Samples/Libraries/Orchidea/Strings/Contrabass/sforzato/Cb-sfz-E2-f-3c-N.wav", "/Volumes/CrucialX8/Musica/Samples/Libraries/Orchidea/Strings/Contrabass/pizzicato_l_vib/Cb-pizz_lv-B2-mf-2c-N.wav", "/Volumes/CrucialX8/Musica/Samples/Libraries/Orchidea/Strings/Viola/ordinario/Va-ord-E3-mf-4c-T19u.wav", "/Volumes/CrucialX8/Musica/Samples/Libraries/Orchidea/Strings/Violin/pizzicato_l_vib/Vn-pizz_lv-G#3-mf-4c-N.wav", "/Volumes/CrucialX8/Musica/Samples/Libraries/Orchidea/Strings/Contrabass/decrescendo/Cb-decr-B3-ffpp-1c-R100u.wav", "/Volumes/CrucialX8/Musica/Samples/Libraries/Orchidea/Brass/bs/Bass_Tuba/trill_major_second_up/BTb-trill_maj_second-D4-mf-N-N.wav", "/Volumes/CrucialX8/Musica/Samples/Libraries/Orchidea/Strings/Violin/ordinario/Vn-ord-E4-pp-4c-N.wav", "/Volumes/CrucialX8/Musica/Samples/Libraries/Orchidea/Strings/Violoncello/pizzicato_l_vib/Vc-pizz_lv-F#4-mf-1c-N.wav", "/Volumes/CrucialX8/Musica/Samples/Libraries/Orchidea/Winds/Bassoon/trill_major_second_up/Bn-trill_maj_second-G#4-mf-N-N.wav", "/Volumes/CrucialX8/Musica/Samples/Libraries/Orchidea/Winds/Flute/flatterzunge/Fl-flatt-A#4-mf-N-N.wav", "/Volumes/CrucialX8/Musica/Samples/Libraries/Orchidea/Strings/Viola/non_vibrato/Va-nonvib-B4-pp-1c-N.wav", "/Volumes/CrucialX8/Musica/Samples/Libraries/Orchidea/Strings/Violin/pizzicato_secco/Vn-pizz_sec-C#5-ff-3c-N.wav", "/Volumes/CrucialX8/Musica/Samples/Libraries/Orchidea/Strings/Violin+sordina/ordinario/Vn+S-ord-D5-mf-3c-N.wav", "/Volumes/CrucialX8/Musica/Samples/Libraries/Orchidea/Brass/Horn/flatterzunge_stopped/Hn-flatt_stopped-D#5-mf-N-N.wav", "/Volumes/CrucialX8/Musica/Samples/Libraries/Orchidea/Strings/Violin/crushed_to_ordinario/Vn-crush_ord-E5-mf-2c-N.wav", "/Volumes/CrucialX8/Musica/Samples/Libraries/Orchidea/Brass/Trumpet_C+sordina_cup/ordinario/TpC+SC-ord-F#5-mf-N-N.wav", "/Volumes/CrucialX8/Musica/Samples/Libraries/Orchidea/Brass/Trumpet_C/sforzato/TpC-sfz-A#5-fp-N-T12d_R100u.wav", "/Volumes/CrucialX8/Musica/Samples/Libraries/Orchidea/Strings/Viola/non_vibrato/Va-nonvib-B5-mf-1c-N.wav", "/Volumes/CrucialX8/Musica/Samples/Libraries/Orchidea/Winds/Flute/ordinario_to_flatterzunge/Fl-ord_flatt-C6-mf-N-R200u.wav", "/Volumes/CrucialX8/Musica/Samples/Libraries/Orchidea/Winds/Oboe/ordinario/Ob-ord-C#6-pp-N-T10u.wav", "/Volumes/CrucialX8/Musica/Samples/Libraries/Orchidea/Strings/Viola/tremolo/Va-trem-D6-pp-2c-N.wav", "/Volumes/CrucialX8/Musica/Samples/Libraries/Orchidea/Strings/Violin/trill_major_second_up/Vn-trill_maj_second-D#6-mf-1c-N.wav", "/Volumes/CrucialX8/Musica/Samples/Libraries/Orchidea/Winds/Oboe/crescendo_to_decrescendo/Ob-cre_dec-E6-ppmfpp-N-R100u.wav", "/Volumes/CrucialX8/Musica/Samples/Libraries/Orchidea/Strings/Viola/non_vibrato/Va-nonvib-F6-ff-1c-N.wav", "/Volumes/CrucialX8/Musica/Samples/Libraries/Orchidea/Winds/Clarinet_Bb/crescendo_to_decrescendo/ClBb-cre_dec-G6-ppmfpp-N-R100u.wav", "/Volumes/CrucialX8/Musica/Samples/Libraries/Orchidea/Winds/Oboe/note_lasting/Ob-lasting_half_sec-G#6-mf-N-T10d.wav", "/Volumes/CrucialX8/Musica/Samples/Libraries/Orchidea/Winds/Clarinet_Bb/note_lasting/ClBb-lasting_half_sec-A#6-mf-N-T11d_R100d.wav", "/Volumes/CrucialX8/Musica/Samples/Libraries/Orchidea/Winds/Flute/ordinario_to_aeolian/Fl-ord_aeol-B6-mf-N-R100d.wav", "/Volumes/CrucialX8/Musica/Samples/Libraries/Orchidea/Winds/Flute/ordinario_to_aeolian/Fl-ord_aeol-B6-mf-N-R100d.wav", "/Volumes/CrucialX8/Musica/Samples/Libraries/Orchidea/Strings/Viola/artificial_harmonic_tremolo/Va-art_harm_trem-C#7-mf-2c-N.wav", "/Volumes/CrucialX8/Musica/Samples/Libraries/Orchidea/Keyboards/Accordion/ordinario/Acc-ord-D7-ff-alt1-N.wav", "/Volumes/CrucialX8/Musica/Samples/Libraries/Orchidea/Harp/ordinario/Hp-ord-F7-pp-N-N.wav", "/Volumes/CrucialX8/Musica/Samples/Libraries/Orchidea/Harp/ordinario/Hp-ord-F7-pp-N-N.wav", "/Volumes/CrucialX8/Musica/Samples/Libraries/Orchidea/Harp/ordinario/Hp-ord-G7-ff-N-T16d.wav", "/Volumes/CrucialX8/Musica/Samples/Libraries/Orchidea/Harp/ordinario/Hp-ord-G7-ff-N-T16d.wav", "/Volumes/CrucialX8/Musica/Samples/Libraries/Orchidea/Brass/bs/Bass_Tuba+sordina/ordinario/BTb+S-ord-C1-f-N-N.wav", "/Volumes/CrucialX8/Musica/Samples/Libraries/Orchidea/Brass/bs/Bass_Tuba+sordina/ordinario/BTb+S-ord-C1-f-N-N.wav", "/Volumes/CrucialX8/Musica/Samples/Libraries/Orchidea/Brass/bs/Bass_Tuba+sordina/ordinario/BTb+S-ord-C1-f-N-N.wav", "/Volumes/CrucialX8/Musica/Samples/Libraries/Orchidea/Brass/bs/Bass_Tuba+sordina/ordinario/BTb+S-ord-C1-f-N-N.wav", "/Volumes/CrucialX8/Musica/Samples/Libraries/Orchidea/Brass/bs/Bass_Tuba+sordina/ordinario/BTb+S-ord-C1-f-N-N.wav", "/Volumes/CrucialX8/Musica/Samples/Libraries/Orchidea/Brass/bs/Bass_Tuba+sordina/ordinario/BTb+S-ord-C1-f-N-N.wav", "/Volumes/CrucialX8/Musica/Samples/Libraries/Orchidea/Brass/bs/Bass_Tuba+sordina/ordinario/BTb+S-ord-C1-f-N-N.wav", "/Volumes/CrucialX8/Musica/Samples/Libraries/Orchidea/Brass/bs/Bass_Tuba+sordina/ordinario/BTb+S-ord-C1-f-N-N.wav", "/Volumes/CrucialX8/Musica/Samples/Libraries/Orchidea/Brass/bs/Bass_Tuba+sordina/ordinario/BTb+S-ord-C1-f-N-N.wav", "/Volumes/CrucialX8/Musica/Samples/Libraries/Orchidea/Brass/bs/Bass_Tuba+sordina/ordinario/BTb+S-ord-C1-f-N-N.wav", "/Volumes/CrucialX8/Musica/Samples/Libraries/Orchidea/Brass/bs/Bass_Tuba+sordina/ordinario/BTb+S-ord-C1-f-N-N.wav", "/Volumes/CrucialX8/Musica/Samples/Libraries/Orchidea/Brass/bs/Bass_Tuba+sordina/ordinario/BTb+S-ord-C1-f-N-N.wav", "/Volumes/CrucialX8/Musica/Samples/Libraries/Orchidea/Brass/bs/Bass_Tuba+sordina/ordinario/BTb+S-ord-C1-f-N-N.wav", "/Volumes/CrucialX8/Musica/Samples/Libraries/Orchidea/Brass/bs/Bass_Tuba+sordina/ordinario/BTb+S-ord-C1-f-N-N.wav", "/Volumes/CrucialX8/Musica/Samples/Libraries/Orchidea/Brass/bs/Bass_Tuba+sordina/ordinario/BTb+S-ord-C1-f-N-N.wav", "/Volumes/CrucialX8/Musica/Samples/Libraries/Orchidea/Brass/bs/Bass_Tuba+sordina/ordinario/BTb+S-ord-C1-f-N-N.wav", "/Volumes/CrucialX8/Musica/Samples/Libraries/Orchidea/Brass/bs/Bass_Tuba+sordina/ordinario/BTb+S-ord-C1-f-N-N.wav", "/Volumes/CrucialX8/Musica/Samples/Libraries/Orchidea/Strings/Contrabass/sforzato/Cb-sfz-E2-f-3c-N.wav", "/Volumes/CrucialX8/Musica/Samples/Libraries/Orchidea/Strings/Contrabass/pizzicato_l_vib/Cb-pizz_lv-B2-mf-2c-N.wav", "/Volumes/CrucialX8/Musica/Samples/Libraries/Orchidea/Strings/Viola/ordinario/Va-ord-E3-mf-4c-T19u.wav", "/Volumes/CrucialX8/Musica/Samples/Libraries/Orchidea/Strings/Violin/pizzicato_l_vib/Vn-pizz_lv-G#3-mf-4c-N.wav", "/Volumes/CrucialX8/Musica/Samples/Libraries/Orchidea/Strings/Contrabass/decrescendo/Cb-decr-B3-ffpp-1c-R100u.wav", "/Volumes/CrucialX8/Musica/Samples/Libraries/Orchidea/Brass/bs/Bass_Tuba/trill_major_second_up/BTb-trill_maj_second-D4-mf-N-N.wav", "/Volumes/CrucialX8/Musica/Samples/Libraries/Orchidea/Strings/Violin/ordinario/Vn-ord-E4-pp-4c-N.wav", "/Volumes/CrucialX8/Musica/Samples/Libraries/Orchidea/Strings/Violoncello/pizzicato_l_vib/Vc-pizz_lv-F#4-mf-1c-N.wav", "/Volumes/CrucialX8/Musica/Samples/Libraries/Orchidea/Winds/Bassoon/trill_major_second_up/Bn-trill_maj_second-G#4-mf-N-N.wav", "/Volumes/CrucialX8/Musica/Samples/Libraries/Orchidea/Winds/Flute/flatterzunge/Fl-flatt-A#4-mf-N-N.wav", "/Volumes/CrucialX8/Musica/Samples/Libraries/Orchidea/Strings/Viola/non_vibrato/Va-nonvib-B4-pp-1c-N.wav", "/Volumes/CrucialX8/Musica/Samples/Libraries/Orchidea/Strings/Violin/pizzicato_secco/Vn-pizz_sec-C#5-ff-3c-N.wav", "/Volumes/CrucialX8/Musica/Samples/Libraries/Orchidea/Strings/Violin+sordina/ordinario/Vn+S-ord-D5-mf-3c-N.wav", "/Volumes/CrucialX8/Musica/Samples/Libraries/Orchidea/Brass/Horn/flatterzunge_stopped/Hn-flatt_stopped-D#5-mf-N-N.wav", "/Volumes/CrucialX8/Musica/Samples/Libraries/Orchidea/Strings/Violin/crushed_to_ordinario/Vn-crush_ord-E5-mf-2c-N.wav", "/Volumes/CrucialX8/Musica/Samples/Libraries/Orchidea/Brass/Trumpet_C+sordina_cup/ordinario/TpC+SC-ord-F#5-mf-N-N.wav", "/Volumes/CrucialX8/Musica/Samples/Libraries/Orchidea/Brass/Trumpet_C/sforzato/TpC-sfz-A#5-fp-N-T12d_R100u.wav", "/Volumes/CrucialX8/Musica/Samples/Libraries/Orchidea/Strings/Viola/non_vibrato/Va-nonvib-B5-mf-1c-N.wav", "/Volumes/CrucialX8/Musica/Samples/Libraries/Orchidea/Winds/Flute/ordinario_to_flatterzunge/Fl-ord_flatt-C6-mf-N-R200u.wav", "/Volumes/CrucialX8/Musica/Samples/Libraries/Orchidea/Winds/Oboe/ordinario/Ob-ord-C#6-pp-N-T10u.wav", "/Volumes/CrucialX8/Musica/Samples/Libraries/Orchidea/Strings/Viola/tremolo/Va-trem-D6-pp-2c-N.wav", "/Volumes/CrucialX8/Musica/Samples/Libraries/Orchidea/Strings/Violin/trill_major_second_up/Vn-trill_maj_second-D#6-mf-1c-N.wav", "/Volumes/CrucialX8/Musica/Samples/Libraries/Orchidea/Winds/Oboe/crescendo_to_decrescendo/Ob-cre_dec-E6-ppmfpp-N-R100u.wav", "/Volumes/CrucialX8/Musica/Samples/Libraries/Orchidea/Strings/Viola/non_vibrato/Va-nonvib-F6-ff-1c-N.wav", "/Volumes/CrucialX8/Musica/Samples/Libraries/Orchidea/Winds/Clarinet_Bb/crescendo_to_decrescendo/ClBb-cre_dec-G6-ppmfpp-N-R100u.wav", "/Volumes/CrucialX8/Musica/Samples/Libraries/Orchidea/Winds/Oboe/note_lasting/Ob-lasting_half_sec-G#6-mf-N-T10d.wav", "/Volumes/CrucialX8/Musica/Samples/Libraries/Orchidea/Winds/Clarinet_Bb/note_lasting/ClBb-lasting_half_sec-A#6-mf-N-T11d_R100d.wav", "/Volumes/CrucialX8/Musica/Samples/Libraries/Orchidea/Winds/Flute/ordinario_to_aeolian/Fl-ord_aeol-B6-mf-N-R100d.wav", "/Volumes/CrucialX8/Musica/Samples/Libraries/Orchidea/Winds/Flute/ordinario_to_aeolian/Fl-ord_aeol-B6-mf-N-R100d.wav", "/Volumes/CrucialX8/Musica/Samples/Libraries/Orchidea/Strings/Viola/artificial_harmonic_tremolo/Va-art_harm_trem-C#7-mf-2c-N.wav", "/Volumes/CrucialX8/Musica/Samples/Libraries/Orchidea/Keyboards/Accordion/ordinario/Acc-ord-D7-ff-alt1-N.wav", "/Volumes/CrucialX8/Musica/Samples/Libraries/Orchidea/Harp/ordinario/Hp-ord-F7-pp-N-N.wav", "/Volumes/CrucialX8/Musica/Samples/Libraries/Orchidea/Harp/ordinario/Hp-ord-F7-pp-N-N.wav", "/Volumes/CrucialX8/Musica/Samples/Libraries/Orchidea/Harp/ordinario/Hp-ord-G7-ff-N-T16d.wav", "/Volumes/CrucialX8/Musica/Samples/Libraries/Orchidea/Harp/ordinario/Hp-ord-G7-ff-N-T16d.wav", "/Volumes/CrucialX8/Musica/Samples/Libraries/Orchidea/Brass/bs/Bass_Tuba+sordina/ordinario/BTb+S-ord-C1-f-N-N.wav"]
)
(
~chords=[ "/Volumes/CrucialX8/Musica/Samples/Libraries/Orchidea/Strings/Contrabass/sforzato/Cb-sfz-E2-f-3c-N.wav", "/Volumes/CrucialX8/Musica/Samples/Libraries/Orchidea/Strings/Contrabass/pizzicato_l_vib/Cb-pizz_lv-B2-mf-2c-N.wav", "/Volumes/CrucialX8/Musica/Samples/Libraries/Orchidea/Strings/Viola/ordinario/Va-ord-E3-mf-4c-T19u.wav", "/Volumes/CrucialX8/Musica/Samples/Libraries/Orchidea/Strings/Violin/pizzicato_l_vib/Vn-pizz_lv-G#3-mf-4c-N.wav", "/Volumes/CrucialX8/Musica/Samples/Libraries/Orchidea/Strings/Contrabass/decrescendo/Cb-decr-B3-ffpp-1c-R100u.wav", "/Volumes/CrucialX8/Musica/Samples/Libraries/Orchidea/Brass/bs/Bass_Tuba/trill_major_second_up/BTb-trill_maj_second-D4-mf-N-N.wav", "/Volumes/CrucialX8/Musica/Samples/Libraries/Orchidea/Strings/Violin/ordinario/Vn-ord-E4-pp-4c-N.wav", "/Volumes/CrucialX8/Musica/Samples/Libraries/Orchidea/Strings/Violoncello/pizzicato_l_vib/Vc-pizz_lv-F#4-mf-1c-N.wav", "/Volumes/CrucialX8/Musica/Samples/Libraries/Orchidea/Winds/Bassoon/trill_major_second_up/Bn-trill_maj_second-G#4-mf-N-N.wav", "/Volumes/CrucialX8/Musica/Samples/Libraries/Orchidea/Winds/Flute/flatterzunge/Fl-flatt-A#4-mf-N-N.wav", "/Volumes/CrucialX8/Musica/Samples/Libraries/Orchidea/Strings/Viola/non_vibrato/Va-nonvib-B4-pp-1c-N.wav", "/Volumes/CrucialX8/Musica/Samples/Libraries/Orchidea/Strings/Violin/pizzicato_secco/Vn-pizz_sec-C#5-ff-3c-N.wav", "/Volumes/CrucialX8/Musica/Samples/Libraries/Orchidea/Strings/Violin+sordina/ordinario/Vn+S-ord-D5-mf-3c-N.wav", "/Volumes/CrucialX8/Musica/Samples/Libraries/Orchidea/Brass/Horn/flatterzunge_stopped/Hn-flatt_stopped-D#5-mf-N-N.wav", "/Volumes/CrucialX8/Musica/Samples/Libraries/Orchidea/Strings/Violin/crushed_to_ordinario/Vn-crush_ord-E5-mf-2c-N.wav", "/Volumes/CrucialX8/Musica/Samples/Libraries/Orchidea/Brass/Trumpet_C+sordina_cup/ordinario/TpC+SC-ord-F#5-mf-N-N.wav", "/Volumes/CrucialX8/Musica/Samples/Libraries/Orchidea/Brass/Trumpet_C/sforzato/TpC-sfz-A#5-fp-N-T12d_R100u.wav", "/Volumes/CrucialX8/Musica/Samples/Libraries/Orchidea/Strings/Viola/non_vibrato/Va-nonvib-B5-mf-1c-N.wav", "/Volumes/CrucialX8/Musica/Samples/Libraries/Orchidea/Winds/Flute/ordinario_to_flatterzunge/Fl-ord_flatt-C6-mf-N-R200u.wav", "/Volumes/CrucialX8/Musica/Samples/Libraries/Orchidea/Winds/Oboe/ordinario/Ob-ord-C#6-pp-N-T10u.wav", "/Volumes/CrucialX8/Musica/Samples/Libraries/Orchidea/Strings/Viola/tremolo/Va-trem-D6-pp-2c-N.wav", "/Volumes/CrucialX8/Musica/Samples/Libraries/Orchidea/Strings/Violin/trill_major_second_up/Vn-trill_maj_second-D#6-mf-1c-N.wav", "/Volumes/CrucialX8/Musica/Samples/Libraries/Orchidea/Winds/Oboe/crescendo_to_decrescendo/Ob-cre_dec-E6-ppmfpp-N-R100u.wav", "/Volumes/CrucialX8/Musica/Samples/Libraries/Orchidea/Strings/Viola/non_vibrato/Va-nonvib-F6-ff-1c-N.wav", "/Volumes/CrucialX8/Musica/Samples/Libraries/Orchidea/Winds/Clarinet_Bb/crescendo_to_decrescendo/ClBb-cre_dec-G6-ppmfpp-N-R100u.wav", "/Volumes/CrucialX8/Musica/Samples/Libraries/Orchidea/Winds/Oboe/note_lasting/Ob-lasting_half_sec-G#6-mf-N-T10d.wav", "/Volumes/CrucialX8/Musica/Samples/Libraries/Orchidea/Winds/Clarinet_Bb/note_lasting/ClBb-lasting_half_sec-A#6-mf-N-T11d_R100d.wav", "/Volumes/CrucialX8/Musica/Samples/Libraries/Orchidea/Winds/Flute/ordinario_to_aeolian/Fl-ord_aeol-B6-mf-N-R100d.wav", "/Volumes/CrucialX8/Musica/Samples/Libraries/Orchidea/Winds/Flute/ordinario_to_aeolian/Fl-ord_aeol-B6-mf-N-R100d.wav", "/Volumes/CrucialX8/Musica/Samples/Libraries/Orchidea/Strings/Viola/artificial_harmonic_tremolo/Va-art_harm_trem-C#7-mf-2c-N.wav", "/Volumes/CrucialX8/Musica/Samples/Libraries/Orchidea/Keyboards/Accordion/ordinario/Acc-ord-D7-ff-alt1-N.wav", "/Volumes/CrucialX8/Musica/Samples/Libraries/Orchidea/Harp/ordinario/Hp-ord-F7-pp-N-N.wav", "/Volumes/CrucialX8/Musica/Samples/Libraries/Orchidea/Harp/ordinario/Hp-ord-F7-pp-N-N.wav", "/Volumes/CrucialX8/Musica/Samples/Libraries/Orchidea/Harp/ordinario/Hp-ord-G7-ff-N-T16d.wav", "/Volumes/CrucialX8/Musica/Samples/Libraries/Orchidea/Harp/ordinario/Hp-ord-G7-ff-N-T16d.wav", "/Volumes/CrucialX8/Musica/Samples/Libraries/Orchidea/Brass/bs/Bass_Tuba+sordina/ordinario/BTb+S-ord-C1-f-N-N.wav", "/Volumes/CrucialX8/Musica/Samples/Libraries/Orchidea/Brass/bs/Bass_Tuba+sordina/ordinario/BTb+S-ord-C1-f-N-N.wav", "/Volumes/CrucialX8/Musica/Samples/Libraries/Orchidea/Brass/bs/Bass_Tuba+sordina/ordinario/BTb+S-ord-C1-f-N-N.wav", "/Volumes/CrucialX8/Musica/Samples/Libraries/Orchidea/Brass/bs/Bass_Tuba+sordina/ordinario/BTb+S-ord-C1-f-N-N.wav", "/Volumes/CrucialX8/Musica/Samples/Libraries/Orchidea/Brass/bs/Bass_Tuba+sordina/ordinario/BTb+S-ord-C1-f-N-N.wav", "/Volumes/CrucialX8/Musica/Samples/Libraries/Orchidea/Brass/bs/Bass_Tuba+sordina/ordinario/BTb+S-ord-C1-f-N-N.wav", "/Volumes/CrucialX8/Musica/Samples/Libraries/Orchidea/Brass/bs/Bass_Tuba+sordina/ordinario/BTb+S-ord-C1-f-N-N.wav", "/Volumes/CrucialX8/Musica/Samples/Libraries/Orchidea/Brass/bs/Bass_Tuba+sordina/ordinario/BTb+S-ord-C1-f-N-N.wav", "/Volumes/CrucialX8/Musica/Samples/Libraries/Orchidea/Brass/bs/Bass_Tuba+sordina/ordinario/BTb+S-ord-C1-f-N-N.wav", "/Volumes/CrucialX8/Musica/Samples/Libraries/Orchidea/Brass/bs/Bass_Tuba+sordina/ordinario/BTb+S-ord-C1-f-N-N.wav", "/Volumes/CrucialX8/Musica/Samples/Libraries/Orchidea/Brass/bs/Bass_Tuba+sordina/ordinario/BTb+S-ord-C1-f-N-N.wav", "/Volumes/CrucialX8/Musica/Samples/Libraries/Orchidea/Brass/bs/Bass_Tuba+sordina/ordinario/BTb+S-ord-C1-f-N-N.wav", "/Volumes/CrucialX8/Musica/Samples/Libraries/Orchidea/Brass/bs/Bass_Tuba+sordina/ordinario/BTb+S-ord-C1-f-N-N.wav", "/Volumes/CrucialX8/Musica/Samples/Libraries/Orchidea/Brass/bs/Bass_Tuba+sordina/ordinario/BTb+S-ord-C1-f-N-N.wav", "/Volumes/CrucialX8/Musica/Samples/Libraries/Orchidea/Brass/bs/Bass_Tuba+sordina/ordinario/BTb+S-ord-C1-f-N-N.wav", "/Volumes/CrucialX8/Musica/Samples/Libraries/Orchidea/Brass/bs/Bass_Tuba+sordina/ordinario/BTb+S-ord-C1-f-N-N.wav", "/Volumes/CrucialX8/Musica/Samples/Libraries/Orchidea/Brass/bs/Bass_Tuba+sordina/ordinario/BTb+S-ord-C1-f-N-N.wav", "/Volumes/CrucialX8/Musica/Samples/Libraries/Orchidea/Strings/Contrabass/sforzato/Cb-sfz-E2-f-3c-N.wav", "/Volumes/CrucialX8/Musica/Samples/Libraries/Orchidea/Strings/Contrabass/pizzicato_l_vib/Cb-pizz_lv-B2-mf-2c-N.wav", "/Volumes/CrucialX8/Musica/Samples/Libraries/Orchidea/Strings/Viola/ordinario/Va-ord-E3-mf-4c-T19u.wav", "/Volumes/CrucialX8/Musica/Samples/Libraries/Orchidea/Strings/Violin/pizzicato_l_vib/Vn-pizz_lv-G#3-mf-4c-N.wav", "/Volumes/CrucialX8/Musica/Samples/Libraries/Orchidea/Strings/Contrabass/decrescendo/Cb-decr-B3-ffpp-1c-R100u.wav", "/Volumes/CrucialX8/Musica/Samples/Libraries/Orchidea/Brass/bs/Bass_Tuba/trill_major_second_up/BTb-trill_maj_second-D4-mf-N-N.wav", "/Volumes/CrucialX8/Musica/Samples/Libraries/Orchidea/Strings/Violin/ordinario/Vn-ord-E4-pp-4c-N.wav", "/Volumes/CrucialX8/Musica/Samples/Libraries/Orchidea/Strings/Violoncello/pizzicato_l_vib/Vc-pizz_lv-F#4-mf-1c-N.wav", "/Volumes/CrucialX8/Musica/Samples/Libraries/Orchidea/Winds/Bassoon/trill_major_second_up/Bn-trill_maj_second-G#4-mf-N-N.wav", "/Volumes/CrucialX8/Musica/Samples/Libraries/Orchidea/Winds/Flute/flatterzunge/Fl-flatt-A#4-mf-N-N.wav", "/Volumes/CrucialX8/Musica/Samples/Libraries/Orchidea/Strings/Viola/non_vibrato/Va-nonvib-B4-pp-1c-N.wav", "/Volumes/CrucialX8/Musica/Samples/Libraries/Orchidea/Strings/Violin/pizzicato_secco/Vn-pizz_sec-C#5-ff-3c-N.wav", "/Volumes/CrucialX8/Musica/Samples/Libraries/Orchidea/Strings/Violin+sordina/ordinario/Vn+S-ord-D5-mf-3c-N.wav", "/Volumes/CrucialX8/Musica/Samples/Libraries/Orchidea/Brass/Horn/flatterzunge_stopped/Hn-flatt_stopped-D#5-mf-N-N.wav", "/Volumes/CrucialX8/Musica/Samples/Libraries/Orchidea/Strings/Violin/crushed_to_ordinario/Vn-crush_ord-E5-mf-2c-N.wav", "/Volumes/CrucialX8/Musica/Samples/Libraries/Orchidea/Brass/Trumpet_C+sordina_cup/ordinario/TpC+SC-ord-F#5-mf-N-N.wav", "/Volumes/CrucialX8/Musica/Samples/Libraries/Orchidea/Brass/Trumpet_C/sforzato/TpC-sfz-A#5-fp-N-T12d_R100u.wav", "/Volumes/CrucialX8/Musica/Samples/Libraries/Orchidea/Strings/Viola/non_vibrato/Va-nonvib-B5-mf-1c-N.wav", "/Volumes/CrucialX8/Musica/Samples/Libraries/Orchidea/Winds/Flute/ordinario_to_flatterzunge/Fl-ord_flatt-C6-mf-N-R200u.wav", "/Volumes/CrucialX8/Musica/Samples/Libraries/Orchidea/Winds/Oboe/ordinario/Ob-ord-C#6-pp-N-T10u.wav", "/Volumes/CrucialX8/Musica/Samples/Libraries/Orchidea/Strings/Viola/tremolo/Va-trem-D6-pp-2c-N.wav", "/Volumes/CrucialX8/Musica/Samples/Libraries/Orchidea/Strings/Violin/trill_major_second_up/Vn-trill_maj_second-D#6-mf-1c-N.wav", "/Volumes/CrucialX8/Musica/Samples/Libraries/Orchidea/Winds/Oboe/crescendo_to_decrescendo/Ob-cre_dec-E6-ppmfpp-N-R100u.wav", "/Volumes/CrucialX8/Musica/Samples/Libraries/Orchidea/Strings/Viola/non_vibrato/Va-nonvib-F6-ff-1c-N.wav", "/Volumes/CrucialX8/Musica/Samples/Libraries/Orchidea/Winds/Clarinet_Bb/crescendo_to_decrescendo/ClBb-cre_dec-G6-ppmfpp-N-R100u.wav", "/Volumes/CrucialX8/Musica/Samples/Libraries/Orchidea/Winds/Oboe/note_lasting/Ob-lasting_half_sec-G#6-mf-N-T10d.wav", "/Volumes/CrucialX8/Musica/Samples/Libraries/Orchidea/Winds/Clarinet_Bb/note_lasting/ClBb-lasting_half_sec-A#6-mf-N-T11d_R100d.wav", "/Volumes/CrucialX8/Musica/Samples/Libraries/Orchidea/Winds/Flute/ordinario_to_aeolian/Fl-ord_aeol-B6-mf-N-R100d.wav", "/Volumes/CrucialX8/Musica/Samples/Libraries/Orchidea/Winds/Flute/ordinario_to_aeolian/Fl-ord_aeol-B6-mf-N-R100d.wav", "/Volumes/CrucialX8/Musica/Samples/Libraries/Orchidea/Strings/Viola/artificial_harmonic_tremolo/Va-art_harm_trem-C#7-mf-2c-N.wav", "/Volumes/CrucialX8/Musica/Samples/Libraries/Orchidea/Keyboards/Accordion/ordinario/Acc-ord-D7-ff-alt1-N.wav", "/Volumes/CrucialX8/Musica/Samples/Libraries/Orchidea/Harp/ordinario/Hp-ord-F7-pp-N-N.wav", "/Volumes/CrucialX8/Musica/Samples/Libraries/Orchidea/Harp/ordinario/Hp-ord-F7-pp-N-N.wav", "/Volumes/CrucialX8/Musica/Samples/Libraries/Orchidea/Harp/ordinario/Hp-ord-G7-ff-N-T16d.wav", "/Volumes/CrucialX8/Musica/Samples/Libraries/Orchidea/Harp/ordinario/Hp-ord-G7-ff-N-T16d.wav", "/Volumes/CrucialX8/Musica/Samples/Libraries/Orchidea/Brass/bs/Bass_Tuba+sordina/ordinario/BTb+S-ord-C1-f-N-N.wav", "/Volumes/CrucialX8/Musica/Samples/Libraries/Orchidea/Brass/bs/Bass_Tuba+sordina/ordinario/BTb+S-ord-C1-f-N-N.wav", "/Volumes/CrucialX8/Musica/Samples/Libraries/Orchidea/Brass/bs/Bass_Tuba+sordina/ordinario/BTb+S-ord-C1-f-N-N.wav", "/Volumes/CrucialX8/Musica/Samples/Libraries/Orchidea/Brass/bs/Bass_Tuba+sordina/ordinario/BTb+S-ord-C1-f-N-N.wav", "/Volumes/CrucialX8/Musica/Samples/Libraries/Orchidea/Brass/bs/Bass_Tuba+sordina/ordinario/BTb+S-ord-C1-f-N-N.wav", "/Volumes/CrucialX8/Musica/Samples/Libraries/Orchidea/Brass/bs/Bass_Tuba+sordina/ordinario/BTb+S-ord-C1-f-N-N.wav", "/Volumes/CrucialX8/Musica/Samples/Libraries/Orchidea/Brass/bs/Bass_Tuba+sordina/ordinario/BTb+S-ord-C1-f-N-N.wav", "/Volumes/CrucialX8/Musica/Samples/Libraries/Orchidea/Brass/bs/Bass_Tuba+sordina/ordinario/BTb+S-ord-C1-f-N-N.wav", "/Volumes/CrucialX8/Musica/Samples/Libraries/Orchidea/Brass/bs/Bass_Tuba+sordina/ordinario/BTb+S-ord-C1-f-N-N.wav", "/Volumes/CrucialX8/Musica/Samples/Libraries/Orchidea/Brass/bs/Bass_Tuba+sordina/ordinario/BTb+S-ord-C1-f-N-N.wav", "/Volumes/CrucialX8/Musica/Samples/Libraries/Orchidea/Brass/bs/Bass_Tuba+sordina/ordinario/BTb+S-ord-C1-f-N-N.wav", "/Volumes/CrucialX8/Musica/Samples/Libraries/Orchidea/Brass/bs/Bass_Tuba+sordina/ordinario/BTb+S-ord-C1-f-N-N.wav", "/Volumes/CrucialX8/Musica/Samples/Libraries/Orchidea/Brass/bs/Bass_Tuba+sordina/ordinario/BTb+S-ord-C1-f-N-N.wav", "/Volumes/CrucialX8/Musica/Samples/Libraries/Orchidea/Brass/bs/Bass_Tuba+sordina/ordinario/BTb+S-ord-C1-f-N-N.wav", "/Volumes/CrucialX8/Musica/Samples/Libraries/Orchidea/Brass/bs/Bass_Tuba+sordina/ordinario/BTb+S-ord-C1-f-N-N.wav", "/Volumes/CrucialX8/Musica/Samples/Libraries/Orchidea/Brass/bs/Bass_Tuba+sordina/ordinario/BTb+S-ord-C1-f-N-N.wav", "/Volumes/CrucialX8/Musica/Samples/Libraries/Orchidea/Brass/bs/Bass_Tuba+sordina/ordinario/BTb+S-ord-C1-f-N-N.wav", "/Volumes/CrucialX8/Musica/Samples/Libraries/Orchidea/Strings/Contrabass/sforzato/Cb-sfz-E2-f-3c-N.wav", "/Volumes/CrucialX8/Musica/Samples/Libraries/Orchidea/Strings/Contrabass/pizzicato_l_vib/Cb-pizz_lv-B2-mf-2c-N.wav", "/Volumes/CrucialX8/Musica/Samples/Libraries/Orchidea/Strings/Viola/ordinario/Va-ord-E3-mf-4c-T19u.wav", "/Volumes/CrucialX8/Musica/Samples/Libraries/Orchidea/Strings/Violin/pizzicato_l_vib/Vn-pizz_lv-G#3-mf-4c-N.wav", "/Volumes/CrucialX8/Musica/Samples/Libraries/Orchidea/Strings/Contrabass/decrescendo/Cb-decr-B3-ffpp-1c-R100u.wav", "/Volumes/CrucialX8/Musica/Samples/Libraries/Orchidea/Brass/bs/Bass_Tuba/trill_major_second_up/BTb-trill_maj_second-D4-mf-N-N.wav", "/Volumes/CrucialX8/Musica/Samples/Libraries/Orchidea/Strings/Violin/ordinario/Vn-ord-E4-pp-4c-N.wav", "/Volumes/CrucialX8/Musica/Samples/Libraries/Orchidea/Strings/Violoncello/pizzicato_l_vib/Vc-pizz_lv-F#4-mf-1c-N.wav", "/Volumes/CrucialX8/Musica/Samples/Libraries/Orchidea/Winds/Bassoon/trill_major_second_up/Bn-trill_maj_second-G#4-mf-N-N.wav", "/Volumes/CrucialX8/Musica/Samples/Libraries/Orchidea/Winds/Flute/flatterzunge/Fl-flatt-A#4-mf-N-N.wav", "/Volumes/CrucialX8/Musica/Samples/Libraries/Orchidea/Strings/Viola/non_vibrato/Va-nonvib-B4-pp-1c-N.wav", "/Volumes/CrucialX8/Musica/Samples/Libraries/Orchidea/Strings/Violin/pizzicato_secco/Vn-pizz_sec-C#5-ff-3c-N.wav", "/Volumes/CrucialX8/Musica/Samples/Libraries/Orchidea/Strings/Violin+sordina/ordinario/Vn+S-ord-D5-mf-3c-N.wav", "/Volumes/CrucialX8/Musica/Samples/Libraries/Orchidea/Brass/Horn/flatterzunge_stopped/Hn-flatt_stopped-D#5-mf-N-N.wav", "/Volumes/CrucialX8/Musica/Samples/Libraries/Orchidea/Strings/Violin/crushed_to_ordinario/Vn-crush_ord-E5-mf-2c-N.wav", "/Volumes/CrucialX8/Musica/Samples/Libraries/Orchidea/Brass/Trumpet_C+sordina_cup/ordinario/TpC+SC-ord-F#5-mf-N-N.wav", "/Volumes/CrucialX8/Musica/Samples/Libraries/Orchidea/Brass/Trumpet_C/sforzato/TpC-sfz-A#5-fp-N-T12d_R100u.wav", "/Volumes/CrucialX8/Musica/Samples/Libraries/Orchidea/Strings/Viola/non_vibrato/Va-nonvib-B5-mf-1c-N.wav", "/Volumes/CrucialX8/Musica/Samples/Libraries/Orchidea/Winds/Flute/ordinario_to_flatterzunge/Fl-ord_flatt-C6-mf-N-R200u.wav", "/Volumes/CrucialX8/Musica/Samples/Libraries/Orchidea/Winds/Oboe/ordinario/Ob-ord-C#6-pp-N-T10u.wav", "/Volumes/CrucialX8/Musica/Samples/Libraries/Orchidea/Strings/Viola/tremolo/Va-trem-D6-pp-2c-N.wav", "/Volumes/CrucialX8/Musica/Samples/Libraries/Orchidea/Strings/Violin/trill_major_second_up/Vn-trill_maj_second-D#6-mf-1c-N.wav", "/Volumes/CrucialX8/Musica/Samples/Libraries/Orchidea/Winds/Oboe/crescendo_to_decrescendo/Ob-cre_dec-E6-ppmfpp-N-R100u.wav", "/Volumes/CrucialX8/Musica/Samples/Libraries/Orchidea/Strings/Viola/non_vibrato/Va-nonvib-F6-ff-1c-N.wav", "/Volumes/CrucialX8/Musica/Samples/Libraries/Orchidea/Winds/Clarinet_Bb/crescendo_to_decrescendo/ClBb-cre_dec-G6-ppmfpp-N-R100u.wav", "/Volumes/CrucialX8/Musica/Samples/Libraries/Orchidea/Winds/Oboe/note_lasting/Ob-lasting_half_sec-G#6-mf-N-T10d.wav", "/Volumes/CrucialX8/Musica/Samples/Libraries/Orchidea/Winds/Clarinet_Bb/note_lasting/ClBb-lasting_half_sec-A#6-mf-N-T11d_R100d.wav", "/Volumes/CrucialX8/Musica/Samples/Libraries/Orchidea/Winds/Flute/ordinario_to_aeolian/Fl-ord_aeol-B6-mf-N-R100d.wav", "/Volumes/CrucialX8/Musica/Samples/Libraries/Orchidea/Winds/Flute/ordinario_to_aeolian/Fl-ord_aeol-B6-mf-N-R100d.wav", "/Volumes/CrucialX8/Musica/Samples/Libraries/Orchidea/Strings/Viola/artificial_harmonic_tremolo/Va-art_harm_trem-C#7-mf-2c-N.wav", "/Volumes/CrucialX8/Musica/Samples/Libraries/Orchidea/Keyboards/Accordion/ordinario/Acc-ord-D7-ff-alt1-N.wav", "/Volumes/CrucialX8/Musica/Samples/Libraries/Orchidea/Harp/ordinario/Hp-ord-F7-pp-N-N.wav", "/Volumes/CrucialX8/Musica/Samples/Libraries/Orchidea/Harp/ordinario/Hp-ord-F7-pp-N-N.wav", "/Volumes/CrucialX8/Musica/Samples/Libraries/Orchidea/Harp/ordinario/Hp-ord-G7-ff-N-T16d.wav", "/Volumes/CrucialX8/Musica/Samples/Libraries/Orchidea/Harp/ordinario/Hp-ord-G7-ff-N-T16d.wav", "/Volumes/CrucialX8/Musica/Samples/Libraries/Orchidea/Brass/bs/Bass_Tuba+sordina/ordinario/BTb+S-ord-C1-f-N-N.wav", "/Volumes/CrucialX8/Musica/Samples/Libraries/Orchidea/Brass/bs/Bass_Tuba+sordina/ordinario/BTb+S-ord-C1-f-N-N.wav", "/Volumes/CrucialX8/Musica/Samples/Libraries/Orchidea/Brass/bs/Bass_Tuba+sordina/ordinario/BTb+S-ord-C1-f-N-N.wav", "/Volumes/CrucialX8/Musica/Samples/Libraries/Orchidea/Brass/bs/Bass_Tuba+sordina/ordinario/BTb+S-ord-C1-f-N-N.wav", "/Volumes/CrucialX8/Musica/Samples/Libraries/Orchidea/Brass/bs/Bass_Tuba+sordina/ordinario/BTb+S-ord-C1-f-N-N.wav", "/Volumes/CrucialX8/Musica/Samples/Libraries/Orchidea/Brass/bs/Bass_Tuba+sordina/ordinario/BTb+S-ord-C1-f-N-N.wav", "/Volumes/CrucialX8/Musica/Samples/Libraries/Orchidea/Brass/bs/Bass_Tuba+sordina/ordinario/BTb+S-ord-C1-f-N-N.wav", "/Volumes/CrucialX8/Musica/Samples/Libraries/Orchidea/Brass/bs/Bass_Tuba+sordina/ordinario/BTb+S-ord-C1-f-N-N.wav", "/Volumes/CrucialX8/Musica/Samples/Libraries/Orchidea/Brass/bs/Bass_Tuba+sordina/ordinario/BTb+S-ord-C1-f-N-N.wav", "/Volumes/CrucialX8/Musica/Samples/Libraries/Orchidea/Brass/bs/Bass_Tuba+sordina/ordinario/BTb+S-ord-C1-f-N-N.wav", "/Volumes/CrucialX8/Musica/Samples/Libraries/Orchidea/Brass/bs/Bass_Tuba+sordina/ordinario/BTb+S-ord-C1-f-N-N.wav", "/Volumes/CrucialX8/Musica/Samples/Libraries/Orchidea/Brass/bs/Bass_Tuba+sordina/ordinario/BTb+S-ord-C1-f-N-N.wav", "/Volumes/CrucialX8/Musica/Samples/Libraries/Orchidea/Brass/bs/Bass_Tuba+sordina/ordinario/BTb+S-ord-C1-f-N-N.wav", "/Volumes/CrucialX8/Musica/Samples/Libraries/Orchidea/Brass/bs/Bass_Tuba+sordina/ordinario/BTb+S-ord-C1-f-N-N.wav", "/Volumes/CrucialX8/Musica/Samples/Libraries/Orchidea/Brass/bs/Bass_Tuba+sordina/ordinario/BTb+S-ord-C1-f-N-N.wav", "/Volumes/CrucialX8/Musica/Samples/Libraries/Orchidea/Brass/bs/Bass_Tuba+sordina/ordinario/BTb+S-ord-C1-f-N-N.wav", "/Volumes/CrucialX8/Musica/Samples/Libraries/Orchidea/Brass/bs/Bass_Tuba+sordina/ordinario/BTb+S-ord-C1-f-N-N.wav", "/Volumes/CrucialX8/Musica/Samples/Libraries/Orchidea/Strings/Contrabass/sforzato/Cb-sfz-E2-f-3c-N.wav", "/Volumes/CrucialX8/Musica/Samples/Libraries/Orchidea/Strings/Contrabass/pizzicato_l_vib/Cb-pizz_lv-B2-mf-2c-N.wav", "/Volumes/CrucialX8/Musica/Samples/Libraries/Orchidea/Strings/Viola/ordinario/Va-ord-E3-mf-4c-T19u.wav", "/Volumes/CrucialX8/Musica/Samples/Libraries/Orchidea/Strings/Violin/pizzicato_l_vib/Vn-pizz_lv-G#3-mf-4c-N.wav", "/Volumes/CrucialX8/Musica/Samples/Libraries/Orchidea/Strings/Contrabass/decrescendo/Cb-decr-B3-ffpp-1c-R100u.wav", "/Volumes/CrucialX8/Musica/Samples/Libraries/Orchidea/Brass/bs/Bass_Tuba/trill_major_second_up/BTb-trill_maj_second-D4-mf-N-N.wav", "/Volumes/CrucialX8/Musica/Samples/Libraries/Orchidea/Strings/Violin/ordinario/Vn-ord-E4-pp-4c-N.wav", "/Volumes/CrucialX8/Musica/Samples/Libraries/Orchidea/Strings/Violoncello/pizzicato_l_vib/Vc-pizz_lv-F#4-mf-1c-N.wav", "/Volumes/CrucialX8/Musica/Samples/Libraries/Orchidea/Winds/Bassoon/trill_major_second_up/Bn-trill_maj_second-G#4-mf-N-N.wav", "/Volumes/CrucialX8/Musica/Samples/Libraries/Orchidea/Winds/Flute/flatterzunge/Fl-flatt-A#4-mf-N-N.wav", "/Volumes/CrucialX8/Musica/Samples/Libraries/Orchidea/Strings/Viola/non_vibrato/Va-nonvib-B4-pp-1c-N.wav", "/Volumes/CrucialX8/Musica/Samples/Libraries/Orchidea/Strings/Violin/pizzicato_secco/Vn-pizz_sec-C#5-ff-3c-N.wav", "/Volumes/CrucialX8/Musica/Samples/Libraries/Orchidea/Strings/Violin+sordina/ordinario/Vn+S-ord-D5-mf-3c-N.wav", "/Volumes/CrucialX8/Musica/Samples/Libraries/Orchidea/Brass/Horn/flatterzunge_stopped/Hn-flatt_stopped-D#5-mf-N-N.wav", "/Volumes/CrucialX8/Musica/Samples/Libraries/Orchidea/Strings/Violin/crushed_to_ordinario/Vn-crush_ord-E5-mf-2c-N.wav", "/Volumes/CrucialX8/Musica/Samples/Libraries/Orchidea/Brass/Trumpet_C+sordina_cup/ordinario/TpC+SC-ord-F#5-mf-N-N.wav", "/Volumes/CrucialX8/Musica/Samples/Libraries/Orchidea/Brass/Trumpet_C/sforzato/TpC-sfz-A#5-fp-N-T12d_R100u.wav", "/Volumes/CrucialX8/Musica/Samples/Libraries/Orchidea/Strings/Viola/non_vibrato/Va-nonvib-B5-mf-1c-N.wav", "/Volumes/CrucialX8/Musica/Samples/Libraries/Orchidea/Winds/Flute/ordinario_to_flatterzunge/Fl-ord_flatt-C6-mf-N-R200u.wav", "/Volumes/CrucialX8/Musica/Samples/Libraries/Orchidea/Winds/Oboe/ordinario/Ob-ord-C#6-pp-N-T10u.wav", "/Volumes/CrucialX8/Musica/Samples/Libraries/Orchidea/Strings/Viola/tremolo/Va-trem-D6-pp-2c-N.wav", "/Volumes/CrucialX8/Musica/Samples/Libraries/Orchidea/Strings/Violin/trill_major_second_up/Vn-trill_maj_second-D#6-mf-1c-N.wav", "/Volumes/CrucialX8/Musica/Samples/Libraries/Orchidea/Winds/Oboe/crescendo_to_decrescendo/Ob-cre_dec-E6-ppmfpp-N-R100u.wav", "/Volumes/CrucialX8/Musica/Samples/Libraries/Orchidea/Strings/Viola/non_vibrato/Va-nonvib-F6-ff-1c-N.wav", "/Volumes/CrucialX8/Musica/Samples/Libraries/Orchidea/Winds/Clarinet_Bb/crescendo_to_decrescendo/ClBb-cre_dec-G6-ppmfpp-N-R100u.wav", "/Volumes/CrucialX8/Musica/Samples/Libraries/Orchidea/Winds/Oboe/note_lasting/Ob-lasting_half_sec-G#6-mf-N-T10d.wav", "/Volumes/CrucialX8/Musica/Samples/Libraries/Orchidea/Winds/Clarinet_Bb/note_lasting/ClBb-lasting_half_sec-A#6-mf-N-T11d_R100d.wav", "/Volumes/CrucialX8/Musica/Samples/Libraries/Orchidea/Winds/Flute/ordinario_to_aeolian/Fl-ord_aeol-B6-mf-N-R100d.wav", "/Volumes/CrucialX8/Musica/Samples/Libraries/Orchidea/Winds/Flute/ordinario_to_aeolian/Fl-ord_aeol-B6-mf-N-R100d.wav", "/Volumes/CrucialX8/Musica/Samples/Libraries/Orchidea/Strings/Viola/artificial_harmonic_tremolo/Va-art_harm_trem-C#7-mf-2c-N.wav", "/Volumes/CrucialX8/Musica/Samples/Libraries/Orchidea/Keyboards/Accordion/ordinario/Acc-ord-D7-ff-alt1-N.wav", "/Volumes/CrucialX8/Musica/Samples/Libraries/Orchidea/Harp/ordinario/Hp-ord-F7-pp-N-N.wav", "/Volumes/CrucialX8/Musica/Samples/Libraries/Orchidea/Harp/ordinario/Hp-ord-F7-pp-N-N.wav", "/Volumes/CrucialX8/Musica/Samples/Libraries/Orchidea/Harp/ordinario/Hp-ord-G7-ff-N-T16d.wav", "/Volumes/CrucialX8/Musica/Samples/Libraries/Orchidea/Harp/ordinario/Hp-ord-G7-ff-N-T16d.wav", "/Volumes/CrucialX8/Musica/Samples/Libraries/Orchidea/Brass/bs/Bass_Tuba+sordina/ordinario/BTb+S-ord-C1-f-N-N.wav", "/Volumes/CrucialX8/Musica/Samples/Libraries/Orchidea/Brass/bs/Bass_Tuba+sordina/ordinario/BTb+S-ord-C1-f-N-N.wav", "/Volumes/CrucialX8/Musica/Samples/Libraries/Orchidea/Brass/bs/Bass_Tuba+sordina/ordinario/BTb+S-ord-C1-f-N-N.wav", "/Volumes/CrucialX8/Musica/Samples/Libraries/Orchidea/Brass/bs/Bass_Tuba+sordina/ordinario/BTb+S-ord-C1-f-N-N.wav", "/Volumes/CrucialX8/Musica/Samples/Libraries/Orchidea/Brass/bs/Bass_Tuba+sordina/ordinario/BTb+S-ord-C1-f-N-N.wav", "/Volumes/CrucialX8/Musica/Samples/Libraries/Orchidea/Brass/bs/Bass_Tuba+sordina/ordinario/BTb+S-ord-C1-f-N-N.wav", "/Volumes/CrucialX8/Musica/Samples/Libraries/Orchidea/Brass/bs/Bass_Tuba+sordina/ordinario/BTb+S-ord-C1-f-N-N.wav", "/Volumes/CrucialX8/Musica/Samples/Libraries/Orchidea/Brass/bs/Bass_Tuba+sordina/ordinario/BTb+S-ord-C1-f-N-N.wav", "/Volumes/CrucialX8/Musica/Samples/Libraries/Orchidea/Brass/bs/Bass_Tuba+sordina/ordinario/BTb+S-ord-C1-f-N-N.wav", "/Volumes/CrucialX8/Musica/Samples/Libraries/Orchidea/Brass/bs/Bass_Tuba+sordina/ordinario/BTb+S-ord-C1-f-N-N.wav", "/Volumes/CrucialX8/Musica/Samples/Libraries/Orchidea/Brass/bs/Bass_Tuba+sordina/ordinario/BTb+S-ord-C1-f-N-N.wav", "/Volumes/CrucialX8/Musica/Samples/Libraries/Orchidea/Brass/bs/Bass_Tuba+sordina/ordinario/BTb+S-ord-C1-f-N-N.wav", "/Volumes/CrucialX8/Musica/Samples/Libraries/Orchidea/Brass/bs/Bass_Tuba+sordina/ordinario/BTb+S-ord-C1-f-N-N.wav", "/Volumes/CrucialX8/Musica/Samples/Libraries/Orchidea/Brass/bs/Bass_Tuba+sordina/ordinario/BTb+S-ord-C1-f-N-N.wav", "/Volumes/CrucialX8/Musica/Samples/Libraries/Orchidea/Brass/bs/Bass_Tuba+sordina/ordinario/BTb+S-ord-C1-f-N-N.wav", "/Volumes/CrucialX8/Musica/Samples/Libraries/Orchidea/Brass/bs/Bass_Tuba+sordina/ordinario/BTb+S-ord-C1-f-N-N.wav", "/Volumes/CrucialX8/Musica/Samples/Libraries/Orchidea/Brass/bs/Bass_Tuba+sordina/ordinario/BTb+S-ord-C1-f-N-N.wav", "/Volumes/CrucialX8/Musica/Samples/Libraries/Orchidea/Strings/Contrabass/sforzato/Cb-sfz-E2-f-3c-N.wav", "/Volumes/CrucialX8/Musica/Samples/Libraries/Orchidea/Strings/Contrabass/pizzicato_l_vib/Cb-pizz_lv-B2-mf-2c-N.wav", "/Volumes/CrucialX8/Musica/Samples/Libraries/Orchidea/Strings/Viola/ordinario/Va-ord-E3-mf-4c-T19u.wav", "/Volumes/CrucialX8/Musica/Samples/Libraries/Orchidea/Strings/Violin/pizzicato_l_vib/Vn-pizz_lv-G#3-mf-4c-N.wav", "/Volumes/CrucialX8/Musica/Samples/Libraries/Orchidea/Strings/Contrabass/decrescendo/Cb-decr-B3-ffpp-1c-R100u.wav", "/Volumes/CrucialX8/Musica/Samples/Libraries/Orchidea/Brass/bs/Bass_Tuba/trill_major_second_up/BTb-trill_maj_second-D4-mf-N-N.wav", "/Volumes/CrucialX8/Musica/Samples/Libraries/Orchidea/Strings/Violin/ordinario/Vn-ord-E4-pp-4c-N.wav", "/Volumes/CrucialX8/Musica/Samples/Libraries/Orchidea/Strings/Violoncello/pizzicato_l_vib/Vc-pizz_lv-F#4-mf-1c-N.wav", "/Volumes/CrucialX8/Musica/Samples/Libraries/Orchidea/Winds/Bassoon/trill_major_second_up/Bn-trill_maj_second-G#4-mf-N-N.wav", "/Volumes/CrucialX8/Musica/Samples/Libraries/Orchidea/Winds/Flute/flatterzunge/Fl-flatt-A#4-mf-N-N.wav", "/Volumes/CrucialX8/Musica/Samples/Libraries/Orchidea/Strings/Viola/non_vibrato/Va-nonvib-B4-pp-1c-N.wav", "/Volumes/CrucialX8/Musica/Samples/Libraries/Orchidea/Strings/Violin/pizzicato_secco/Vn-pizz_sec-C#5-ff-3c-N.wav", "/Volumes/CrucialX8/Musica/Samples/Libraries/Orchidea/Strings/Violin+sordina/ordinario/Vn+S-ord-D5-mf-3c-N.wav", "/Volumes/CrucialX8/Musica/Samples/Libraries/Orchidea/Brass/Horn/flatterzunge_stopped/Hn-flatt_stopped-D#5-mf-N-N.wav", "/Volumes/CrucialX8/Musica/Samples/Libraries/Orchidea/Strings/Violin/crushed_to_ordinario/Vn-crush_ord-E5-mf-2c-N.wav", "/Volumes/CrucialX8/Musica/Samples/Libraries/Orchidea/Brass/Trumpet_C+sordina_cup/ordinario/TpC+SC-ord-F#5-mf-N-N.wav", "/Volumes/CrucialX8/Musica/Samples/Libraries/Orchidea/Brass/Trumpet_C/sforzato/TpC-sfz-A#5-fp-N-T12d_R100u.wav", "/Volumes/CrucialX8/Musica/Samples/Libraries/Orchidea/Strings/Viola/non_vibrato/Va-nonvib-B5-mf-1c-N.wav", "/Volumes/CrucialX8/Musica/Samples/Libraries/Orchidea/Winds/Flute/ordinario_to_flatterzunge/Fl-ord_flatt-C6-mf-N-R200u.wav", "/Volumes/CrucialX8/Musica/Samples/Libraries/Orchidea/Winds/Oboe/ordinario/Ob-ord-C#6-pp-N-T10u.wav", "/Volumes/CrucialX8/Musica/Samples/Libraries/Orchidea/Strings/Viola/tremolo/Va-trem-D6-pp-2c-N.wav", "/Volumes/CrucialX8/Musica/Samples/Libraries/Orchidea/Strings/Violin/trill_major_second_up/Vn-trill_maj_second-D#6-mf-1c-N.wav", "/Volumes/CrucialX8/Musica/Samples/Libraries/Orchidea/Winds/Oboe/crescendo_to_decrescendo/Ob-cre_dec-E6-ppmfpp-N-R100u.wav", "/Volumes/CrucialX8/Musica/Samples/Libraries/Orchidea/Strings/Viola/non_vibrato/Va-nonvib-F6-ff-1c-N.wav", "/Volumes/CrucialX8/Musica/Samples/Libraries/Orchidea/Winds/Clarinet_Bb/crescendo_to_decrescendo/ClBb-cre_dec-G6-ppmfpp-N-R100u.wav", "/Volumes/CrucialX8/Musica/Samples/Libraries/Orchidea/Winds/Oboe/note_lasting/Ob-lasting_half_sec-G#6-mf-N-T10d.wav", "/Volumes/CrucialX8/Musica/Samples/Libraries/Orchidea/Winds/Clarinet_Bb/note_lasting/ClBb-lasting_half_sec-A#6-mf-N-T11d_R100d.wav", "/Volumes/CrucialX8/Musica/Samples/Libraries/Orchidea/Winds/Flute/ordinario_to_aeolian/Fl-ord_aeol-B6-mf-N-R100d.wav", "/Volumes/CrucialX8/Musica/Samples/Libraries/Orchidea/Winds/Flute/ordinario_to_aeolian/Fl-ord_aeol-B6-mf-N-R100d.wav", "/Volumes/CrucialX8/Musica/Samples/Libraries/Orchidea/Strings/Viola/artificial_harmonic_tremolo/Va-art_harm_trem-C#7-mf-2c-N.wav", "/Volumes/CrucialX8/Musica/Samples/Libraries/Orchidea/Keyboards/Accordion/ordinario/Acc-ord-D7-ff-alt1-N.wav", "/Volumes/CrucialX8/Musica/Samples/Libraries/Orchidea/Harp/ordinario/Hp-ord-F7-pp-N-N.wav", "/Volumes/CrucialX8/Musica/Samples/Libraries/Orchidea/Harp/ordinario/Hp-ord-F7-pp-N-N.wav", "/Volumes/CrucialX8/Musica/Samples/Libraries/Orchidea/Harp/ordinario/Hp-ord-G7-ff-N-T16d.wav", "/Volumes/CrucialX8/Musica/Samples/Libraries/Orchidea/Harp/ordinario/Hp-ord-G7-ff-N-T16d.wav", "/Volumes/CrucialX8/Musica/Samples/Libraries/Orchidea/Brass/bs/Bass_Tuba+sordina/ordinario/BTb+S-ord-C1-f-N-N.wav", "/Volumes/CrucialX8/Musica/Samples/Libraries/Orchidea/Brass/bs/Bass_Tuba+sordina/ordinario/BTb+S-ord-C1-f-N-N.wav", "/Volumes/CrucialX8/Musica/Samples/Libraries/Orchidea/Brass/bs/Bass_Tuba+sordina/ordinario/BTb+S-ord-C1-f-N-N.wav", "/Volumes/CrucialX8/Musica/Samples/Libraries/Orchidea/Brass/bs/Bass_Tuba+sordina/ordinario/BTb+S-ord-C1-f-N-N.wav", "/Volumes/CrucialX8/Musica/Samples/Libraries/Orchidea/Brass/bs/Bass_Tuba+sordina/ordinario/BTb+S-ord-C1-f-N-N.wav", "/Volumes/CrucialX8/Musica/Samples/Libraries/Orchidea/Brass/bs/Bass_Tuba+sordina/ordinario/BTb+S-ord-C1-f-N-N.wav", "/Volumes/CrucialX8/Musica/Samples/Libraries/Orchidea/Brass/bs/Bass_Tuba+sordina/ordinario/BTb+S-ord-C1-f-N-N.wav", "/Volumes/CrucialX8/Musica/Samples/Libraries/Orchidea/Brass/bs/Bass_Tuba+sordina/ordinario/BTb+S-ord-C1-f-N-N.wav", "/Volumes/CrucialX8/Musica/Samples/Libraries/Orchidea/Brass/bs/Bass_Tuba+sordina/ordinario/BTb+S-ord-C1-f-N-N.wav", "/Volumes/CrucialX8/Musica/Samples/Libraries/Orchidea/Brass/bs/Bass_Tuba+sordina/ordinario/BTb+S-ord-C1-f-N-N.wav", "/Volumes/CrucialX8/Musica/Samples/Libraries/Orchidea/Brass/bs/Bass_Tuba+sordina/ordinario/BTb+S-ord-C1-f-N-N.wav", "/Volumes/CrucialX8/Musica/Samples/Libraries/Orchidea/Brass/bs/Bass_Tuba+sordina/ordinario/BTb+S-ord-C1-f-N-N.wav", "/Volumes/CrucialX8/Musica/Samples/Libraries/Orchidea/Brass/bs/Bass_Tuba+sordina/ordinario/BTb+S-ord-C1-f-N-N.wav", "/Volumes/CrucialX8/Musica/Samples/Libraries/Orchidea/Brass/bs/Bass_Tuba+sordina/ordinario/BTb+S-ord-C1-f-N-N.wav", "/Volumes/CrucialX8/Musica/Samples/Libraries/Orchidea/Brass/bs/Bass_Tuba+sordina/ordinario/BTb+S-ord-C1-f-N-N.wav", "/Volumes/CrucialX8/Musica/Samples/Libraries/Orchidea/Brass/bs/Bass_Tuba+sordina/ordinario/BTb+S-ord-C1-f-N-N.wav", "/Volumes/CrucialX8/Musica/Samples/Libraries/Orchidea/Brass/bs/Bass_Tuba+sordina/ordinario/BTb+S-ord-C1-f-N-N.wav", "/Volumes/CrucialX8/Musica/Samples/Libraries/Orchidea/Strings/Contrabass/sforzato/Cb-sfz-E2-f-3c-N.wav", "/Volumes/CrucialX8/Musica/Samples/Libraries/Orchidea/Strings/Contrabass/pizzicato_l_vib/Cb-pizz_lv-B2-mf-2c-N.wav", "/Volumes/CrucialX8/Musica/Samples/Libraries/Orchidea/Strings/Viola/ordinario/Va-ord-E3-mf-4c-T19u.wav", "/Volumes/CrucialX8/Musica/Samples/Libraries/Orchidea/Strings/Violin/pizzicato_l_vib/Vn-pizz_lv-G#3-mf-4c-N.wav", "/Volumes/CrucialX8/Musica/Samples/Libraries/Orchidea/Strings/Contrabass/decrescendo/Cb-decr-B3-ffpp-1c-R100u.wav", "/Volumes/CrucialX8/Musica/Samples/Libraries/Orchidea/Brass/bs/Bass_Tuba/trill_major_second_up/BTb-trill_maj_second-D4-mf-N-N.wav", "/Volumes/CrucialX8/Musica/Samples/Libraries/Orchidea/Strings/Violin/ordinario/Vn-ord-E4-pp-4c-N.wav", "/Volumes/CrucialX8/Musica/Samples/Libraries/Orchidea/Strings/Violoncello/pizzicato_l_vib/Vc-pizz_lv-F#4-mf-1c-N.wav", "/Volumes/CrucialX8/Musica/Samples/Libraries/Orchidea/Winds/Bassoon/trill_major_second_up/Bn-trill_maj_second-G#4-mf-N-N.wav", "/Volumes/CrucialX8/Musica/Samples/Libraries/Orchidea/Winds/Flute/flatterzunge/Fl-flatt-A#4-mf-N-N.wav", "/Volumes/CrucialX8/Musica/Samples/Libraries/Orchidea/Strings/Viola/non_vibrato/Va-nonvib-B4-pp-1c-N.wav", "/Volumes/CrucialX8/Musica/Samples/Libraries/Orchidea/Strings/Violoncello/sul_ponticello_to_sul_tasto/Vc-pont_tasto-C5-mf-1c-N.wav", "/Volumes/CrucialX8/Musica/Samples/Libraries/Orchidea/Strings/Violin+sordina/ordinario/Vn+S-ord-D5-mf-3c-N.wav", "/Volumes/CrucialX8/Musica/Samples/Libraries/Orchidea/Brass/Horn/flatterzunge_stopped/Hn-flatt_stopped-D#5-mf-N-N.wav", "/Volumes/CrucialX8/Musica/Samples/Libraries/Orchidea/Strings/Violin/crushed_to_ordinario/Vn-crush_ord-E5-mf-2c-N.wav", "/Volumes/CrucialX8/Musica/Samples/Libraries/Orchidea/Brass/Trumpet_C+sordina_cup/ordinario/TpC+SC-ord-F#5-mf-N-N.wav", "/Volumes/CrucialX8/Musica/Samples/Libraries/Orchidea/Brass/Trumpet_C/sforzato/TpC-sfz-A#5-fp-N-T12d_R100u.wav", "/Volumes/CrucialX8/Musica/Samples/Libraries/Orchidea/Strings/Viola/non_vibrato/Va-nonvib-B5-mf-1c-N.wav", "/Volumes/CrucialX8/Musica/Samples/Libraries/Orchidea/Winds/Flute/ordinario_to_flatterzunge/Fl-ord_flatt-C6-mf-N-R200u.wav", "/Volumes/CrucialX8/Musica/Samples/Libraries/Orchidea/Winds/Oboe/ordinario/Ob-ord-C#6-pp-N-T10u.wav", "/Volumes/CrucialX8/Musica/Samples/Libraries/Orchidea/Strings/Viola/tremolo/Va-trem-D6-pp-2c-N.wav", "/Volumes/CrucialX8/Musica/Samples/Libraries/Orchidea/Strings/Violin/trill_major_second_up/Vn-trill_maj_second-D#6-mf-1c-N.wav", "/Volumes/CrucialX8/Musica/Samples/Libraries/Orchidea/Winds/Oboe/crescendo_to_decrescendo/Ob-cre_dec-E6-ppmfpp-N-R100u.wav", "/Volumes/CrucialX8/Musica/Samples/Libraries/Orchidea/Strings/Viola/non_vibrato/Va-nonvib-F6-ff-1c-N.wav", "/Volumes/CrucialX8/Musica/Samples/Libraries/Orchidea/Winds/Clarinet_Bb/crescendo_to_decrescendo/ClBb-cre_dec-G6-ppmfpp-N-R100u.wav", "/Volumes/CrucialX8/Musica/Samples/Libraries/Orchidea/Winds/Oboe/note_lasting/Ob-lasting_half_sec-G#6-mf-N-T10d.wav", "/Volumes/CrucialX8/Musica/Samples/Libraries/Orchidea/Winds/Clarinet_Bb/note_lasting/ClBb-lasting_half_sec-A#6-mf-N-T11d_R100d.wav", "/Volumes/CrucialX8/Musica/Samples/Libraries/Orchidea/Winds/Flute/ordinario_to_aeolian/Fl-ord_aeol-B6-mf-N-R100d.wav", "/Volumes/CrucialX8/Musica/Samples/Libraries/Orchidea/Winds/Flute/ordinario_to_aeolian/Fl-ord_aeol-B6-mf-N-R100d.wav", "/Volumes/CrucialX8/Musica/Samples/Libraries/Orchidea/Strings/Viola/artificial_harmonic_tremolo/Va-art_harm_trem-C#7-mf-2c-N.wav", "/Volumes/CrucialX8/Musica/Samples/Libraries/Orchidea/Keyboards/Accordion/ordinario/Acc-ord-D7-ff-alt1-N.wav", "/Volumes/CrucialX8/Musica/Samples/Libraries/Orchidea/Harp/ordinario/Hp-ord-F7-pp-N-N.wav", "/Volumes/CrucialX8/Musica/Samples/Libraries/Orchidea/Harp/ordinario/Hp-ord-F7-pp-N-N.wav", "/Volumes/CrucialX8/Musica/Samples/Libraries/Orchidea/Harp/ordinario/Hp-ord-G7-ff-N-T16d.wav", "/Volumes/CrucialX8/Musica/Samples/Libraries/Orchidea/Harp/ordinario/Hp-ord-G7-ff-N-T16d.wav", "/Volumes/CrucialX8/Musica/Samples/Libraries/Orchidea/Brass/bs/Bass_Tuba+sordina/ordinario/BTb+S-ord-C1-f-N-N.wav", "/Volumes/CrucialX8/Musica/Samples/Libraries/Orchidea/Brass/bs/Bass_Tuba+sordina/ordinario/BTb+S-ord-C1-f-N-N.wav", "/Volumes/CrucialX8/Musica/Samples/Libraries/Orchidea/Brass/bs/Bass_Tuba+sordina/ordinario/BTb+S-ord-C1-f-N-N.wav", "/Volumes/CrucialX8/Musica/Samples/Libraries/Orchidea/Brass/bs/Bass_Tuba+sordina/ordinario/BTb+S-ord-C1-f-N-N.wav", "/Volumes/CrucialX8/Musica/Samples/Libraries/Orchidea/Brass/bs/Bass_Tuba+sordina/ordinario/BTb+S-ord-C1-f-N-N.wav", "/Volumes/CrucialX8/Musica/Samples/Libraries/Orchidea/Brass/bs/Bass_Tuba+sordina/ordinario/BTb+S-ord-C1-f-N-N.wav", "/Volumes/CrucialX8/Musica/Samples/Libraries/Orchidea/Brass/bs/Bass_Tuba+sordina/ordinario/BTb+S-ord-C1-f-N-N.wav", "/Volumes/CrucialX8/Musica/Samples/Libraries/Orchidea/Brass/bs/Bass_Tuba+sordina/ordinario/BTb+S-ord-C1-f-N-N.wav", "/Volumes/CrucialX8/Musica/Samples/Libraries/Orchidea/Brass/bs/Bass_Tuba+sordina/ordinario/BTb+S-ord-C1-f-N-N.wav", "/Volumes/CrucialX8/Musica/Samples/Libraries/Orchidea/Brass/bs/Bass_Tuba+sordina/ordinario/BTb+S-ord-C1-f-N-N.wav", "/Volumes/CrucialX8/Musica/Samples/Libraries/Orchidea/Brass/bs/Bass_Tuba+sordina/ordinario/BTb+S-ord-C1-f-N-N.wav", "/Volumes/CrucialX8/Musica/Samples/Libraries/Orchidea/Brass/bs/Bass_Tuba+sordina/ordinario/BTb+S-ord-C1-f-N-N.wav", "/Volumes/CrucialX8/Musica/Samples/Libraries/Orchidea/Brass/bs/Bass_Tuba+sordina/ordinario/BTb+S-ord-C1-f-N-N.wav", "/Volumes/CrucialX8/Musica/Samples/Libraries/Orchidea/Brass/bs/Bass_Tuba+sordina/ordinario/BTb+S-ord-C1-f-N-N.wav", "/Volumes/CrucialX8/Musica/Samples/Libraries/Orchidea/Brass/bs/Bass_Tuba+sordina/ordinario/BTb+S-ord-C1-f-N-N.wav", "/Volumes/CrucialX8/Musica/Samples/Libraries/Orchidea/Brass/bs/Bass_Tuba+sordina/ordinario/BTb+S-ord-C1-f-N-N.wav", "/Volumes/CrucialX8/Musica/Samples/Libraries/Orchidea/Brass/bs/Bass_Tuba+sordina/ordinario/BTb+S-ord-C1-f-N-N.wav", "/Volumes/CrucialX8/Musica/Samples/Libraries/Orchidea/Strings/Contrabass/sforzato/Cb-sfz-E2-f-3c-N.wav", "/Volumes/CrucialX8/Musica/Samples/Libraries/Orchidea/Strings/Contrabass/pizzicato_l_vib/Cb-pizz_lv-B2-mf-2c-N.wav", "/Volumes/CrucialX8/Musica/Samples/Libraries/Orchidea/Strings/Viola/ordinario/Va-ord-E3-mf-4c-T19u.wav", "/Volumes/CrucialX8/Musica/Samples/Libraries/Orchidea/Strings/Violin/pizzicato_l_vib/Vn-pizz_lv-G#3-mf-4c-N.wav", "/Volumes/CrucialX8/Musica/Samples/Libraries/Orchidea/Strings/Contrabass/decrescendo/Cb-decr-B3-ffpp-1c-R100u.wav", "/Volumes/CrucialX8/Musica/Samples/Libraries/Orchidea/Brass/bs/Bass_Tuba/trill_major_second_up/BTb-trill_maj_second-D4-mf-N-N.wav", "/Volumes/CrucialX8/Musica/Samples/Libraries/Orchidea/Strings/Violin/ordinario/Vn-ord-E4-pp-4c-N.wav", "/Volumes/CrucialX8/Musica/Samples/Libraries/Orchidea/Strings/Violoncello/pizzicato_l_vib/Vc-pizz_lv-F#4-mf-1c-N.wav", "/Volumes/CrucialX8/Musica/Samples/Libraries/Orchidea/Winds/Bassoon/trill_major_second_up/Bn-trill_maj_second-G#4-mf-N-N.wav", "/Volumes/CrucialX8/Musica/Samples/Libraries/Orchidea/Winds/Flute/flatterzunge/Fl-flatt-A#4-mf-N-N.wav", "/Volumes/CrucialX8/Musica/Samples/Libraries/Orchidea/Strings/Viola/non_vibrato/Va-nonvib-B4-pp-1c-N.wav", "/Volumes/CrucialX8/Musica/Samples/Libraries/Orchidea/Strings/Violin/pizzicato_secco/Vn-pizz_sec-C#5-ff-3c-N.wav", "/Volumes/CrucialX8/Musica/Samples/Libraries/Orchidea/Strings/Violin+sordina/ordinario/Vn+S-ord-D5-mf-3c-N.wav", "/Volumes/CrucialX8/Musica/Samples/Libraries/Orchidea/Brass/Horn/flatterzunge_stopped/Hn-flatt_stopped-D#5-mf-N-N.wav", "/Volumes/CrucialX8/Musica/Samples/Libraries/Orchidea/Strings/Violin/crushed_to_ordinario/Vn-crush_ord-E5-mf-2c-N.wav", "/Volumes/CrucialX8/Musica/Samples/Libraries/Orchidea/Brass/Trumpet_C+sordina_cup/ordinario/TpC+SC-ord-F#5-mf-N-N.wav", "/Volumes/CrucialX8/Musica/Samples/Libraries/Orchidea/Brass/Trumpet_C/sforzato/TpC-sfz-A#5-fp-N-T12d_R100u.wav", "/Volumes/CrucialX8/Musica/Samples/Libraries/Orchidea/Strings/Viola/non_vibrato/Va-nonvib-B5-mf-1c-N.wav", "/Volumes/CrucialX8/Musica/Samples/Libraries/Orchidea/Winds/Flute/ordinario_to_flatterzunge/Fl-ord_flatt-C6-mf-N-R200u.wav", "/Volumes/CrucialX8/Musica/Samples/Libraries/Orchidea/Winds/Oboe/ordinario/Ob-ord-C#6-pp-N-T10u.wav", "/Volumes/CrucialX8/Musica/Samples/Libraries/Orchidea/Strings/Viola/tremolo/Va-trem-D6-pp-2c-N.wav", "/Volumes/CrucialX8/Musica/Samples/Libraries/Orchidea/Strings/Violin/trill_major_second_up/Vn-trill_maj_second-D#6-mf-1c-N.wav", "/Volumes/CrucialX8/Musica/Samples/Libraries/Orchidea/Winds/Oboe/crescendo_to_decrescendo/Ob-cre_dec-E6-ppmfpp-N-R100u.wav", "/Volumes/CrucialX8/Musica/Samples/Libraries/Orchidea/Strings/Viola/non_vibrato/Va-nonvib-F6-ff-1c-N.wav", "/Volumes/CrucialX8/Musica/Samples/Libraries/Orchidea/Winds/Clarinet_Bb/crescendo_to_decrescendo/ClBb-cre_dec-G6-ppmfpp-N-R100u.wav", "/Volumes/CrucialX8/Musica/Samples/Libraries/Orchidea/Winds/Oboe/note_lasting/Ob-lasting_half_sec-G#6-mf-N-T10d.wav", "/Volumes/CrucialX8/Musica/Samples/Libraries/Orchidea/Winds/Clarinet_Bb/note_lasting/ClBb-lasting_half_sec-A#6-mf-N-T11d_R100d.wav", "/Volumes/CrucialX8/Musica/Samples/Libraries/Orchidea/Winds/Flute/ordinario_to_aeolian/Fl-ord_aeol-B6-mf-N-R100d.wav", "/Volumes/CrucialX8/Musica/Samples/Libraries/Orchidea/Winds/Flute/ordinario_to_aeolian/Fl-ord_aeol-B6-mf-N-R100d.wav", "/Volumes/CrucialX8/Musica/Samples/Libraries/Orchidea/Strings/Viola/artificial_harmonic_tremolo/Va-art_harm_trem-C#7-mf-2c-N.wav", "/Volumes/CrucialX8/Musica/Samples/Libraries/Orchidea/Keyboards/Accordion/ordinario/Acc-ord-D7-ff-alt1-N.wav", "/Volumes/CrucialX8/Musica/Samples/Libraries/Orchidea/Harp/ordinario/Hp-ord-F7-pp-N-N.wav", "/Volumes/CrucialX8/Musica/Samples/Libraries/Orchidea/Harp/ordinario/Hp-ord-F7-pp-N-N.wav", "/Volumes/CrucialX8/Musica/Samples/Libraries/Orchidea/Harp/ordinario/Hp-ord-G7-ff-N-T16d.wav", "/Volumes/CrucialX8/Musica/Samples/Libraries/Orchidea/Harp/ordinario/Hp-ord-G7-ff-N-T16d.wav", "/Volumes/CrucialX8/Musica/Samples/Libraries/Orchidea/Brass/bs/Bass_Tuba+sordina/ordinario/BTb+S-ord-C1-f-N-N.wav", "/Volumes/CrucialX8/Musica/Samples/Libraries/Orchidea/Brass/bs/Bass_Tuba+sordina/ordinario/BTb+S-ord-C1-f-N-N.wav", "/Volumes/CrucialX8/Musica/Samples/Libraries/Orchidea/Brass/bs/Bass_Tuba+sordina/ordinario/BTb+S-ord-C1-f-N-N.wav", "/Volumes/CrucialX8/Musica/Samples/Libraries/Orchidea/Brass/bs/Bass_Tuba+sordina/ordinario/BTb+S-ord-C1-f-N-N.wav", "/Volumes/CrucialX8/Musica/Samples/Libraries/Orchidea/Brass/bs/Bass_Tuba+sordina/ordinario/BTb+S-ord-C1-f-N-N.wav", "/Volumes/CrucialX8/Musica/Samples/Libraries/Orchidea/Brass/bs/Bass_Tuba+sordina/ordinario/BTb+S-ord-C1-f-N-N.wav", "/Volumes/CrucialX8/Musica/Samples/Libraries/Orchidea/Brass/bs/Bass_Tuba+sordina/ordinario/BTb+S-ord-C1-f-N-N.wav", "/Volumes/CrucialX8/Musica/Samples/Libraries/Orchidea/Brass/bs/Bass_Tuba+sordina/ordinario/BTb+S-ord-C1-f-N-N.wav", "/Volumes/CrucialX8/Musica/Samples/Libraries/Orchidea/Brass/bs/Bass_Tuba+sordina/ordinario/BTb+S-ord-C1-f-N-N.wav", "/Volumes/CrucialX8/Musica/Samples/Libraries/Orchidea/Brass/bs/Bass_Tuba+sordina/ordinario/BTb+S-ord-C1-f-N-N.wav", "/Volumes/CrucialX8/Musica/Samples/Libraries/Orchidea/Brass/bs/Bass_Tuba+sordina/ordinario/BTb+S-ord-C1-f-N-N.wav", "/Volumes/CrucialX8/Musica/Samples/Libraries/Orchidea/Brass/bs/Bass_Tuba+sordina/ordinario/BTb+S-ord-C1-f-N-N.wav", "/Volumes/CrucialX8/Musica/Samples/Libraries/Orchidea/Brass/bs/Bass_Tuba+sordina/ordinario/BTb+S-ord-C1-f-N-N.wav", "/Volumes/CrucialX8/Musica/Samples/Libraries/Orchidea/Brass/bs/Bass_Tuba+sordina/ordinario/BTb+S-ord-C1-f-N-N.wav", "/Volumes/CrucialX8/Musica/Samples/Libraries/Orchidea/Brass/bs/Bass_Tuba+sordina/ordinario/BTb+S-ord-C1-f-N-N.wav", "/Volumes/CrucialX8/Musica/Samples/Libraries/Orchidea/Brass/bs/Bass_Tuba+sordina/ordinario/BTb+S-ord-C1-f-N-N.wav", "/Volumes/CrucialX8/Musica/Samples/Libraries/Orchidea/Brass/bs/Bass_Tuba+sordina/ordinario/BTb+S-ord-C1-f-N-N.wav", "/Volumes/CrucialX8/Musica/Samples/Libraries/Orchidea/Strings/Contrabass/sforzato/Cb-sfz-E2-f-3c-N.wav", "/Volumes/CrucialX8/Musica/Samples/Libraries/Orchidea/Strings/Contrabass/pizzicato_l_vib/Cb-pizz_lv-B2-mf-2c-N.wav", "/Volumes/CrucialX8/Musica/Samples/Libraries/Orchidea/Strings/Viola/ordinario/Va-ord-E3-mf-4c-T19u.wav", "/Volumes/CrucialX8/Musica/Samples/Libraries/Orchidea/Strings/Violin/pizzicato_l_vib/Vn-pizz_lv-G#3-mf-4c-N.wav", "/Volumes/CrucialX8/Musica/Samples/Libraries/Orchidea/Strings/Contrabass/decrescendo/Cb-decr-B3-ffpp-1c-R100u.wav", "/Volumes/CrucialX8/Musica/Samples/Libraries/Orchidea/Brass/bs/Bass_Tuba/trill_major_second_up/BTb-trill_maj_second-D4-mf-N-N.wav", "/Volumes/CrucialX8/Musica/Samples/Libraries/Orchidea/Strings/Violin/ordinario/Vn-ord-E4-pp-4c-N.wav", "/Volumes/CrucialX8/Musica/Samples/Libraries/Orchidea/Strings/Violoncello/pizzicato_l_vib/Vc-pizz_lv-F#4-mf-1c-N.wav", "/Volumes/CrucialX8/Musica/Samples/Libraries/Orchidea/Winds/Bassoon/trill_major_second_up/Bn-trill_maj_second-G#4-mf-N-N.wav", "/Volumes/CrucialX8/Musica/Samples/Libraries/Orchidea/Winds/Flute/flatterzunge/Fl-flatt-A#4-mf-N-N.wav", "/Volumes/CrucialX8/Musica/Samples/Libraries/Orchidea/Strings/Viola/non_vibrato/Va-nonvib-B4-pp-1c-N.wav", "/Volumes/CrucialX8/Musica/Samples/Libraries/Orchidea/Strings/Violin/pizzicato_secco/Vn-pizz_sec-C#5-ff-3c-N.wav", "/Volumes/CrucialX8/Musica/Samples/Libraries/Orchidea/Strings/Violin+sordina/ordinario/Vn+S-ord-D5-mf-3c-N.wav", "/Volumes/CrucialX8/Musica/Samples/Libraries/Orchidea/Brass/Horn/flatterzunge_stopped/Hn-flatt_stopped-D#5-mf-N-N.wav", "/Volumes/CrucialX8/Musica/Samples/Libraries/Orchidea/Strings/Violin/crushed_to_ordinario/Vn-crush_ord-E5-mf-2c-N.wav", "/Volumes/CrucialX8/Musica/Samples/Libraries/Orchidea/Brass/Trumpet_C+sordina_cup/ordinario/TpC+SC-ord-F#5-mf-N-N.wav", "/Volumes/CrucialX8/Musica/Samples/Libraries/Orchidea/Brass/Trumpet_C/sforzato/TpC-sfz-A#5-fp-N-T12d_R100u.wav", "/Volumes/CrucialX8/Musica/Samples/Libraries/Orchidea/Strings/Viola/non_vibrato/Va-nonvib-B5-mf-1c-N.wav", "/Volumes/CrucialX8/Musica/Samples/Libraries/Orchidea/Winds/Flute/ordinario_to_flatterzunge/Fl-ord_flatt-C6-mf-N-R200u.wav", "/Volumes/CrucialX8/Musica/Samples/Libraries/Orchidea/Winds/Oboe/ordinario/Ob-ord-C#6-pp-N-T10u.wav", "/Volumes/CrucialX8/Musica/Samples/Libraries/Orchidea/Strings/Viola/tremolo/Va-trem-D6-pp-2c-N.wav", "/Volumes/CrucialX8/Musica/Samples/Libraries/Orchidea/Strings/Violin/trill_major_second_up/Vn-trill_maj_second-D#6-mf-1c-N.wav", "/Volumes/CrucialX8/Musica/Samples/Libraries/Orchidea/Winds/Oboe/crescendo_to_decrescendo/Ob-cre_dec-E6-ppmfpp-N-R100u.wav", "/Volumes/CrucialX8/Musica/Samples/Libraries/Orchidea/Strings/Viola/non_vibrato/Va-nonvib-F6-ff-1c-N.wav", "/Volumes/CrucialX8/Musica/Samples/Libraries/Orchidea/Winds/Clarinet_Bb/crescendo_to_decrescendo/ClBb-cre_dec-G6-ppmfpp-N-R100u.wav", "/Volumes/CrucialX8/Musica/Samples/Libraries/Orchidea/Winds/Oboe/note_lasting/Ob-lasting_half_sec-G#6-mf-N-T10d.wav", "/Volumes/CrucialX8/Musica/Samples/Libraries/Orchidea/Winds/Clarinet_Bb/note_lasting/ClBb-lasting_half_sec-A#6-mf-N-T11d_R100d.wav", "/Volumes/CrucialX8/Musica/Samples/Libraries/Orchidea/Winds/Flute/ordinario_to_aeolian/Fl-ord_aeol-B6-mf-N-R100d.wav", "/Volumes/CrucialX8/Musica/Samples/Libraries/Orchidea/Winds/Flute/ordinario_to_aeolian/Fl-ord_aeol-B6-mf-N-R100d.wav", "/Volumes/CrucialX8/Musica/Samples/Libraries/Orchidea/Strings/Viola/artificial_harmonic_tremolo/Va-art_harm_trem-C#7-mf-2c-N.wav", "/Volumes/CrucialX8/Musica/Samples/Libraries/Orchidea/Keyboards/Accordion/ordinario/Acc-ord-D7-ff-alt1-N.wav", "/Volumes/CrucialX8/Musica/Samples/Libraries/Orchidea/Harp/ordinario/Hp-ord-F7-pp-N-N.wav", "/Volumes/CrucialX8/Musica/Samples/Libraries/Orchidea/Harp/ordinario/Hp-ord-F7-pp-N-N.wav", "/Volumes/CrucialX8/Musica/Samples/Libraries/Orchidea/Harp/ordinario/Hp-ord-G7-ff-N-T16d.wav", "/Volumes/CrucialX8/Musica/Samples/Libraries/Orchidea/Harp/ordinario/Hp-ord-G7-ff-N-T16d.wav", "/Volumes/CrucialX8/Musica/Samples/Libraries/Orchidea/Brass/bs/Bass_Tuba+sordina/ordinario/BTb+S-ord-C1-f-N-N.wav", "/Volumes/CrucialX8/Musica/Samples/Libraries/Orchidea/Brass/bs/Bass_Tuba+sordina/ordinario/BTb+S-ord-C1-f-N-N.wav", "/Volumes/CrucialX8/Musica/Samples/Libraries/Orchidea/Brass/bs/Bass_Tuba+sordina/ordinario/BTb+S-ord-C1-f-N-N.wav", "/Volumes/CrucialX8/Musica/Samples/Libraries/Orchidea/Brass/bs/Bass_Tuba+sordina/ordinario/BTb+S-ord-C1-f-N-N.wav", "/Volumes/CrucialX8/Musica/Samples/Libraries/Orchidea/Brass/bs/Bass_Tuba+sordina/ordinario/BTb+S-ord-C1-f-N-N.wav", "/Volumes/CrucialX8/Musica/Samples/Libraries/Orchidea/Brass/bs/Bass_Tuba+sordina/ordinario/BTb+S-ord-C1-f-N-N.wav", "/Volumes/CrucialX8/Musica/Samples/Libraries/Orchidea/Brass/bs/Bass_Tuba+sordina/ordinario/BTb+S-ord-C1-f-N-N.wav", "/Volumes/CrucialX8/Musica/Samples/Libraries/Orchidea/Brass/bs/Bass_Tuba+sordina/ordinario/BTb+S-ord-C1-f-N-N.wav", "/Volumes/CrucialX8/Musica/Samples/Libraries/Orchidea/Brass/bs/Bass_Tuba+sordina/ordinario/BTb+S-ord-C1-f-N-N.wav", "/Volumes/CrucialX8/Musica/Samples/Libraries/Orchidea/Brass/bs/Bass_Tuba+sordina/ordinario/BTb+S-ord-C1-f-N-N.wav", "/Volumes/CrucialX8/Musica/Samples/Libraries/Orchidea/Brass/bs/Bass_Tuba+sordina/ordinario/BTb+S-ord-C1-f-N-N.wav", "/Volumes/CrucialX8/Musica/Samples/Libraries/Orchidea/Brass/bs/Bass_Tuba+sordina/ordinario/BTb+S-ord-C1-f-N-N.wav", "/Volumes/CrucialX8/Musica/Samples/Libraries/Orchidea/Brass/bs/Bass_Tuba+sordina/ordinario/BTb+S-ord-C1-f-N-N.wav", "/Volumes/CrucialX8/Musica/Samples/Libraries/Orchidea/Brass/bs/Bass_Tuba+sordina/ordinario/BTb+S-ord-C1-f-N-N.wav", "/Volumes/CrucialX8/Musica/Samples/Libraries/Orchidea/Brass/bs/Bass_Tuba+sordina/ordinario/BTb+S-ord-C1-f-N-N.wav", "/Volumes/CrucialX8/Musica/Samples/Libraries/Orchidea/Brass/bs/Bass_Tuba+sordina/ordinario/BTb+S-ord-C1-f-N-N.wav", "/Volumes/CrucialX8/Musica/Samples/Libraries/Orchidea/Brass/bs/Bass_Tuba+sordina/ordinario/BTb+S-ord-C1-f-N-N.wav", "/Volumes/CrucialX8/Musica/Samples/Libraries/Orchidea/Strings/Contrabass/sforzato/Cb-sfz-E2-f-3c-N.wav", "/Volumes/CrucialX8/Musica/Samples/Libraries/Orchidea/Strings/Contrabass/pizzicato_l_vib/Cb-pizz_lv-B2-mf-2c-N.wav", "/Volumes/CrucialX8/Musica/Samples/Libraries/Orchidea/Strings/Viola/ordinario/Va-ord-E3-mf-4c-T19u.wav", "/Volumes/CrucialX8/Musica/Samples/Libraries/Orchidea/Strings/Violin/pizzicato_l_vib/Vn-pizz_lv-G#3-mf-4c-N.wav", "/Volumes/CrucialX8/Musica/Samples/Libraries/Orchidea/Strings/Contrabass/decrescendo/Cb-decr-B3-ffpp-1c-R100u.wav", "/Volumes/CrucialX8/Musica/Samples/Libraries/Orchidea/Brass/bs/Bass_Tuba/trill_major_second_up/BTb-trill_maj_second-D4-mf-N-N.wav", "/Volumes/CrucialX8/Musica/Samples/Libraries/Orchidea/Strings/Violin/ordinario/Vn-ord-E4-pp-4c-N.wav", "/Volumes/CrucialX8/Musica/Samples/Libraries/Orchidea/Strings/Violoncello/pizzicato_l_vib/Vc-pizz_lv-F#4-mf-1c-N.wav", "/Volumes/CrucialX8/Musica/Samples/Libraries/Orchidea/Winds/Bassoon/trill_major_second_up/Bn-trill_maj_second-G#4-mf-N-N.wav", "/Volumes/CrucialX8/Musica/Samples/Libraries/Orchidea/Winds/Flute/flatterzunge/Fl-flatt-A#4-mf-N-N.wav", "/Volumes/CrucialX8/Musica/Samples/Libraries/Orchidea/Strings/Viola/non_vibrato/Va-nonvib-B4-pp-1c-N.wav", "/Volumes/CrucialX8/Musica/Samples/Libraries/Orchidea/Strings/Violoncello/sul_ponticello_to_sul_tasto/Vc-pont_tasto-C5-mf-1c-N.wav", "/Volumes/CrucialX8/Musica/Samples/Libraries/Orchidea/Strings/Violin+sordina/ordinario/Vn+S-ord-D5-mf-3c-N.wav", "/Volumes/CrucialX8/Musica/Samples/Libraries/Orchidea/Brass/Horn/flatterzunge_stopped/Hn-flatt_stopped-D#5-mf-N-N.wav", "/Volumes/CrucialX8/Musica/Samples/Libraries/Orchidea/Strings/Violin/crushed_to_ordinario/Vn-crush_ord-E5-mf-2c-N.wav", "/Volumes/CrucialX8/Musica/Samples/Libraries/Orchidea/Brass/Trumpet_C+sordina_cup/ordinario/TpC+SC-ord-F#5-mf-N-N.wav", "/Volumes/CrucialX8/Musica/Samples/Libraries/Orchidea/Brass/Trumpet_C/sforzato/TpC-sfz-A#5-fp-N-T12d_R100u.wav", "/Volumes/CrucialX8/Musica/Samples/Libraries/Orchidea/Strings/Viola/non_vibrato/Va-nonvib-B5-mf-1c-N.wav", "/Volumes/CrucialX8/Musica/Samples/Libraries/Orchidea/Winds/Flute/ordinario_to_flatterzunge/Fl-ord_flatt-C6-mf-N-R200u.wav", "/Volumes/CrucialX8/Musica/Samples/Libraries/Orchidea/Winds/Oboe/ordinario/Ob-ord-C#6-pp-N-T10u.wav", "/Volumes/CrucialX8/Musica/Samples/Libraries/Orchidea/Strings/Viola/tremolo/Va-trem-D6-pp-2c-N.wav", "/Volumes/CrucialX8/Musica/Samples/Libraries/Orchidea/Strings/Violin/trill_major_second_up/Vn-trill_maj_second-D#6-mf-1c-N.wav", "/Volumes/CrucialX8/Musica/Samples/Libraries/Orchidea/Winds/Oboe/crescendo_to_decrescendo/Ob-cre_dec-E6-ppmfpp-N-R100u.wav", "/Volumes/CrucialX8/Musica/Samples/Libraries/Orchidea/Strings/Viola/non_vibrato/Va-nonvib-F6-ff-1c-N.wav", "/Volumes/CrucialX8/Musica/Samples/Libraries/Orchidea/Winds/Clarinet_Bb/crescendo_to_decrescendo/ClBb-cre_dec-G6-ppmfpp-N-R100u.wav", "/Volumes/CrucialX8/Musica/Samples/Libraries/Orchidea/Winds/Oboe/note_lasting/Ob-lasting_half_sec-G#6-mf-N-T10d.wav", "/Volumes/CrucialX8/Musica/Samples/Libraries/Orchidea/Winds/Clarinet_Bb/note_lasting/ClBb-lasting_half_sec-A#6-mf-N-T11d_R100d.wav", "/Volumes/CrucialX8/Musica/Samples/Libraries/Orchidea/Winds/Flute/ordinario_to_aeolian/Fl-ord_aeol-B6-mf-N-R100d.wav", "/Volumes/CrucialX8/Musica/Samples/Libraries/Orchidea/Winds/Flute/ordinario_to_aeolian/Fl-ord_aeol-B6-mf-N-R100d.wav", "/Volumes/CrucialX8/Musica/Samples/Libraries/Orchidea/Strings/Viola/artificial_harmonic_tremolo/Va-art_harm_trem-C#7-mf-2c-N.wav", "/Volumes/CrucialX8/Musica/Samples/Libraries/Orchidea/Keyboards/Accordion/ordinario/Acc-ord-D7-ff-alt1-N.wav", "/Volumes/CrucialX8/Musica/Samples/Libraries/Orchidea/Harp/ordinario/Hp-ord-F7-pp-N-N.wav", "/Volumes/CrucialX8/Musica/Samples/Libraries/Orchidea/Harp/ordinario/Hp-ord-F7-pp-N-N.wav", "/Volumes/CrucialX8/Musica/Samples/Libraries/Orchidea/Harp/ordinario/Hp-ord-G7-ff-N-T16d.wav", "/Volumes/CrucialX8/Musica/Samples/Libraries/Orchidea/Harp/ordinario/Hp-ord-G7-ff-N-T16d.wav", "/Volumes/CrucialX8/Musica/Samples/Libraries/Orchidea/Brass/bs/Bass_Tuba+sordina/ordinario/BTb+S-ord-C1-f-N-N.wav", "/Volumes/CrucialX8/Musica/Samples/Libraries/Orchidea/Brass/bs/Bass_Tuba+sordina/ordinario/BTb+S-ord-C1-f-N-N.wav", "/Volumes/CrucialX8/Musica/Samples/Libraries/Orchidea/Brass/bs/Bass_Tuba+sordina/ordinario/BTb+S-ord-C1-f-N-N.wav", "/Volumes/CrucialX8/Musica/Samples/Libraries/Orchidea/Brass/bs/Bass_Tuba+sordina/ordinario/BTb+S-ord-C1-f-N-N.wav", "/Volumes/CrucialX8/Musica/Samples/Libraries/Orchidea/Brass/bs/Bass_Tuba+sordina/ordinario/BTb+S-ord-C1-f-N-N.wav", "/Volumes/CrucialX8/Musica/Samples/Libraries/Orchidea/Brass/bs/Bass_Tuba+sordina/ordinario/BTb+S-ord-C1-f-N-N.wav", "/Volumes/CrucialX8/Musica/Samples/Libraries/Orchidea/Brass/bs/Bass_Tuba+sordina/ordinario/BTb+S-ord-C1-f-N-N.wav", "/Volumes/CrucialX8/Musica/Samples/Libraries/Orchidea/Brass/bs/Bass_Tuba+sordina/ordinario/BTb+S-ord-C1-f-N-N.wav", "/Volumes/CrucialX8/Musica/Samples/Libraries/Orchidea/Brass/bs/Bass_Tuba+sordina/ordinario/BTb+S-ord-C1-f-N-N.wav", "/Volumes/CrucialX8/Musica/Samples/Libraries/Orchidea/Brass/bs/Bass_Tuba+sordina/ordinario/BTb+S-ord-C1-f-N-N.wav", "/Volumes/CrucialX8/Musica/Samples/Libraries/Orchidea/Brass/bs/Bass_Tuba+sordina/ordinario/BTb+S-ord-C1-f-N-N.wav", "/Volumes/CrucialX8/Musica/Samples/Libraries/Orchidea/Brass/bs/Bass_Tuba+sordina/ordinario/BTb+S-ord-C1-f-N-N.wav", "/Volumes/CrucialX8/Musica/Samples/Libraries/Orchidea/Brass/bs/Bass_Tuba+sordina/ordinario/BTb+S-ord-C1-f-N-N.wav", "/Volumes/CrucialX8/Musica/Samples/Libraries/Orchidea/Brass/bs/Bass_Tuba+sordina/ordinario/BTb+S-ord-C1-f-N-N.wav", "/Volumes/CrucialX8/Musica/Samples/Libraries/Orchidea/Brass/bs/Bass_Tuba+sordina/ordinario/BTb+S-ord-C1-f-N-N.wav", "/Volumes/CrucialX8/Musica/Samples/Libraries/Orchidea/Brass/bs/Bass_Tuba+sordina/ordinario/BTb+S-ord-C1-f-N-N.wav", "/Volumes/CrucialX8/Musica/Samples/Libraries/Orchidea/Brass/bs/Bass_Tuba+sordina/ordinario/BTb+S-ord-C1-f-N-N.wav", "/Volumes/CrucialX8/Musica/Samples/Libraries/Orchidea/Strings/Contrabass/sforzato/Cb-sfz-E2-f-3c-N.wav", "/Volumes/CrucialX8/Musica/Samples/Libraries/Orchidea/Strings/Contrabass/pizzicato_l_vib/Cb-pizz_lv-B2-mf-2c-N.wav", "/Volumes/CrucialX8/Musica/Samples/Libraries/Orchidea/Strings/Viola/ordinario/Va-ord-E3-mf-4c-T19u.wav", "/Volumes/CrucialX8/Musica/Samples/Libraries/Orchidea/Strings/Violin/pizzicato_l_vib/Vn-pizz_lv-G#3-mf-4c-N.wav", "/Volumes/CrucialX8/Musica/Samples/Libraries/Orchidea/Strings/Contrabass/decrescendo/Cb-decr-B3-ffpp-1c-R100u.wav", "/Volumes/CrucialX8/Musica/Samples/Libraries/Orchidea/Brass/bs/Bass_Tuba/trill_major_second_up/BTb-trill_maj_second-D4-mf-N-N.wav", "/Volumes/CrucialX8/Musica/Samples/Libraries/Orchidea/Strings/Violin/ordinario/Vn-ord-E4-pp-4c-N.wav", "/Volumes/CrucialX8/Musica/Samples/Libraries/Orchidea/Strings/Violoncello/pizzicato_l_vib/Vc-pizz_lv-F#4-mf-1c-N.wav", "/Volumes/CrucialX8/Musica/Samples/Libraries/Orchidea/Winds/Bassoon/trill_major_second_up/Bn-trill_maj_second-G#4-mf-N-N.wav", "/Volumes/CrucialX8/Musica/Samples/Libraries/Orchidea/Winds/Flute/flatterzunge/Fl-flatt-A#4-mf-N-N.wav", "/Volumes/CrucialX8/Musica/Samples/Libraries/Orchidea/Strings/Viola/non_vibrato/Va-nonvib-B4-pp-1c-N.wav", "/Volumes/CrucialX8/Musica/Samples/Libraries/Orchidea/Strings/Violin/pizzicato_secco/Vn-pizz_sec-C#5-ff-3c-N.wav", "/Volumes/CrucialX8/Musica/Samples/Libraries/Orchidea/Strings/Violin+sordina/ordinario/Vn+S-ord-D5-mf-3c-N.wav", "/Volumes/CrucialX8/Musica/Samples/Libraries/Orchidea/Brass/Horn/flatterzunge_stopped/Hn-flatt_stopped-D#5-mf-N-N.wav", "/Volumes/CrucialX8/Musica/Samples/Libraries/Orchidea/Strings/Violin/crushed_to_ordinario/Vn-crush_ord-E5-mf-2c-N.wav", "/Volumes/CrucialX8/Musica/Samples/Libraries/Orchidea/Brass/Trumpet_C+sordina_cup/ordinario/TpC+SC-ord-F#5-mf-N-N.wav", "/Volumes/CrucialX8/Musica/Samples/Libraries/Orchidea/Brass/Trumpet_C/sforzato/TpC-sfz-A#5-fp-N-T12d_R100u.wav", "/Volumes/CrucialX8/Musica/Samples/Libraries/Orchidea/Strings/Viola/non_vibrato/Va-nonvib-B5-mf-1c-N.wav", "/Volumes/CrucialX8/Musica/Samples/Libraries/Orchidea/Winds/Flute/ordinario_to_flatterzunge/Fl-ord_flatt-C6-mf-N-R200u.wav", "/Volumes/CrucialX8/Musica/Samples/Libraries/Orchidea/Winds/Oboe/ordinario/Ob-ord-C#6-pp-N-T10u.wav", "/Volumes/CrucialX8/Musica/Samples/Libraries/Orchidea/Strings/Viola/tremolo/Va-trem-D6-pp-2c-N.wav", "/Volumes/CrucialX8/Musica/Samples/Libraries/Orchidea/Strings/Violin/trill_major_second_up/Vn-trill_maj_second-D#6-mf-1c-N.wav", "/Volumes/CrucialX8/Musica/Samples/Libraries/Orchidea/Winds/Oboe/crescendo_to_decrescendo/Ob-cre_dec-E6-ppmfpp-N-R100u.wav", "/Volumes/CrucialX8/Musica/Samples/Libraries/Orchidea/Strings/Viola/non_vibrato/Va-nonvib-F6-ff-1c-N.wav", "/Volumes/CrucialX8/Musica/Samples/Libraries/Orchidea/Winds/Clarinet_Bb/crescendo_to_decrescendo/ClBb-cre_dec-G6-ppmfpp-N-R100u.wav", "/Volumes/CrucialX8/Musica/Samples/Libraries/Orchidea/Winds/Oboe/note_lasting/Ob-lasting_half_sec-G#6-mf-N-T10d.wav", "/Volumes/CrucialX8/Musica/Samples/Libraries/Orchidea/Winds/Clarinet_Bb/note_lasting/ClBb-lasting_half_sec-A#6-mf-N-T11d_R100d.wav", "/Volumes/CrucialX8/Musica/Samples/Libraries/Orchidea/Winds/Flute/ordinario_to_aeolian/Fl-ord_aeol-B6-mf-N-R100d.wav", "/Volumes/CrucialX8/Musica/Samples/Libraries/Orchidea/Winds/Flute/ordinario_to_aeolian/Fl-ord_aeol-B6-mf-N-R100d.wav", "/Volumes/CrucialX8/Musica/Samples/Libraries/Orchidea/Strings/Viola/artificial_harmonic_tremolo/Va-art_harm_trem-C#7-mf-2c-N.wav", "/Volumes/CrucialX8/Musica/Samples/Libraries/Orchidea/Keyboards/Accordion/ordinario/Acc-ord-D7-ff-alt1-N.wav", "/Volumes/CrucialX8/Musica/Samples/Libraries/Orchidea/Harp/ordinario/Hp-ord-F7-pp-N-N.wav", "/Volumes/CrucialX8/Musica/Samples/Libraries/Orchidea/Harp/ordinario/Hp-ord-F7-pp-N-N.wav", "/Volumes/CrucialX8/Musica/Samples/Libraries/Orchidea/Harp/ordinario/Hp-ord-G7-ff-N-T16d.wav", "/Volumes/CrucialX8/Musica/Samples/Libraries/Orchidea/Harp/ordinario/Hp-ord-G7-ff-N-T16d.wav", "/Volumes/CrucialX8/Musica/Samples/Libraries/Orchidea/Brass/bs/Bass_Tuba+sordina/ordinario/BTb+S-ord-C1-f-N-N.wav", "/Volumes/CrucialX8/Musica/Samples/Libraries/Orchidea/Brass/bs/Bass_Tuba+sordina/ordinario/BTb+S-ord-C1-f-N-N.wav", "/Volumes/CrucialX8/Musica/Samples/Libraries/Orchidea/Brass/bs/Bass_Tuba+sordina/ordinario/BTb+S-ord-C1-f-N-N.wav", "/Volumes/CrucialX8/Musica/Samples/Libraries/Orchidea/Brass/bs/Bass_Tuba+sordina/ordinario/BTb+S-ord-C1-f-N-N.wav", "/Volumes/CrucialX8/Musica/Samples/Libraries/Orchidea/Brass/bs/Bass_Tuba+sordina/ordinario/BTb+S-ord-C1-f-N-N.wav", "/Volumes/CrucialX8/Musica/Samples/Libraries/Orchidea/Brass/bs/Bass_Tuba+sordina/ordinario/BTb+S-ord-C1-f-N-N.wav", "/Volumes/CrucialX8/Musica/Samples/Libraries/Orchidea/Brass/bs/Bass_Tuba+sordina/ordinario/BTb+S-ord-C1-f-N-N.wav", "/Volumes/CrucialX8/Musica/Samples/Libraries/Orchidea/Brass/bs/Bass_Tuba+sordina/ordinario/BTb+S-ord-C1-f-N-N.wav", "/Volumes/CrucialX8/Musica/Samples/Libraries/Orchidea/Brass/bs/Bass_Tuba+sordina/ordinario/BTb+S-ord-C1-f-N-N.wav", "/Volumes/CrucialX8/Musica/Samples/Libraries/Orchidea/Brass/bs/Bass_Tuba+sordina/ordinario/BTb+S-ord-C1-f-N-N.wav", "/Volumes/CrucialX8/Musica/Samples/Libraries/Orchidea/Brass/bs/Bass_Tuba+sordina/ordinario/BTb+S-ord-C1-f-N-N.wav", "/Volumes/CrucialX8/Musica/Samples/Libraries/Orchidea/Brass/bs/Bass_Tuba+sordina/ordinario/BTb+S-ord-C1-f-N-N.wav", "/Volumes/CrucialX8/Musica/Samples/Libraries/Orchidea/Brass/bs/Bass_Tuba+sordina/ordinario/BTb+S-ord-C1-f-N-N.wav", "/Volumes/CrucialX8/Musica/Samples/Libraries/Orchidea/Brass/bs/Bass_Tuba+sordina/ordinario/BTb+S-ord-C1-f-N-N.wav", "/Volumes/CrucialX8/Musica/Samples/Libraries/Orchidea/Brass/bs/Bass_Tuba+sordina/ordinario/BTb+S-ord-C1-f-N-N.wav", "/Volumes/CrucialX8/Musica/Samples/Libraries/Orchidea/Brass/bs/Bass_Tuba+sordina/ordinario/BTb+S-ord-C1-f-N-N.wav", "/Volumes/CrucialX8/Musica/Samples/Libraries/Orchidea/Brass/bs/Bass_Tuba+sordina/ordinario/BTb+S-ord-C1-f-N-N.wav", "/Volumes/CrucialX8/Musica/Samples/Libraries/Orchidea/Strings/Contrabass/tremolo/Cb-trem-B1-mf-3c-N.wav", "/Volumes/CrucialX8/Musica/Samples/Libraries/Orchidea/Brass/Horn/flatterzunge/Hn-flatt-G#2-mf-N-N.wav", "/Volumes/CrucialX8/Musica/Samples/Libraries/Orchidea/Brass/Trombone+sordina_cup/ordinario/Tbn+SC-ord-D3-mf-N-N.wav", "/Volumes/CrucialX8/Musica/Samples/Libraries/Orchidea/Brass/bs/Bass_Tuba/crescendo_to_decrescendo/BTb-cre_dec-F#3-ppmfpp-N-N.wav", "/Volumes/CrucialX8/Musica/Samples/Libraries/Orchidea/Strings/Contrabass/ordinario/Cb-ord-A#3-ff-2c-N.wav", "/Volumes/CrucialX8/Musica/Samples/Libraries/Orchidea/Brass/Trombone+sordina_straight/ordinario/Tbn+SS-ord-C#4-mf-N-T10u.wav", "/Volumes/CrucialX8/Musica/Samples/Libraries/Orchidea/Winds/Bassoon/crescendo_to_decrescendo/Bn-cre_dec-D#4-ppmfpp-N-R100u.wav", "/Volumes/CrucialX8/Musica/Samples/Libraries/Orchidea/Brass/Trumpet_C/note_lasting/TpC-lasting_half_sec-F4-mf-N-T14u.wav", "/Volumes/CrucialX8/Musica/Samples/Libraries/Orchidea/Brass/Trumpet_C+sordina_cup/ordinario/TpC+SC-ord-G4-mf-N-N.wav", "/Volumes/CrucialX8/Musica/Samples/Libraries/Orchidea/Strings/Violin/ordinario_to_tremolo/Vn-ord_trem-A4-mf-3c-R100u.wav", "/Volumes/CrucialX8/Musica/Samples/Libraries/Orchidea/Winds/Flute/flatterzunge/Fl-flatt-A#4-mf-N-N.wav", "/Volumes/CrucialX8/Musica/Samples/Libraries/Orchidea/Strings/Violoncello/sul_ponticello_to_sul_tasto/Vc-pont_tasto-C5-mf-1c-N.wav", "/Volumes/CrucialX8/Musica/Samples/Libraries/Orchidea/Strings/Violin+sordina/ordinario/Vn+S-ord-D5-mf-3c-N.wav", "/Volumes/CrucialX8/Musica/Samples/Libraries/Orchidea/Brass/Horn/flatterzunge_stopped/Hn-flatt_stopped-D#5-mf-N-N.wav", "/Volumes/CrucialX8/Musica/Samples/Libraries/Orchidea/Brass/Horn/flatterzunge_stopped/Hn-flatt_stopped-D#5-mf-N-N.wav", "/Volumes/CrucialX8/Musica/Samples/Libraries/Orchidea/Strings/Violin/non_vibrato/Vn-nonvib-F5-mf-3c-N.wav", "/Volumes/CrucialX8/Musica/Samples/Libraries/Orchidea/Brass/Trumpet_C/sforzato/TpC-sfz-A#5-fp-N-T12d_R100u.wav", "/Volumes/CrucialX8/Musica/Samples/Libraries/Orchidea/Strings/Viola/non_vibrato/Va-nonvib-B5-mf-1c-N.wav", "/Volumes/CrucialX8/Musica/Samples/Libraries/Orchidea/Winds/Flute/ordinario_to_flatterzunge/Fl-ord_flatt-C6-mf-N-R200u.wav", "/Volumes/CrucialX8/Musica/Samples/Libraries/Orchidea/Winds/Oboe/ordinario/Ob-ord-C#6-pp-N-T10u.wav", "/Volumes/CrucialX8/Musica/Samples/Libraries/Orchidea/Strings/Viola/tremolo/Va-trem-D6-pp-2c-N.wav", "/Volumes/CrucialX8/Musica/Samples/Libraries/Orchidea/Strings/Violin/trill_major_second_up/Vn-trill_maj_second-D#6-mf-1c-N.wav", "/Volumes/CrucialX8/Musica/Samples/Libraries/Orchidea/Winds/Oboe/crescendo_to_decrescendo/Ob-cre_dec-E6-ppmfpp-N-R100u.wav", "/Volumes/CrucialX8/Musica/Samples/Libraries/Orchidea/Strings/Viola/non_vibrato/Va-nonvib-F6-ff-1c-N.wav", "/Volumes/CrucialX8/Musica/Samples/Libraries/Orchidea/Winds/Clarinet_Bb/crescendo_to_decrescendo/ClBb-cre_dec-G6-ppmfpp-N-R100u.wav", "/Volumes/CrucialX8/Musica/Samples/Libraries/Orchidea/Winds/Oboe/note_lasting/Ob-lasting_half_sec-G#6-mf-N-T10d.wav", "/Volumes/CrucialX8/Musica/Samples/Libraries/Orchidea/Winds/Clarinet_Bb/note_lasting/ClBb-lasting_half_sec-A#6-mf-N-T11d_R100d.wav", "/Volumes/CrucialX8/Musica/Samples/Libraries/Orchidea/Winds/Flute/ordinario_to_aeolian/Fl-ord_aeol-B6-mf-N-R100d.wav", "/Volumes/CrucialX8/Musica/Samples/Libraries/Orchidea/Winds/Flute/ordinario_to_aeolian/Fl-ord_aeol-B6-mf-N-R100d.wav", "/Volumes/CrucialX8/Musica/Samples/Libraries/Orchidea/Strings/Viola/artificial_harmonic_tremolo/Va-art_harm_trem-C#7-mf-2c-N.wav", "/Volumes/CrucialX8/Musica/Samples/Libraries/Orchidea/Keyboards/Accordion/ordinario/Acc-ord-D7-ff-alt1-N.wav", "/Volumes/CrucialX8/Musica/Samples/Libraries/Orchidea/Harp/ordinario/Hp-ord-F7-pp-N-N.wav", "/Volumes/CrucialX8/Musica/Samples/Libraries/Orchidea/Harp/ordinario/Hp-ord-F7-pp-N-N.wav", "/Volumes/CrucialX8/Musica/Samples/Libraries/Orchidea/Harp/ordinario/Hp-ord-G7-ff-N-T16d.wav", "/Volumes/CrucialX8/Musica/Samples/Libraries/Orchidea/Harp/ordinario/Hp-ord-G7-ff-N-T16d.wav", "/Volumes/CrucialX8/Musica/Samples/Libraries/Orchidea/Harp/ordinario/Hp-ord-G7-ff-N-T16d.wav", "/Volumes/CrucialX8/Musica/Samples/Libraries/Orchidea/Brass/bs/Bass_Tuba+sordina/ordinario/BTb+S-ord-C1-f-N-N.wav", "/Volumes/CrucialX8/Musica/Samples/Libraries/Orchidea/Brass/bs/Bass_Tuba+sordina/ordinario/BTb+S-ord-C1-f-N-N.wav", "/Volumes/CrucialX8/Musica/Samples/Libraries/Orchidea/Brass/bs/Bass_Tuba+sordina/ordinario/BTb+S-ord-C1-f-N-N.wav", "/Volumes/CrucialX8/Musica/Samples/Libraries/Orchidea/Brass/bs/Bass_Tuba+sordina/ordinario/BTb+S-ord-C1-f-N-N.wav", "/Volumes/CrucialX8/Musica/Samples/Libraries/Orchidea/Brass/bs/Bass_Tuba+sordina/ordinario/BTb+S-ord-C1-f-N-N.wav", "/Volumes/CrucialX8/Musica/Samples/Libraries/Orchidea/Brass/bs/Bass_Tuba+sordina/ordinario/BTb+S-ord-C1-f-N-N.wav", "/Volumes/CrucialX8/Musica/Samples/Libraries/Orchidea/Brass/bs/Bass_Tuba+sordina/ordinario/BTb+S-ord-C1-f-N-N.wav", "/Volumes/CrucialX8/Musica/Samples/Libraries/Orchidea/Brass/bs/Bass_Tuba+sordina/ordinario/BTb+S-ord-C1-f-N-N.wav", "/Volumes/CrucialX8/Musica/Samples/Libraries/Orchidea/Brass/bs/Bass_Tuba+sordina/ordinario/BTb+S-ord-C1-f-N-N.wav", "/Volumes/CrucialX8/Musica/Samples/Libraries/Orchidea/Brass/bs/Bass_Tuba+sordina/ordinario/BTb+S-ord-C1-f-N-N.wav", "/Volumes/CrucialX8/Musica/Samples/Libraries/Orchidea/Brass/bs/Bass_Tuba+sordina/ordinario/BTb+S-ord-C1-f-N-N.wav", "/Volumes/CrucialX8/Musica/Samples/Libraries/Orchidea/Brass/bs/Bass_Tuba+sordina/ordinario/BTb+S-ord-C1-f-N-N.wav", "/Volumes/CrucialX8/Musica/Samples/Libraries/Orchidea/Brass/bs/Bass_Tuba+sordina/ordinario/BTb+S-ord-C1-f-N-N.wav", "/Volumes/CrucialX8/Musica/Samples/Libraries/Orchidea/Brass/bs/Bass_Tuba+sordina/ordinario/BTb+S-ord-C1-f-N-N.wav", "/Volumes/CrucialX8/Musica/Samples/Libraries/Orchidea/Brass/bs/Bass_Tuba+sordina/ordinario/BTb+S-ord-C1-f-N-N.wav", "/Volumes/CrucialX8/Musica/Samples/Libraries/Orchidea/Brass/bs/Bass_Tuba+sordina/ordinario/BTb+S-ord-C1-f-N-N.wav" ]
)