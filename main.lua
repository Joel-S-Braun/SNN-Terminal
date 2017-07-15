--[ enable this for LOVE2D usage, disable in ROBLOX

function love.load()
	
    love.filesystem.setIdentity('snn', searchorder)
	require("settings")
	require("workspace")
end

love.graphics.newFont(13)

love.graphics.setBackgroundColor(29,31,33)

function love.draw()
	local t = 1
	gametime = gametime + settings.step
	love.graphics.printf('fps: '..love.timer.getFPS(),0,0,500)

	for i,v in pairs(nn_workspace.loaded) do
        love.graphics.setColor(255,255,255)
        love.graphics.printf('running: '..i,0,t*16,500)
        t=t+1
        local classes={}
		for i,v in pairs(v()) do
			i.name = tonumber(i.name) or i.name
            graph[i.name] = graph[i.name] or {}
            graph[i.name][#graph[i.name]+1] = v
            
            if #graph[i.name] >= (150/settings.step) * settings.scale then
                table.remove(graph[i.name],1)
            end

            neurograph[i.name] = neurograph[i.name] or {}
            neurograph[i.name][#neurograph[i.name]+1] = i.transmitter

            if #neurograph[i.name] >= (150/settings.step) * settings.scale then
                table.remove(neurograph[i.name],1)
            end

            classes[i.type] = classes[i.type] or {}
            classes[i.type][i.name]={neuron=i,voltage=v}
        end
		
        for i,v in pairs(classes) do
           for i,v in pairs(v) do
                t = t + 1
                local y = (t*30)%love.graphics.getHeight()
                local x = math.floor((t*30)/love.graphics.getHeight()) * (160+150)
                local col = settings.colours[v.neuron.type]

                local threshold = (y-(((6+v.neuron.threshold)/49)*30))
                local bassline = (y-(((6)/49)*30))

                love.graphics.setColor(255,0,0,100)
                love.graphics.line(x+160, threshold+30, x+160+150, threshold+30)

                love.graphics.setColor(0,0,255,100)
                love.graphics.line(x+160, bassline+30, x+160+150, bassline+30)

                if graph[v.neuron.name] then
                    for i,slices in pairs(neurograph[v.neuron.name]) do
                        for transmitter,v in pairs(slices) do
                            local color = settings.colours[transmitter]

                            love.graphics.setColor(color[1],color[2],color[3],200)
                           
                            local y = y-(((v+6)/49)*30)
                            love.graphics.rectangle('fill', x+160+((i/settings.scale)*settings.step),y+30, 1,1)
                            
                        end
                    end
                    love.graphics.setColor(115,245,237,150)
                    for i,v in pairs(graph[v.neuron.name]) do
                        local y = y-(((v+6)/49)*30)
                        love.graphics.rectangle('fill', x+160+((i/settings.scale)*settings.step),y+30, 1,1)
                    end
                end
                if v.voltage >= 6 then
                    love.graphics.setColor(col[1],col[2]-30,col[3]-100,255)
                else
                    love.graphics.setColor(col[1],col[2]-30,col[3]-100,150)
                end
                love.graphics.printf(v.neuron.name..':'..v.voltage ,x,y,400) 
            end
        end
	end
end
--]]



--[[@enable if you want to use the SNN in ROBLOX, combine the scripts into 1 in this order. you will want to enable the code below and disable the LOVE2D code
-->settings
-->workspace
-->main

spawn(function()
	while wait() do
       gametime = gametime + settings.step
		for i,v in pairs(nn_workspace.loaded) do
			for i,v in pairs(v()) do
				print(i.name,':',v) -- could also make UI display out of this
			end
		end
	end
end)
--]]