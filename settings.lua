settings = { --@enable make this local if its in a ROBLOX port
    ai_model = 'new police',
    step = .5,--0.468126878/2
    scale=1, -- 1 pixel = 1 ms? approx
    --the rason i use step value instead of 1/fps is because while in LOVE2D, the framerate can vary from 400-100 as long as vsync is off, ROBLOX has fps limit of 60
    --this limit means thatb if the FPS drops, then it may end up offsetting the snn stuff

    critical_activation = 0.01,
    lock_time = 300,
    perm_lock_chance=0,

    
    membrane_leak_multiplier=1.5,
     -- integrate this ^
    hyperpolarisation_value = -2, -- the value of neuron membrane once action potential has been fired

	instance_key = {
		h='hidden_neuron',
		i='input_neuron',
		o='output_neuron',
		s='soft_mem_neuron',
	},

    synthesis = {
        o='nitrous_oxide',

        d='dopamine',  -- happywappyness
        c='cortisol', -- fear/stress
        p='substance_p', -- pain
        e='epinephrine', -- adrenaline
        [' ']='action_p', -- action potential
    },

    increment = {
        ['['] = -0.1,
        [']'] = 0.1,
    },

    fire_neuron = {
        f=7,
    },

    neurotransmitter_membrane_offset = {
        dopamine= 0.8,-- should be exhibitory and inhibitory,
        epinephrine= 0.5,  -- adrenaline
        cortisol= - -0.4,
        substance_p= 1, -- pain. yes it is the real scientific name for a neurotransmitter released when you feel pain
        nitrous_oxide = -2, -- laughing gas
        action_p=1,
        fire=1,

        nitrous_oxide_epinephrine = -1, -- neutralises the epinephrine. is 1/2 of n2o as there would be 2x as much neurotransmitter so it remains same strengt3h
        nitrous_oxide_dopamine = -1,
		nitrous_oxide_substance_p=0, -- neutralises SUBSTANCE P. man this shit is powerful

        epinephrine_dopamine = 1,
        epinephrine_cortisol = -1,
        epinephrine_substance_p = -0.2,

        substance_p_action_p = -1
    },

    colours = {
        input_neuron = {87,87,87},
        soft_mem_neuron={253,0,138},
        hidden_neuron= {0,9,138},
        output_neuron= {253,138,0},

        dopamine= {9,0,138},
        cortisol = {138,138,9},
        epinephrine = {238,9,138}, -- change ph to p
        substance_p = {138,0,9},
        action_p = {0,138,0},
        nitrous_oxide={138,9,238},

        selected1 = {2,140,131},
        selected2 = {138,138,138}
    },

    neurotransmitter_combination = {
        {'nitrous_oxide','epinephrine'},
        {'nitrous_oxide','dopamine'},
		{'nitrous_oxide','substance_p'},

        --main use of epinephrine is to enhance other neurotransmitters. this means if all other neurotransmitters were removed and there was a 'pure epinephrine' f or f event then itd not do too much

        {'epinephrine','cortisol'},
        {'epinephrine','substance_p'},
        {'epinephrine','dopamine'},
        {'substance_p','action_p'}
    },
    
    colours = {
        input_neuron = {87,87,87},
        soft_mem_neuron={253,0,138},
        hidden_neuron= {0,9,138},
        output_neuron= {253,138,0},

        dopamine= {9,0,138},
        cortisol = {138,138,9},
        epinephrine = {238,9,138}, -- change ph to p
        substance_p = {138,0,9},
        action_p = {0,138,0},
        nitrous_oxide={138,9,238},

        selected1 = {2,140,131},
        selected2 = {138,138,138}
    },
    graph_pixel_size = 15
}

for _,comb in pairs(settings.neurotransmitter_combination) do
    local full = comb[1]..'_'..comb[2]
    local c1,c2 = settings.colours[comb[1]],settings.colours[comb[2]]
    settings.colours[full]={(c1[1]+c1[1])/2,(c1[2]+c1[2])/2,(c1[3]+c1[3])/2}
    
end