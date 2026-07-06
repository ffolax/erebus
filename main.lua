local uiScript = "https://raw.githubusercontent.com/yourusername/yourrepo/main/ui.lua"
local success, result = pcall(loadstring(http.request(uiScript)))

if success then
    result()
else
    print("Failed to load UI: " .. tostring(result))
end
