local uiScript = "https://raw.githubusercontent.com/ffolax/erebus/main/ui.lua"
local success, result = pcall(loadstring(http.request(uiScript)))

if success then
    result()
else
    print("Failed to load UI: " .. tostring(result))
end
