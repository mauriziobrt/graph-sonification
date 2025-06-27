//================================================================================================================================================
// BUBBLES
//================================================================================================================================================
//4 blocchi con opposizione tempo/pitch pairwise - ciascuno di circa 20 nodi con diverse connessioni

//ciascuno diviso in 3 parti, uno con tante connnessioni uno con medie e uno conpoche, diciamo ai partecipanti di cliccare quello di colore x che decidiamo a priori

(
a = Scale.major;
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
(
OSCdef(\bubbleControl, {|msg, time, addr, recvPort|
	var bell1 = [ 3958.2691669464, 2219.5205450058, 3720.8760738373, 3930.4407596588, 827.31196880341, 3670.5682277679, 550.56445598602, 3677.7821779251, 581.56654834747, 3224.8901605606, 2330.4237604141, 756.98308944702 ];
	var bell2 = [ 223.22008609772, 1996.9875097275, 3631.1988592148, 753.74145507812, 659.04550552368, 953.89244556427, 612.56682872772, 426.58507823944, 1644.7909116745, 875.82595348358, 1946.9505548477, 3229.9587249756 ];
	var bell3 = [ 3901.8504142761, 3278.7544727325, 3938.3745193481, 1065.1204586029, 3879.1404008865, 3816.3529872894, 2989.7552490234, 1730.3744077682, 678.00426483154, 2374.1246700287, 2525.9301900864, 3549.2574453354 ];
	var bell4 = [ 2657.4152469635, 912.29071617126, 1286.7574691772, 3869.4250106812, 1136.3956451416, 2689.750957489, 459.87751483917, 2751.2355566025, 3400.4847288132, 1524.5981216431, 2834.7212314606, 2828.8508653641 ];
	var bell5 = [ 1328.7076234818, 456.14535808563, 643.3787345886, 1934.7125053406, 568.1978225708, 1344.8754787445, 229.93875741958, 1375.6177783012, 1700.2423644066, 762.29906082155, 1417.3606157303, 1414.4254326821 ];
	Synth("help-KlankOverlapTexture", [
		\atk, 0,
		\sus, 0,
		\rel, 4,
		\pan, 1.0.rand2,
		\amp, (msg[3].linlin(0,200,-10,0).dbamp),
		\freqs, [bell1, bell2, bell3, bell4, bell5].choose,
		\rings, {0.1.rrand(msg[3]/10.0)}.dup(12),
		\rel, (msg[4].linlin(0,60,100,1300)/50)
        ]);
}, '/bubbles');
);

//================================================================================================================================================
// TRANSITION
//================================================================================================================================================
// 4 blocchi con opposizione timbro/pitch pairwise - ciascuno di circa 20 nodi con diverse connessioni
(

l = 0;
OSCdef(\transitionControl, {|msg, time, addr, recvPort|
	switch (msg[6],
		0, { \no }, //1. Nodo grande → Low pitch - Nodo piccolo → High pitch - ? Envelope ?
		1, { \wrong }, //2. Nodo piccolo → Low pitch - Nodo grande → High pitch - ? Envelope ?
		2, { \wrong }, //3. Nodo grande → Sweep Low-High pitch - Nodo piccolo → Sweep High-Low pitch - ? Envelope ?
		3, { \wrong }, //4 Nodo piccolo → Sweep High-Low pitch - Nodo grande → Sweep Low-High pitch - ? Envelope ?
	var my_time = msg[5] /1000;
	if( l == 0,
		{l = my_time; Ndef(\resControlled).fadeTime_(l/4); "Start".postln},
		{}
	);
	"TIME:".postln;
	(msg[5]/1000).postln;
	a = Scale.major;
	(
		Ndef(\resControlled, {
			var fund = ((msg[3] + 1).linlin(0,850,100, 800));
			var sig = DynKlank.ar(`[Array.series(msg[4]+1, fund,fund * a.ratios[4]), nil, [1, 1, 1, 1]], PinkNoise.ar([0.007, 0.007]));
			sig = sig * SinOsc.ar([msg[3].linlin(0,860,0.0, 0.02), msg[3].linlin(0,860,0.0, 0.03)]).abs;
			sig = sig;
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
//================================================================================================================================================
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
//================================================================================================================================================

//1. Nodo grande → Low pitch - Nodo piccolo → High pitch - ? Envelope ?
//2. Nodo piccolo → Low pitch - Nodo grande → High pitch - ? Envelope ?
//3. Nodo grande → Sweep Low-High pitch - Nodo piccolo → Sweep High-Low pitch - ? Envelope ?
//4. Nodo piccolo → Sweep High-Low pitch - Nodo grande → Sweep Low-High pitch - ? Envelope ?
(
(
OSCdef(\hoverControl, {|msg, time, addr, recvPort|
	switch (msg[6],
		0, { \no }, //1. Nodo grande → Low pitch - Nodo piccolo → High pitch - ? Envelope ?
		1, { \wrong }, //2. Nodo piccolo → Low pitch - Nodo grande → High pitch - ? Envelope ?
		2, { \wrong }, //3. Nodo grande → Sweep Low-High pitch - Nodo piccolo → Sweep High-Low pitch - ? Envelope ?
		3, { \wrong }, //4 Nodo piccolo → Sweep High-Low pitch - Nodo grande → Sweep Low-High pitch - ? Envelope ?
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
			Out.ar(out, Pan2.ar(sig * 0))// stereo output
		}).play;
	);
}, '/control');
)
)
)
)
)

//================================================================================================================================================
// Experiments
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

//================================================================================================================================================
// Spatialization
//================================================================================================================================================

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

(
~bell5 = [ 1328.7076234818, 456.14535808563, 643.3787345886, 1934.7125053406, 568.1978225708, 1344.8754787445, 229.93875741958, 1375.6177783012, 1700.2423644066, 762.29906082155, 1417.3606157303, 1414.4254326821 ]/3;
~bell6 = [ 1328.7076234818, 456.14535808563, 643.3787345886, 1934.7125053406, 568.1978225708, 1344.8754787445, 229.93875741958, 1375.6177783012, 1700.2423644066, 762.29906082155, 1417.3606157303, 1414.4254326821 ]*10;
Synth("help-KlankOverlapTexture", [
		\atk, 0,
		\sus, 0,
		\rel, 4,
		\pan, 1.0.rand2,
		\amp, (-8.dbamp),
		\freqs, [~bell6, ~bell5].choose,
		\rings, {0.1.rrand(250/10.0)}.dup(12),
		\rel, (60.linlin(0,60,100,5000)/300)
		// \filterfreq, msg[4].linlin(0,55, 60, 20000)
        ]);
)

(
SynthDef(\miaoControlled, {|out, fund= 80|
	// Sweep da basso a alto e da alto a basso
	var freq = XLine.kr(100, 2, 1);
	// var freq = myfreq;
	var env = Env.new(levels: [0, 1, 0.4, 0], times: [0.1, 0.2, freq/100], curve: [-5, 0, -5]);
	var arraySeries = `[Array.series(20, freq, 2 * freq * a.ratios[2]), nil, [1, 1, 1, 1]];
	var sig = DynKlank.ar(arraySeries, PinkNoise.ar([0.007, 0.007])) * 0.3;
	sig = sig +
	(sig * Pulse.ar(Rand(1,20),mul:0.1) * Saw.ar(0.5)) * 0.2 +
	SinOsc.ar([freq, freq*a.ratios[3]], mul: 0.2);
	sig = sig * EnvGen.ar(env, doneAction: Done.freeSelf)*0.5+ FreeVerb.ar(sig,1, mul: 0.1);
	Out.ar(out, Pan2.ar(sig * 0.5))// stereo output
}).play;
)

MIDIOut.newByName("RemoteSL IN","Port 1");
MIDIClient.init()
m = MIDIOut(0);

//4 blocchi con opposizione tempo/pitch pairwise - ciascuno di circa 20 nodi con diverse connessioni

//ciascuno diviso in 3 parti, uno con tante connnessioni uno con medie e uno conpoche, diciamo ai partecipanti di cliccare quello di colore x che decidiamo a priori
// Devo avere n campane diverse, ognuna con caratteristiche fisiche differenti, oppure uso un modello fisico e bom
	var bell1 = [ 3958.2691669464, 2219.5205450058, 3720.8760738373, 3930.4407596588, 827.31196880341, 3670.5682277679, 550.56445598602, 3677.7821779251, 581.56654834747, 3224.8901605606, 2330.4237604141, 756.98308944702 ];
	var bell2 = [ 223.22008609772, 1996.9875097275, 3631.1988592148, 753.74145507812, 659.04550552368, 953.89244556427, 612.56682872772, 426.58507823944, 1644.7909116745, 875.82595348358, 1946.9505548477, 3229.9587249756 ];
	var bell3 = [ 3901.8504142761, 3278.7544727325, 3938.3745193481, 1065.1204586029, 3879.1404008865, 3816.3529872894, 2989.7552490234, 1730.3744077682, 678.00426483154, 2374.1246700287, 2525.9301900864, 3549.2574453354 ];
	var bell4 = [ 2657.4152469635, 912.29071617126, 1286.7574691772, 3869.4250106812, 1136.3956451416, 2689.750957489, 459.87751483917, 2751.2355566025, 3400.4847288132, 1524.5981216431, 2834.7212314606, 2828.8508653641 ];
	var bell5 = [ 1328.7076234818, 456.14535808563, 643.3787345886, 1934.7125053406, 568.1978225708, 1344.8754787445, 229.93875741958, 1375.6177783012, 1700.2423644066, 762.29906082155, 1417.3606157303, 1414.4254326821 ];


// choose randomly one of the bells, divide them by a number according to their quantitative features

(
var bell1 = [ 3958.2691669464, 2219.5205450058, 3720.8760738373, 3930.4407596588, 827.31196880341, 3670.5682277679, 	550.56445598602, 3677.7821779251, 581.56654834747, 3224.8901605606, 2330.4237604141, 756.98308944702 ];

SynthDef("help-KlankOverlapTexture",
	{|out = 0, amp = 1, freqs = #[0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0], rings = #[0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0], atk = 0, sus = 0, rel = 5, pan = 0, filterfreq=440|
		var e = EnvGen.kr(Env.linen(atk, sus, rel, 1, -50), doneAction: Done.freeSelf);
		// var i = Decay.ar(Impulse.ar(Rand(0.8, 2.2)), 0.0, ClipNoise.ar(0.01));
		var z = Klank.ar(
			`[bell1, nil, {0.1.rrand(100)}.dup(12)],     // specs
			ClipNoise.ar(0.01) * e                    // input
		);

		Out.ar(out, Pan2.ar(LPF.ar(z*e*amp, filterfreq), pan));
}).play;
)


//================================================================================================================================================
// UPDATED HOVERING
//================================================================================================================================================
(
(
a = Scale.major;
OSCdef(\hoverControl, {|msg, time, addr, recvPort|
	var cit, coupling, myfreq, panPos, cluster;
	cit = msg[3];
	coupling = msg[4];
	cluster = msg[9];
	// msg.postln;
	(
		SynthDef(\hoverControlled, {|out, fund= 80|
			var freq, env, arraySeries, sig, arrayCit, volumeCit;

			arrayCit = cit.linlin(0, 1000, 1, 100);
			volumeCit = cit.linlin(0,200,-5,0).dbamp.postln;
			switch (msg[9],
				1, {//1. Nodo grande → Low pitch - Nodo piccolo → High pitch - ? Envelope ?
					freq = (msg[4]).linexp(0, 60, 1300, 50);
					env = Env.new(levels: [0, 1, 0.4, 0], times: [0.1, 0.2, freq/1000], curve: [-5, 0, -5]);
				},
				2, { //2. Nodo piccolo → Low pitch - Nodo grande → High pitch - ? Envelope ?
					freq = (msg[4]).linlin(0, 60, 50, 1300);
					env = Env.new(levels: [0, 1, 0.4, 0], times: [0.1, 0.2, freq/100], curve: [-5, 0, -5]);
				},
				3, {//3. Nodo grande → Sweep Low-High pitch - Nodo piccolo → Sweep High-Low pitch - ? Envelope ?
					freq = (msg[4]).linexp(0, 60, 1300, 50);
					freq = XLine.ar(freq, freq/10, arrayCit);
					env = Env.new(levels: [0, 1, 0.4, 0], times: [0.1, 0.2, freq/100], curve: [-5, 0, -5]);
				},
				4, {//4 Nodo piccolo → Sweep High-Low pitch - Nodo grande → Sweep Low-High pitch - ? Envelope ?
					freq = (msg[4]).linlin(0, 60, 50, 1300);
					freq = XLine.ar(freq, freq*10, arrayCit);
					env = Env.new(levels: [0, 1, 0.4, 0], times: [0.1, 0.2, freq/100], curve: [-5, 0, -5]);
				},
			);
			arraySeries = `[Array.series(arrayCit, freq, 2 * freq * a.ratios[2]), nil, [1, 1, 1, 1]];
			sig = DynKlank.ar(arraySeries, PinkNoise.ar([0.007, 0.007])) * 0.3;

			sig = sig +
			(sig * Pulse.ar(Rand(1,20),mul:0.1) * Saw.ar(0.5)) * 0.2 +
			SinOsc.ar([freq, freq*a.ratios[3]], mul: 0.2)  + FreeVerb.ar(sig, 1,1, mul: 0.5);
			sig = volumeCit * sig * EnvGen.ar(env, doneAction: Done.freeSelf);
			Out.ar(out, Pan2.ar(sig * 0.2))// stereo output
		}).play;
	);
}, '/control');
);

//================================================================================================================================================
// UPDATED BUBBLES
//================================================================================================================================================


(
a = Scale.major;
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
(
OSCdef(\bubbleControl, {|msg, time, addr, recvPort|
	var bell1, bell2, bell3, bell4, bell5, freq, rel, maxlength;
	maxlength = 20;
	bell1 = [ 3958.2691669464, 2219.5205450058, 3720.8760738373, 3930.4407596588, 827.31196880341, 3670.5682277679, 550.56445598602, 3677.7821779251, 581.56654834747, 3224.8901605606, 2330.4237604141, 756.98308944702 ];
	bell2 = [ 223.22008609772, 1996.9875097275, 3631.1988592148, 753.74145507812, 659.04550552368, 953.89244556427, 612.56682872772, 426.58507823944, 1644.7909116745, 875.82595348358, 1946.9505548477, 3229.9587249756 ];
	bell3 = [ 3901.8504142761, 3278.7544727325, 3938.3745193481, 1065.1204586029, 3879.1404008865, 3816.3529872894, 2989.7552490234, 1730.3744077682, 678.00426483154, 2374.1246700287, 2525.9301900864, 3549.2574453354 ];
	bell4 = [ 2657.4152469635, 912.29071617126, 1286.7574691772, 3869.4250106812, 1136.3956451416, 2689.750957489, 459.87751483917, 2751.2355566025, 3400.4847288132, 1524.5981216431, 2834.7212314606, 2828.8508653641 ];
	bell5 = [ 1328.7076234818, 456.14535808563, 643.3787345886, 1934.7125053406, 568.1978225708, 1344.8754787445, 229.93875741958, 1375.6177783012, 1700.2423644066, 762.29906082155, 1417.3606157303, 1414.4254326821 ];
	msg[9].postln;
	switch (msg[9],
		1, {//1. Nodo grande → Low pitch + Long sound - Nodo piccolo → High pitch + Short Sound
			freq = ([bell1, bell2, bell3, bell4, bell5].choose)/msg[4].linlin(0,60,0.5,5);
			rel = (msg[4].linlin(0,60,0,maxlength)).postln;
		},
		2, { //2. Nodo grande → High pitch + Long sound - Nodo piccolo → Low pitch + Short Sound
			freq = ([bell1, bell2, bell3, bell4, bell5].choose)/msg[4].linlin(0,60,5,0.5);
			rel = (msg[4].linlin(0,60,maxlength,0));
		},
		3, {//3. Nodo grande → Low pitch + Short sound - Nodo piccolo → Low pitch + Long Sound
			freq = ([bell1, bell2, bell3, bell4, bell5].choose)/msg[4].linlin(0,60,0.5,5);
			rel = (msg[4].linlin(0,60,0,maxlength));
		},
		4, {//4. Nodo grande → High pitch + Short sound - Nodo piccolo → Low pitch + Long Sound
			freq = ([bell1, bell2, bell3, bell4, bell5].choose)/msg[4].linlin(0,60,0.5,5);
			rel = (msg[4].linlin(0,60,maxlength,0));
		},
	);
	Synth("help-KlankOverlapTexture", [
		\atk, 0,
		\sus, 0,
		\rel, 4,
		\pan, 1.0.rand2,
		\amp, (msg[3].linlin(0,200,-10,-5).dbamp),
		\freqs, freq,
		\rings, {0.1.rrand(msg[3]/10.0)}.dup(12),
		\rel, rel
        ]);
}, '/bubbles');
);
);

//================================================================================================================================================
// UPDATED TRANSITION
//================================================================================================================================================
// 4 blocchi con opposizione timbro/pitch pairwise - ciascuno di circa 20 nodi con diverse connessioni
)
(
l = 0;
OSCdef(\transitionControl, {|msg, time, addr, recvPort|
	var cit, coupling, cluster, freq, my_time, nr_resonators, max_degree, max_cit;
	msg.postln;
	a = Scale.minor;
	cit = msg[3];
	coupling = msg[4];
	cluster = msg[9];
	max_degree = msg[10].postln;
	max_cit = msg[11].postln;
	my_time = msg[5] /1000.postln;
	if( l == 0,
		{l = my_time; Ndef(\resControlled).fadeTime_(l/4); "Start".postln},
		{}
	);
	"TIME:".postln;
	(msg[5]/1000).postln;
	(
		switch (cluster,
			1, { //1. Big node → Low pitch → Bright - Small node → High pitch → Dark
				freq = ((coupling + 1).linlin(0,max_degree,100, 800));
				nr_resonators = cit.linlin(0,max_cit,1, 50) + 1; //inverti con il valore massimo di cit/co-cit
			},
			2, { //2. Big node → High pitch → Dark - Small node → Low pitch → Bright
				freq = ((coupling + 1).linlin(0,max_degree,800, 100));
				nr_resonators = cit.linlin(0,max_cit,1, 50) + 1;
			},
			3, { //3. Big node → High pitch → Bright - Small node → High pitch → Dark
				freq = ((coupling + 1).linlin(0,max_degree,100, 800));
				nr_resonators = (max_cit - cit).linlin(0,max_cit,1, 50) + 1;
			},
			4, { //4 Big node → Low pitch → Dark - Small node → Low pitch → Bright
				freq = ((coupling + 1).linlin(0,max_degree,800, 100));
				nr_resonators = (max_cit - cit).linlin(0,max_cit,1, 50) + 1;
			},
		);
		Ndef(\resControlled, {
			var sig;
			sig = DynKlank.ar(`[Array.series(nr_resonators + 1, freq, freq * a.ratios[4]), nil, [1, 1, 1, 1]], PinkNoise.ar([0.007, 0.007]));
			sig = sig * SinOsc.ar([cit.linlin(0,860,0.0, 0.02), cit.linlin(0,860,0.0, 0.03)]).abs;
			sig = sig;
		});
	);
	if ( msg[1] == 0,
		{Ndef.clear(20); l = 0; "END".postln;},    // true function
		{Ndef(\resControlled).play; Ndef(\resControlled).fadeTime_(l/2);l = my_time;"Continue".postln}    // false function
	);
}, '/additive');
)