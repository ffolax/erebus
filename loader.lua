local p = game:GetService("Players")

if p.UserId == 11232890519 then

    loadstring(game:HttpGet(
        "https://raw.githubusercontent.com/ffolax/erebus/main/dev/Main.lua"
    ))()

else

    loadstring(game:HttpGet(
        "https://raw.githubusercontent.com/ffolax/erebus/main/Release/Main.lua"
    ))()

end
