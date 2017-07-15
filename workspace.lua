graph = {}
neurograph = {}

nn_workspace={networks={},loaded={},input={},output={},exeptions={},default_input={bias=7}} -- but i dont mean networking

--default_parent

function nn_workspace:load(ai_model,name,is_default)
    if is_default then
        default_parent = name
    end
    
    nn_workspace.input[name]= nn_workspace.input[name] or {}
    nn_workspace.output[name]= nn_workspace.output[name] or {}
    nn_workspace.exeptions[name]=nn_workspace.exeptions[name] or {} -- potentially causes issues when overriding data
    

    --@enable this if you're using the SNN in roblox and disable the line after it v
    --nn_workspace.networks[name] = require(game.ReplicatedStorage.ai_models[settings.ai_model])
    
    --[
    if love.filesystem.exists('workspace_'..ai_model..'.lua') then
        nn_workspace.networks[name]= love.filesystem.load('workspace_'..ai_model..'.lua')()
    else
        nn_workspace.networks[name] = {}
    end
    --]]

    for i,v in pairs(nn_workspace.networks[name]) do -- disgostin i know
        if type(v) == 'table' then
            --@enable this in ROBLOX v
            --v.position = Vector2.new(v.position.x,v.position.y)
            v.parent = nn_workspace.networks[name]
            function v:destroy()
                local object = v
                object.real = false
                nn_workspace[object.name] = nil
                local meta = getmetatable(object) or {}
                meta.__mode = 'v'
                for i,_ in pairs(object) do
                    object[i] = nil
                end
                setmetatable(object, meta)
            end
        end
    end

    nn_workspace.networks[name].name = name
    local update= function()
        local printable = {}
        for i,v in pairs(nn_workspace:getchildren(name)) do
            printable[v] = nn_workspace:get_activation(v)
            -- just do nn_workspace:get_activation(v) if you dont wanna do table/visualisation stuff
        end
        return printable
    end
    nn_workspace.loaded[name] = update
    return update
end

nn_workspace:load(settings.ai_model,settings.ai_model,true)

function love.keypressed(key)
    if key =='=' then
		graph={}
        nn_workspace:load(settings.ai_model,settings.ai_model,true)
    end
end

gametime = 0


--[(@enable) disable this if porting to ROBLOX
if love.filesystem.exists("data.lua") then
    love.filesystem.load("data.lua")()
else
    love.filesystem.write('data.lua',[[
if nn_workspace then
	-- edit this if you're currently using snn executor
	nn_workspace.input[default_parent].bias = 6 -- you can replace default_parent with name of neurotransmitter

	nn_workspace.exeptions[default_parent].bias = {
		dopamine=2, -- dopamine is now a strong exhibitory chemical for the bias neuron
		substance_p = -2  -- substance p is now a strong inhibitory chemical for the bias neuron
	}
else
	--edit this if you're currently using snn builder
	exeption_list=exeption_list or{}
	neuron_input=neuron_input or{}
	neuron_input.bias=6

	exeption_list.bias = {
	    dopamine=2, -- dopamine is now a strong exhibitory chemical for the bias neuron
	    substance_p = -2  -- substance p is now a strong inhibitory chemical for the bias neuron
	}
end]]) -- you'll want to add a space in the double ] or else the thingie wont work in ROBLOX
    neuron_input = {}
    exeption_list = {}
end

function love.focus()
    if love.filesystem.exists("data.lua") then
        love.filesystem.load("data.lua")()
    end
end
--]]

function raw_action(t)
    t = math.max(0,t)
    return (math.cos((math.pi*2)/(t+0.8))/(t+1)^2)*1.125
end

function action_potential(t)
    t=t/100
    if t < 3.2 then
        return raw_action(t+0.016)*43
    else
        return 0,true
    end
end
function propegated_action_potential(t)
    t=t/100
    if t < 0.5555555 then
        return raw_action(t)*43
    else
        return 0,true
    end
end
-- make it use low-pass filter for activation? nvm thats dumb

function approx_equal(a,b,e)
    local m = 10^(e or 3)
    return (math.floor(a*m+0.5)/m)==(math.floor(a*b+0.5)/m)
end

local ftype = type
function clone_table(t)
	local new = {}
	for i,v in pairs(t) do
		new[i] = v
	end
	local meta = getmetatable(t)
	if meta then
		setmetatable(new,meta)
	end
	return  new
end

local default = { -- coulda just used switch function but im cool xd
    input = {}, -- format = [tick()] = {intensity,type},
    connections={},
    synthesis='action_p',
    threshold=6,
}

types = {
	input_neuron = {"connections","synthesis","input","threshold"},
	hidden_neuron= {"connections","synthesis","input","threshold"},
	output_neuron= {"connections","synthesis","input","threshold"},
	soft_mem_neuron={"connections","synthesis","input","threshold"},
}

function nn_workspace:destroy(name)
    nn_workspace.loaded[name]=nil
    
end

function nn_workspace:new_connection(from,to,v)
	from.connections[to] = v
end

function nn_workspace:get_activation(neuron) --
    if neuron.type ~= 'input_neuron' then
        local bassline_value = 0

        if neuron.locked and (neuron.locked =='perm' or (neuron.lock_chance or neuron.locked+settings.lock_time) > gametime) then
            print(neuron.locked)
            bassline_value = neuron.threshold
        else
            if neuron.locked then
                neuron.locked = nil
                neuron.input = {{time=gametime-20,amount=neuron.threshold,linear=true,transmitter='action_p'},{time=gametime,amount=-neuron.threshold,linear=true,transmitter='action_p'}}
            end
            local bassline_transmitters = {}
            neuron.input = neuron.input or {}

            local channels_closed

            if neuron.input.fire then
                local value,term = action_potential(gametime-neuron.input.fire)
                bassline_value = value
                if value >= 0 then
                    channels_closed = true
                else
                    setmetatable(neuron.input,{})
                end
                if term then
                    neuron.input.fire = nil
                end
            end

            if not channels_closed then
                for index,data in  pairs(neuron.input) do -- gets activation value for each neurotransmitter
                    if type(data) ~= 'number' then
                        local offset_time = gametime-data.time
                        local activation,term

                        if not data.linear then
                            activation,term = propegated_action_potential(offset_time)
                        else
                            activation= data.activation
                        end


                        if term then
                            neuron.input[index] = nil 
                        else
                            bassline_transmitters[data.transmitter] =  (bassline_transmitters[data.transmitter] or 0) + activation * data.amount
                        end
                    end
                end

                local new_combinations = true
                while new_combinations do -- combines neurotransmitters, while loop to handle multi layered combinations
                    new_combinations = false
                    
                    for _,list in pairs(neuron.neurotransmitter_combination or settings.neurotransmitter_combination) do
                        local combined_value = ''
                        local minima = math.huge
                        local existant = true
                        local negative_minima = false

                        for _,neurotransmitter in pairs(list) do
                            if  bassline_transmitters[neurotransmitter] then
                                minima = math.min(minima,math.abs(bassline_transmitters[neurotransmitter]))
                                if math.abs(bassline_transmitters[neurotransmitter]) == minima then
                                    negative_minima = minima == (bassline_transmitters[neurotransmitter])
                                end
                                local connective = ((combined_value~='') and '_') or '' -- serialises the new neurotransmitter mixture name 
                                combined_value = combined_value..connective..neurotransmitter -- e.g. epinephrine_dopamine
                            else 
                                existant = false
                            end
                        end
                        if negative_minima then
                            minima = -minima
                        end


                        --if minima > 0 then
                            if existant then -- able to make combination
                                new_combination = true
                                for _,neurotransmitter in pairs(list) do
                                    if approx_equal(bassline_transmitters[neurotransmitter],0) then -- ik 
                                        bassline_transmitters[neurotransmitter] = nil -- all used up, no point in keeping track of it
                                    else
                                        bassline_transmitters[neurotransmitter] = bassline_transmitters[neurotransmitter]-minima
                                    end
                                end
                                bassline_transmitters[combined_value] = minima
                            end
                        --end


                    end
                end
                 -- bassline_transmitters have been converted into genuine transmitters value
                for neurotransmitter,value in pairs(bassline_transmitters) do
                    local exeptions = nn_workspace.exeptions[neuron.parent.name][neuron.name]
                    local exeption_multiplier
                    if exeptions then
                        exeption_multiplier = (exeptions[neurotransmitter])-- * settings.neurotransmitter_membrane_offset[neurotransmitter]
                    end
                    exeption_multiplier = exeption_multiplier or settings.neurotransmitter_membrane_offset[neurotransmitter]
                    bassline_value = bassline_value + (exeption_multiplier * value) -- add exeptions
                end
                neuron.transmitter=bassline_transmitters
            end
        end


        neuron.threshold = neuron.threshold or 6

        if bassline_value >= neuron.threshold and (not neuron.input.fire or (action_potential(gametime-neuron.input.fire) < 0) ) then
            --bassline_value = bassline_value - settings.hyperpolarisation_value
            if neuron.type == 'soft_mem_neuron' then
                if not neuron.locked then -- prevents feedback loop
                    if math.random() > (neuron.perm_lock_chance or settings.perm_lock_chance) then
                        neuron.locked = gametime
                    else
                        neuron.locked = 'perm'
                    end
                end

                for reference_neuron,weight in pairs(neuron.connections) do
                    reference_neuron.input = reference_neuron.input or {}
                    if not reference_neuron.input[neuron.name] then
                    --reference_neuron.input = reference_neuron.input or {} -- input seems to randomly dissapear, this is quick fix
                        reference_neuron.input[neuron.name] = {transmitter=neuron.synthesis,time=gametime,linear=true}
                    end
					if reference_neuron.input[neuron.name] then
						reference_neuron.input[neuron.name].amount=weight*bassline_value
					end
                end
            else
                neuron.input = neuron.input or {}

                for reference_neuron,weight in pairs(neuron.connections) do
                    reference_neuron.input = reference_neuron.input or {}
                    --error(weight)
                    reference_neuron.input[reference_neuron.name] = {transmitter=neuron.synthesis,amount=weight,time=gametime} 
                end
				
                neuron.input ={fire = gametime}
                --neuron.transmitter={}
               setmetatable(neuron.input,
                    {
                        __newindex = function()
                        end
                    }
                )
            end
		elseif bassline_value < neuron.threshold and neuron.type == 'soft_mem_neuron' then
			for reference_neuron,weight in pairs(neuron.connections) do
				reference_neuron.input[neuron.name] = nil --{amount=-neuron.threshold,time=gametime,transmitter=neuron.synthesis,linear=true}
			end
        end
        return bassline_value
    else

        neuron.input.output = neuron.input.output or 0

		local input_val=nn_workspace.input[neuron.name]
		neuron.name = tostring(neuron.name)
		local first_space = neuron.name:find(' ') or #neuron.name+1
		local class = neuron.name:sub(1,first_space-1)

		if not input_val and nn_workspace.default_input[class] then
			input_val = nn_workspace.default_input[class]
        elseif not input_val and nn_workspace.default_input[neuron.name] then -- could wrap in 1 if for input_val but im laaaazy
            input_val = nn_workspace.default_input[neuron.name]
		end
		if type(input_val) == 'function' then -- dynamic inputs
			input_val = input_val(neuron.name:sub(first_space,#neuron.name)) --
		end
		-- e.g. if input neuron is called "seen gunshot" it would call nn_workspace.default_input.seen("gunshot") if there is func there and no specific params
		input_val = input_val or 0 -- in case all else fails lol
		

        for reference_neuron,weight in pairs(neuron.connections) do
            reference_neuron.input[neuron.name] = reference_neuron.input[neuron.name] or {transmitter=neuron.synthesis,linear=true, time=gametime,amount=weight}
            if reference_neuron.input[neuron.name] then
                reference_neuron.input[neuron.name].output = reference_neuron.input[neuron.name].output or 0
                local multiplier=math.max(-0.1,math.min(reference_neuron.input[neuron.name].output-input_val,0.1))
                reference_neuron.input[neuron.name].output =reference_neuron.input[neuron.name].output-multiplier
                reference_neuron.input[neuron.name].activation=reference_neuron.input[neuron.name].output
            end
        --   rawset(reference_neuron.input[neuron.name],'activation',neuron.input.output)
        end
    
        return input_val or 0
    end
end

function nn_workspace:instance(parent,name,type,position,...)
    parent = parent or nn_workspace.networks[parent]
	local object = {type=type,name=name,position=position,real=true}

	for index,value in pairs(types[type]) do -- fills in default to be ovewritten
		local val = default[value]
		if ftype(val) == 'table' then
			val = clone_table(val)
		end
		object[value] = val
	end
	for index,value in pairs({...}) do
		local property = types[type][index]
		object[property] = value
	end
	function object:destroy()
		object.real = false
		nn_workspace[object.name] = nil
		local meta = getmetatable(object) or {}
		meta.__mode = 'v'
		for i,_ in pairs(object) do
			object[i] = nil
		end
		setmetatable(object, meta)
	end
	nn_workspace[name] = object
	return object
end

function nn_workspace:getchildren(parent)
    parent = nn_workspace.networks[parent] or nn_workspace.networks[default_parent]
	local children = {}
	for _,value in pairs(parent) do
		if ftype(value) == 'table' and value.position and value.real then
			children[#children+1] = value
		end
	end
	return children
end