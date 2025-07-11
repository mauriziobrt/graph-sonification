//================================================================================================================================================
// GRAPH SONIFICATION
//================================================================================================================================================

( // Installs the SafetyNet Quark.

Quarks.fetchDirectory(true); Quarks.install("SafetyNet");
thisProcess.recompile;

)

//================================================================================================================================================
// HOVERING
//================================================================================================================================================
(
~upperResonatorLimit = 10000;
(
a = Scale.major;
OSCdef(\hoverControl, {|msg, time, addr, recvPort|
	var cit, coupling, myfreq, panPos, cluster, max_coupling, max_cit;
	cit = msg[3];
	coupling = msg[4];
	cluster = msg[9];
	max_coupling = msg[10];
	max_cit = msg[11];
	msg.postln;
	(
		SynthDef(\hoverControlled, {|out, fund= 80|
			var freq, env, arraySeries, sig, nr_resonators, volumeCit;

			nr_resonators = cit.linlin(0, max_cit, 1, 50);
			volumeCit = cit.linlin(0,max_cit,-5,0).dbamp.postln;
			switch (cluster,
				2, {//2. Nodo grande → Low pitch - Nodo piccolo → High pitch - ? Envelope ?
					freq = coupling.linexp(0, max_coupling, 1300, 50);
					env = Env.new(levels: [0, 1, 0.4, 0], times: [0.1, 0.2, freq/100], curve: [-5, 0, -5]);
				},
				1, { //1. Nodo piccolo → Low pitch - Nodo grande → High pitch - ? Envelope ?
					freq = coupling.linlin(0, max_coupling, 50, 1300);
					env = Env.new(levels: [0, 1, 0.4, 0], times: [0.1, 0.2, freq/100], curve: [-5, 0, -5]);
				},
				3, {//3. Nodo grande → Sweep Low-High pitch - Nodo piccolo → Sweep High-Low pitch - ? Envelope ?
					freq = coupling.linexp(0, max_coupling, 1300, 50);
					freq = XLine.ar(freq, freq/10, 0.1);
					env = Env.new(levels: [0, 1, 0.4, 0], times: [0.1, 0.2, freq/100], curve: [-5, 0, -5]);
				},
				4, {//4 Nodo piccolo → Sweep High-Low pitch - Nodo grande → Sweep Low-High pitch - ? Envelope ?
					freq = coupling.linlin(0, max_coupling, 50, 1300);
					freq = XLine.ar(freq, freq*10, 0.1);
					env = Env.new(levels: [0, 1, 0.4, 0], times: [0.1, 0.2, freq/100], curve: [-5, 0, -5]);
				},
			);
			arraySeries = Array.series(nr_resonators, freq, 2 * freq * a.ratios[2]);
			arraySeries = `[arraySeries.linlin(arraySeries[0], arraySeries[arraySeries.lastIndex], arraySeries[0], ~upperResonatorLimit), nil, [1, 1, 1, 1]].postln;
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
// WASD
//================================================================================================================================================
(
(
OSCdef(\wasdControl, {|msg, time, addr, recvPort|
	var cit, coupling, freq, max_coupling, max_cit, nr_resonators;
	cit = msg[3];
	coupling = msg[4];
	max_coupling = msg[10];
	max_cit = msg[11];
	nr_resonators = cit.linlin(0, max_cit, 1, 100);
	freq = coupling.linlin(0, max_coupling, 50, 1300);
	(
		SynthDef(\miaoControlled, {|out, fund= 80|
			var env, arraySeries, sig;
			env = Env.new(levels: [0, 1, 0.4, 0], times: [0.1, 0.2, freq/100], curve: [-5, 0, -5]);
			arraySeries = Array.series(nr_resonators, freq, 2 * freq * a.ratios[2]);
			arraySeries = `[arraySeries.linlin(arraySeries[0], arraySeries[arraySeries.lastIndex], arraySeries[0], 15000), nil, [1, 1, 1, 1]].postln;
			sig = DynKlank.ar(arraySeries, PinkNoise.ar([0.007, 0.007])) * 0.3;
			sig = sig + (sig * Pulse.ar(Rand(1,20),mul:0.1) * Saw.ar(0.5)) * 0.2 + SinOsc.ar([freq, freq*a.ratios[3]], mul: 0.2);
			sig = sig * EnvGen.ar(env, doneAction: Done.freeSelf)*0.5;
			Out.ar(out, Pan2.ar(sig * 0.2))// stereo output
		}).play;
	);
}, '/wasd');
)
);

//================================================================================================================================================
// BUBBLES
//================================================================================================================================================

(
a = Scale.major;
(
SynthDef("help-KlankOverlapTexture",
	{|out = 0, amp = 1, freqs = #[0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0], rings = #[0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0], atk = 5, sus = 8, rel = 5, pan = 0, filterfreq=440|
		var env, sig;
		env = EnvGen.kr(Env.linen(atk, sus, rel, 1, -50), doneAction: Done.freeSelf);
		// var i = Decay.ar(Impulse.ar(Rand(0.8, 2.2)), 0.0, ClipNoise.ar(0.01));
		sig = Klank.ar(
			`[freqs, nil, rings],     // specs
			ClipNoise.ar(0.01) * env                    // input
		);
		sig = FreeVerb.ar(sig, 0.2, 10, 1, mul: 0.7);
		Out.ar(out, Pan2.ar(LPF.ar(sig*env*amp, filterfreq), pan));
}).add;
);
(
OSCdef(\bubbleControl, {|msg, time, addr, recvPort|
	var bell1, bell2, bell3, bell4, bell5, freq, rel, maxlength, cit, coupling, max_coupling,max_cit, cluster;
	cit = msg[3];
	coupling = msg[4];
	max_coupling = msg[10];
	max_cit = msg[11];
	maxlength = 20;
	cluster = msg[9];
	bell1 = [ 3958.2691669464, 2219.5205450058, 3720.8760738373, 3930.4407596588, 827.31196880341, 3670.5682277679, 550.56445598602, 3677.7821779251, 581.56654834747, 3224.8901605606, 2330.4237604141, 756.98308944702 ];
	bell2 = [ 223.22008609772, 1996.9875097275, 3631.1988592148, 753.74145507812, 659.04550552368, 953.89244556427, 612.56682872772, 426.58507823944, 1644.7909116745, 875.82595348358, 1946.9505548477, 3229.9587249756 ];
	bell3 = [ 3901.8504142761, 3278.7544727325, 3938.3745193481, 1065.1204586029, 3879.1404008865, 3816.3529872894, 2989.7552490234, 1730.3744077682, 678.00426483154, 2374.1246700287, 2525.9301900864, 3549.2574453354 ];
	bell4 = [ 2657.4152469635, 912.29071617126, 1286.7574691772, 3869.4250106812, 1136.3956451416, 2689.750957489, 459.87751483917, 2751.2355566025, 3400.4847288132, 1524.5981216431, 2834.7212314606, 2828.8508653641 ];
	bell5 = [ 1328.7076234818, 456.14535808563, 643.3787345886, 1934.7125053406, 568.1978225708, 1344.8754787445, 229.93875741958, 1375.6177783012, 1700.2423644066, 762.29906082155, 1417.3606157303, 1414.4254326821 ];
	cluster.postln;
	switch (cluster,
		1, {//1. Nodo grande → Low pitch + Long sound - Nodo piccolo → High pitch + Short Sound
			freq = ([bell1, bell2, bell3, bell4, bell5].choose)/coupling.linlin(0,max_coupling,0.5,5);
			rel = (coupling.linlin(0,max_coupling,0,maxlength)).postln;
		},
		2, { //2. Nodo grande → High pitch + Long sound - Nodo piccolo → Low pitch + Short Sound
			freq = ([bell1, bell2, bell3, bell4, bell5].choose)/coupling.linlin(0,max_coupling,5,0.5);
			rel = (coupling.linlin(0,max_coupling,maxlength,0));
		},
		3, {//3. Nodo grande → Low pitch + Short sound - Nodo piccolo → Low pitch + Long Sound
			freq = ([bell1, bell2, bell3, bell4, bell5].choose)/coupling.linlin(0,max_coupling,0.5,5);
			rel = (coupling.linlin(0,max_coupling,0,maxlength));
		},
		4, {//4. Nodo grande → High pitch + Short sound - Nodo piccolo → Low pitch + Long Sound
			freq = ([bell1, bell2, bell3, bell4, bell5].choose)/coupling.linlin(0,max_coupling,0.5,5);
			rel = (coupling.linlin(0,max_coupling,maxlength,0));
		},
	);
	Synth("help-KlankOverlapTexture", [
		\atk, 0,
		\sus, 0,
		\rel, 4,
		\pan, 1.0.rand2,
		\amp, (cit.linlin(0,max_cit,-12,-7).dbamp),
		\freqs, freq,
		\rings, {0.1.rrand(cit/10.0)}.dup(12),
		\rel, rel
        ]);
}, '/bubbles');
);
);

//================================================================================================================================================
// TRANSITION
//================================================================================================================================================
(
l = 0;
OSCdef(\transitionControl, {|msg, time, addr, recvPort|
	var cit, coupling, cluster, freq, my_time, nr_resonators, max_coupling, max_cit;
	cit = msg[3];
	coupling = msg[4];
	cluster = msg[9];
	max_coupling = msg[10];
	max_cit = msg[11];
	my_time = msg[5] /1000;
	if( l == 0,
		{l = my_time; Ndef(\resControlled).fadeTime_(l/4); "Start".postln},
		{}
	);
	"TIME:".postln;
	(my_time).postln;
	(
		switch (cluster,
			1, { //1. Big node → High pitch - Small node → Low pitch | Cit: Dark > Bright
				freq = ((coupling + 1).linlin(0,max_coupling,800, 100));
				nr_resonators = cit.linlin(0,max_cit,1, 50) + 1;
			},
			2, { //2. Big node → Low pitch  - Small node → High pitch | Cit:  Bright > Dark
				freq = ((coupling + 1).linlin(0,max_coupling,100, 800));
				nr_resonators = cit.linlin(0,max_cit,50, 1) + 1; //inverti con il valore massimo di cit/co-cit
			},
			3, { //3. Big node → High pitch - Small node → High pitch | Cit: Dark > Bright
				freq = ((coupling + 1).linlin(0,max_coupling,100, 800));
				nr_resonators = (max_cit - cit).linlin(0,max_cit,1, 50) + 1;
			},
			4, { //4 Big node → Low pitch  - Small node → Low pitch | Cit: Bright > Dark
				freq = ((coupling + 1).linlin(0,max_coupling,800, 100));
				nr_resonators = (max_cit - cit).linlin(0,max_cit,50, 1) + 1;
			},
		);
		Ndef(\resControlled, {
			var sig, arraySeries;
			arraySeries = Array.series(nr_resonators, freq, 2 * freq * a.ratios[2]);
			arraySeries = `[arraySeries.linlin(arraySeries[0], arraySeries[arraySeries.lastIndex], arraySeries[0], 15000), nil, [1, 1, 1, 1]].postln;
			sig = DynKlank.ar(arraySeries, PinkNoise.ar([0.007, 0.007]));
			sig = sig * SinOsc.ar([cit.linlin(0 ,max_cit,0.001, 0.02), cit.linlin(0,max_cit,0.001, 0.03)]).abs;
			sig = sig * 0.2;
			sig
		});
	);
	if ( msg[1] == 0,
		{Ndef.clear(20); l = 0; "END".postln;},    // true function
		{Ndef(\resControlled).play; Ndef(\resControlled).fadeTime_(l);l = my_time;"Continue".postln}    // false function
	);
}, '/additive');
)
)