nn_workspace={networks={},loaded={},input={},output={},exeptions={}} -- but i dont mean networking

--default_parent

function nn_workspace:load(ai_model,name,is_default)
    if is_default then
        default_parent = name
    end
    
    nn_workspace.input[name]= nn_workspace.input[name] or {}
    nn_workspace.output[name]= nn_workspace.output[name] or {}
    nn_workspace.exeptions[name]=nn_workspace.exeptions[name] or {} -- potentially causes issues when overriding data
    

    --@enable this if you're using the SNN in roblox and disable the line after it v
    --nn_workspace.networks[name] = require(game.ReplicatedStorage.ai_models)

    if love.filesystem.exists('workspace_'..ai_model..'.lua') then
        nn_workspace.networks[name]= love.filesystem.load('workspace_'..ai_model..'.lua')()
    else
        nn_workspace.networks[name] = {}
    end

    for i,v in pairs(nn_workspace.networks[name]) do -- disgostin i know
        if type(v) == 'table' then
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
            printable[#printable+1] = {txt=v.name..': '..nn_workspace:get_activation(v),col=settings.colours[v.type]}
            -- just do nn_workspace:get_activation(v) if you dont wanna do table/visualisation stuff
        end
        return printable
    end
    nn_workspace.loaded[name] = update
    return update
end
nn_workspace:load(settings.ai_model,'new civilian',true)

function love.keypressed(key)
    if key =='=' then
        nn_workspace:load(settings.ai_model,'new civilian',true)
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
end]])
    neuron_input = {}
    exeption_list = {}
end

function love.focus()
    if love.filesystem.exists("data.lua") then
        love.filesystem.load("data.lua")()
    end
end
--]]

print(neuron_input,'gang gang')

local function action_potential(x)
    --local x=x*10 -- converts to ms for inpit
	return math.sin(1/(x/36+0.31845))^4
end

local function hyperpolarisation(x)
   return action_potential(x*settings.membrane_leak_multiplier+settings.term_time)--*settings.hyperpolarisation_value * settings.membrane_leak_multiplier -- actually simple, just looks complex because of fancy words
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

function nn_workspace:new_connection(from,to,v)
	from.connections[to] = v
end

function nn_workspace:get_activation(neuron) --
    if neuron.type ~= 'input_neuron' then
        local bassline_value = 0

        if neuron.locked and (neuron.locked =='perm' or (neuron.locked+settings.lock_time) > gametime) then
            bassline_value = neuron.threshold
        else
            neuron.locked = nil
            local bassline_transmitters = {}
            neuron.input = neuron.input or {}
            for index,data in  pairs(neuron.input) do -- gets activation value for each neurotransmitter
                local offset_time = gametime-data.time
                if data.transmitter == 'fire' then
                    local activation = hyperpolarisation(offset_time)
                    if  math.abs(activation) < settings.critical_activation then
                        neuron.input[index] = nil 
                    else
                        bassline_transmitters[data.transmitter] = (bassline_transmitters[data.transmitter] or 0) + activation
                    end
                else
                    local activation = action_potential(offset_time) * data.amount
                    if offset_time > settings.term_time and math.abs(activation) < settings.critical_activation then
                        neuron.input[index] = nil 
                    else
                        bassline_transmitters[data.transmitter] = (bassline_transmitters[data.transmitter] or 0) + activation
                    end
                end
            end

            local new_combinations = true
            while new_combinations do -- combines neurotransmitters, while loop to handle multi layered combinations
                new_combinations = false
                for _,list in pairs(settings.neurotransmitter_combination) do
                    local combined_value = ''
                    local minima = math.huge
                    local existant = true

                    for _,neurotransmitter in pairs(list) do
                        if  bassline_transmitters[neurotransmitter] then
                            minima = math.min(minima,bassline_transmitters[neurotransmitter])
                            local connective = ((combined_value~='') and '_') or '' -- serialises the new neurotransmitter mixture name 
                            combined_value = combined_value..connective..neurotransmitter -- e.g. epinephrine_dopamine
                        else 
                            existant = false
                        end
                    end

                    if existant then -- able to make combination
                        new_combination = true
                        for _,neurotransmitter in pairs(list) do
                            local value = bassline_transmitters[neurotransmitter]-minima
                            if approx_equal(bassline_transmitters[neurotransmitter],0) then -- ik 
                                bassline_transmitters[neurotransmitter] = nil -- all used up, no point in keeping track of it
                            else
                                bassline_transmitters[neurotransmitter] =  bassline_transmitters[neurotransmitter]-minima
                            end
                        end
                        bassline_transmitters[combined_value] = minima
                    end
                end
            end

        
             -- bassline_transmitters have been converted into genuine transmitters value
            for neurotransmitter,value in pairs(bassline_transmitters) do
                local exeptions = nn_workspace.exeptions[neuron.parent.name][neuron.name]
                local exeption_multiplier
                if exeptions then
                    exeption_multiplier = (exeptions[neurotransmitter] or 1) * settings.neurotransmitter_membrane_offset[neurotransmitter]
                end
                exeption_multiplier = exeption_multiplier or settings.neurotransmitter_membrane_offset[neurotransmitter]
                bassline_value = bassline_value + exeption_multiplier * value -- add exeptions
            end
        end

        --neuron fired

        neuron.threshold = neuron.threshold or 6

        if bassline_value >= neuron.threshold then
            bassline_value = bassline_value - settings.hyperpolarisation_value
            if neuron.type == 'soft_mem_neuron' then
                if not neuron.locked then -- prevents feedback loop
                    if math.random() > settings.perm_lock_chance then
                        neuron.locked = gametime
                    else
                        neuron.locked = 'perm'
                    end
                end

                for reference_neuron,weight in pairs(neuron.connections) do
                    reference_neuron.input = reference_neuron.input or {} -- input seems to randomly dissapear, this is quick fix
                    reference_neuron.input[neuron.name] = {transmitter=neuron.synthesis,amount=(weight * bassline_value),time=gametime - settings.term_time}
                end
            else
                neuron.input = neuron.input or {}
                for reference_neuron,weight in pairs(neuron.connections) do
                    reference_neuron.input = reference_neuron.input or {}
                    if reference_neuron.type ~= 'output_neuron' then
                        reference_neuron.input[#reference_neuron.input+1] = {transmitter=neuron.synthesis,amount=(weight * bassline_value),time=gametime} -- :O
                    else
                         reference_neuron.input[reference_neuron.name] = {transmitter=neuron.synthesis,amount=(weight * bassline_value),time=gametime}
                    end
                end
                for i,_ in pairs(neuron.input) do
                    neuron.input[i] = nil
                end
                 neuron.input[1] = {transmitter='fire',time=gametime}
            end
        end
        return bassline_value
    else --
        for reference_neuron,weight in pairs(neuron.connections) do
            reference_neuron.input = reference_neuron.input or {}
            reference_neuron.input[neuron.name] = 
                {transmitter=neuron.synthesis,amount= (nn_workspace.input[neuron.parent.name][neuron.name] or 0) * weight, time=gametime - settings.term_time}
        end
    
        return nn_workspace.input[neuron.parent.name][neuron.name] or 0
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