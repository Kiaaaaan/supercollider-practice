//boot the server
s.boot;//or Server.local.boot;

//quit the server
s.quit;

s;//the server

//you can do this:
a = {SinOsc.ar}.play;
a.free;

//but you can't do this, it won't stop, you can't free a function:
a = {SinOsc.ar}
a.play;
a.free;

//a way to solve this:

a = {SinOsc.ar}
b = a.play;
b.free;

//arg
(
a = {
	arg freq = 440, amp = 1;//also |freq = 440, amp = 1|
	var sig;
	sig = {SinOsc.ar(freq) * amp}.dup;
}.play;
)

a.set(\freq, 250, \amp, 0.2);
a.free;

// .range
(
a = {
	SinOsc.ar(
		LFNoise0.kr(10).range(200, 1000)
	)*0.125
}.play
)
a.free;

//Blip
----------------------------------------------
p = ProxySpace.push;

~out = { \in.ar(0!2) };
~out.play;

~blip = {
	arg freq = 440, numharm = 0;
	Blip.ar(freq,numharm)*0.125.dup
};

~blip <>> ~out;

~numharm = {Blip.kr(0.1,Pulse.kr(1).range(0, 40)).range(0, 8)};
~freq = {Blip.kr(0.1,Saw.kr(1).range(1, 90)).range(440, 550)};
~blip.set(\numharm, ~numharm);
~blip.set(\freq, ~freq);

~out.stop;
p.clear;
----------------------------------------------
{ Blip.ar(200,Line.kr(1,100,20),0.2) }.scope

c = { Blip.ar(Blip.kr(4, 5, 500, 60), 59, 0.1) }.play;
c.free;


//SynthDef

(
z = {
	arg noiseHz = 8;
	var freq, amp, sig;
	freq = LFNoise0.kr(noiseHz).exprange(200, 2000);
	amp = LFNoise1.kr(12).exprange(0.02, 0.7);
	sig = SinOsc.ar(freq) * 0.7.dup;
}.play;
)//without SynthDef

z.free;

---------------------------------------------
//now use SynthDef

(
SynthDef.new(\sinTest, {
	arg noiseHz = 8, fund = 200;
	var freq, amp, numharm, sig;
	freq = LFNoise0.kr(noiseHz).exprange(fund, 1000).round(fund);
	amp = LFNoise1.kr(12).exprange(0.02, 0.7);
	numharm = LFNoise0.kr(noiseHz).range(0, 6);
	sig = Blip.ar(freq, numharm) * amp;
	Out.ar(0, sig);
}).add//or .load, .send, .store
)

x = Synth.new(\sinTest);

x = Synth.new(\sinTest, [\noiseHz, 32]);

x.set(\noiseHz, 10);
x.set(\fund, 100);

x.free;

----pulseTest----

(
SynthDef.new(\pulseTest, {
	arg ampHz = 4, fund = 40, maxPartial = 4, width = 0.5;
	var amp1, amp2, freq1, freq2, sig1, sig2;
	amp1 = LFPulse.kr(ampHz, 0, 0.12) * 0.75;
	amp2 = LFPulse.kr(ampHz, 0.5, 0.12) * 0.75;
	freq1 = LFNoise0.kr(4).exprange(fund, fund*maxPartial).round(fund);
	freq2 = LFNoise0.kr(4).exprange(fund, fund*maxPartial).round(fund);
	freq1 = freq1 * LFPulse.kr(8, add:1);
	freq2 = freq2 * LFPulse.kr(6, add:1);
	sig1 = Pulse.ar(freq1, width, amp1);
	sig2 = Pulse.ar(freq2, width, amp2);
	sig1 = FreeVerb.ar(sig1, 0.7, 0.8, 0.25);
	sig2 = FreeVerb.ar(sig2, 0.7, 0.8, 0.25);
	//sig1 = RLPF.ar(sig1, MouseX.kr(50, 4000), MouseY.kr (0.01, 0.9));
	//sig2 = RLPF.ar(sig2, MouseX.kr(50, 4000), MouseY.kr (0.01, 0.9));
	Out.ar(0, sig1);
	Out.ar(1, sig2);
}).add;
)


y = Synth.new(\pulseTest);

y.set(\ampHz, 2.2);
y.set(\width, 0.25);
y.set(\fund, 65);
y.set(\maxPartial, 20);
y.set(\asd, 6);
y.free;

y = Synth.new(\pulseTest, [\ampJz, 2.2, \width, 0.3, \fund, 50, \maxPartial, 10]);

y.free;

s.quit;
------------------------------------------
//doneAction
s.boot;

x = {arg amp = 0.75; PinkNoise.ar * amp}.play;
x.set(\amp, SinOsc);
x.free;


s.boot;
s.quit;



a = {SinOsc.ar((LFNoise0.kr(4).exprange(400, 40*3).round(50))
	* (LFPulse.kr(8, add:1.5)), mul:0.5).dup}.play;

a = {Blip.ar((LFNoise0.kr(4).exprange(400, 40*3).round(50))
	* (LFPulse.kr(8, add:1.5)), LFPulse.kr(8).range(1, 5), 0.5).dup}.play;



{ Ringz.ar(PinkNoise.ar([0.1, 0.2]).scope(\pink), 2000, 1, 0.25) }.play; // multichannel works
s







s.quit;
s.boot;

(
b = Buffer.alloc(s,512,1,{|z|z.sine1Msg(1.0/[1,3,5,7,9,11,13,15,17])});
c = Buffer.read(s, "/pathtothesample");

fork{
    s.sync;
~sound = {
    var sig;
    var local;
    var f = [30,60,15]*Lag.kr(TChoose.kr(Impulse.kr(0.05),[0.75, 0.5, 1]), 8);
    sig = Mix(COsc.ar(b.bufnum,f + SinOsc.ar(f*25, 0, LFTri.kr(0.01).range(0, 10)), [0.1, 0.1001, 0.2], 0.2))*0.1;
sig = sig;
sig = LeakDC.ar(Ringz.ar(sig, TChoose.kr(Impulse.kr(0.1),[88, 97, 99, 100].midicps), LFTri.kr([0.05, 0.051]).range(0.2, 0.5)));
sig = sig + Decimator.ar(sig, 48000*LFNoise0.kr(1).range(0.25, 1), TChoose.kr(Impulse.kr(4), [8, 12, 16, 24]), 0.4);
    sig = LPF.ar(sig, 3000*LFTri.kr(0.01).range(0.1, 1));
    sig = sig + (Splay.ar(Array.fill(4, {PlayBuf.ar(2, c, rrand(-0.8, 0.8), loop: 2)*0.01}), 0.5));
    sig = CombC.ar(sig, 1.0, [0.1, 0.2], LFTri.kr(0.05).range(5, 9));

    local = sig + LocalIn.ar(2);
    15.do({
            local = AllpassN.ar(local, 0.06, Rand(0.001, 0.06), 3)
          });
    LocalOut.ar(local*0.4);

    Out.ar(0, Limiter.ar(LPF.ar(local, 4000), 0.8)*EnvGen.kr(Env([0, 1, 1, 0],[3, 100, 10])));
}.play;
}
)

s.quit;