settings = { --@enable make this local if its in a ROBLOX port
    ai_model = 'new civilian',
    step = 1/3,--0.468126878/2
    --the reason i use step value instead of 1/fps is because while in LOVE2D, the framerate can vary from 400-100 as long as vsync is off, ROBLOX has fps limit of 60
    --this limit means thatb if the FPS drops, then it may end up offsetting the 
    
    term_time= 11.4540217, -- also peak time
    critical_activation = 0.01,
    lock_time = 300,
    perm_lock_chance=1,

    
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
        substance_p= -1.2, -- pain. yes it is the real scientific name for a neurotransmitter released when you feel pain
        nitrous_oxide = -0.5, -- should be -2 but for demo its 0.5
        action_p=1,
        fire=1,

        nitrous_oxide_epinephrine = -1, -- neutralises the epinephrine. is 1/2 of n2o as there would be 2x as much neurotransmitter so it remains same strengt3h
        nitrous_oxide_dopamine = -1,

        epinephrine_dopamine = 1,
        epinephrine_cortisol = -1,
        epinephrine_substance_p = -0.2,

        substance_p_action_p = -1
    },

    neurotransmitter_combination = {
        {'nitrous_oxide','epinephrine'},
        {'nitrous_oxide','dopamine'},

        --main use of epinephrine is to enhance other neurotransmitters. this means if all other neurotransmitters were removed and there was a 'pure epinephrine' f or f event then itd not do too much

        {'epinephrine','cortisol'},
        {'epinephrine','substance_p'},
        {'epinephrine','dopamine'},
        {'substance_p','action_p'}
    },
    
    colours = {
        input_neuron = {200,200,200},
        soft_mem_neuron={253,0,138},
        hidden_neuron= {0,29,158},
        output_neuron= {253,138,0},
    }
}