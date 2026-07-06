local uiScript = "https://raw.githubusercontent.com/ffolax/erebus/main/ui.lua"
local success, result = pcall(loadstring(game:HttpGet(uiScript)))

if success then
    result()
else
    print("Failed to load UI: " .. tostring(result))
end
