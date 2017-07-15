
--ONLY FOR ROBLOX


--render innit
local function resize(p1,p2)
	local offset = (p2-p1)
	return math.sqrt(offset.X^2+offset.Y^2),math.deg(math.atan2(offset.Y,offset.X))

end
local function draw_connections(_model,origin,connected_to,weight)
	if connected_to.name then
		local _connected_to = _model[connected_to.name]
		local _origin = _model[origin.name]
		local _model = _model or _tmodel


		if not _origin.connections:FindFirstChild(_connected_to.Name) then
			local connection_cluster = Instance.new("Frame")
			connection_cluster.Parent = _origin.connections
			connection_cluster.Position = UDim2.new(0.5,0,0,0)
			connection_cluster.Name = connected_to.name

			local size,angle = resize(connection_cluster.AbsolutePosition,(_connected_to.AbsolutePosition+Vector2.new(25,50)))
			connection_cluster.Rotation = angle

			local connection = Instance.new("Frame")
			connection.Parent = connection_cluster

			connection.Size = UDim2.new(0,size,0,0)
			local col = settings.colours[origin.synthesis]
			connection.BackgroundTransparency = 1-math.abs(weight)
			if weight>0 then
				connection.BorderColor3 = Color3.fromRGB(col[1],col[2],col[3])
			else
				connection.BorderColor3 = Color3.fromRGB(255-col[1],255-col[2],255-col[3])
			end
		else
			local connection_cluster = _origin.connections[connected_to.name]
			local size,angle = resize(_origin.AbsolutePosition,(_connected_to.AbsolutePosition+Vector2.new(0,50)))
			connection_cluster.Rotation = angle

			local connection = connection_cluster.Frame
			connection.Size = UDim2.new(0,size,0,0)
		end
	end
end

function create_network_map(network_parent,_model)
	network_parent = network_parent or default_parent
	_model = _model or _tmodel

	for _,data in pairs(nn_workspace:getchildren(network_parent)) do
		local new_neuron = game.ReplicatedStorage.neuron:Clone()
		new_neuron.Name = data.name

		new_neuron.Parent = _model
		new_neuron.Position = UDim2.new(0,data.position.X,0,data.position.Y)
		new_neuron.txt.Text = data.name
		local col = settings.colours[data.synthesis]
		new_neuron.neurotransmitter.BackgroundColor3 = Color3.fromRGB(col[1]/2,col[2]/2,col[3]/2)

		local col =settings.colours[data.type]
		new_neuron.BackgroundColor3 = Color3.fromRGB(col[1],col[2],col[3])
	end
	return function(printable)
		--error('talk of the town')
		for from,activation in pairs(printable) do
			for to,weight in pairs(from.connections) do
				draw_connections(_model,from,to,weight)
			end
			activation = (activation/10)+0.2
			_model[from.name].activation.BackgroundColor3 = Color3.new(activation,activation,activation)
		end
	end
end

-- do create_network_map(default_parent,GUI FRAME) and itll create network model there. this returns function which updates it, so you can call it with the update loop for the actual NN