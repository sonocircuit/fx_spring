FxSpring : FxBase {

    *new { 
        var ret = super.newCopyArgs(nil, \none, (
            room: 0.5,
            damp: 0.5,
        ), nil, 0.5);
        ^ret;
    }

    *initClass {
        FxSetup.register(this.new);
    }

    subPath {
        ^"/fx_spring";
    }  

    symbol {
        ^\fxSpring;
    }

    addSynthdefs {
        // passersby's spring approximation by mark eats
        // adapted and slightly modified for fx mod @sonocircuit
        SynthDef(\fxSpring, {|inBus, outBus|
            var dry, preProcess, springReso, wet, max_predelay = 1;
            dry = In.ar(inBus, 2);
            preProcess = BHiShelf.ar(in: dry, freq: 1000, rs: 1, db: -6, mul: 1.5, add: 0).tanh;
            preProcess = DelayN.ar(in: preProcess, maxdelaytime: max_predelay, delaytime: \predelay.kr(0.015));
            springReso = Limiter.ar(Klank.ar(specificationsArrayRef: `[[508, 270, 1153], [0.15, 0.25, 0.1], [1, 1.2, 1.4]], input: preProcess));
            preProcess = preProcess * -6.dbamp;
            wet = tanh(FreeVerb2.ar(in: preProcess[0], in2: preProcess[1], mix: 1, room: \room.kr(0.7), damp: \damp.kr(0.35), mul: 6.dbamp));
            wet = (wet * 0.93) + (springReso * 0.07);
            Out.ar(outBus, wet);
        }).add;

    }

}
