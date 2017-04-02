--[ enable this for LOVE2D usage, disable in ROBLOX
function love.load()
    love.filesystem.setIdentity('snn', searchorder)
	require("settings")
	require("workspace")
end

love.graphics.newFont(13)

function love.draw()
	local t = 0
	gametime = gametime + settings.step

	for i,v in pairs(nn_workspace.loaded) do
        love.graphics.setColor(255,255,255)
        love.graphics.printf('running: '..i,0,0,500)
        t=t+1
        local classes={}
		for i,v in pairs(v()) do
            classes[v.col[1]..v.col[2]] = classes[v.col[1]..v.col[2]] or {}
            classes[v.col[1]..v.col[2]][#classes[v.col[1]..v.col[2]]+1] = v
        end
        for i,v in pairs(classes) do
           for i,v in pairs(v) do
                t = t + 1
               love.graphics.setColor(v.col[1]+30,v.col[2]+30,v.col[3]+30)
                love.graphics.printf(v.txt,0,t*16,400) 
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
		for i,v in pairs(nn_workspace.loaded) do
			for i,v in pairs(v()) do
				print(i,':',v.txt) -- could also make UI display out of this
			end
		end
	end
end)
--]]