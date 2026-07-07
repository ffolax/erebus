local ps = game:GetService("Players")
local p = ps.LocalPlayer

if p.UserId == 11232890519 then

    loadstring(game:HttpGet(
        "https://raw.githubusercontent.com/ffolax/erebus/main/Dev/Main.lua"
    ))()

else

    loadstring(game:HttpGet(
        "https://raw.githubusercontent.com/ffolax/erebus/main/Release/Main.lua"
    ))()

end
