local ps = game:GetService("Players")
local p = ps.LocalPlayer

repeat

    p = ps.LocalPlayer
    task.wait()

until p

if p.UserId == 11319493592 then

    loadstring(game:HttpGet(
        "https://raw.githubusercontent.com/ffolax/erebus/main/Dev/Main.lua"
    ))()

else

    loadstring(game:HttpGet(
        "https://raw.githubusercontent.com/ffolax/erebus/main/Release/Main.lua"
    ))()

end