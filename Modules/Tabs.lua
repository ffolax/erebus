return function(Context, UI)

    local Tabs = {}

    Tabs.Main = {
        OnOpen = function()
            print("Main tab opened")

            UI:CreateButton("Test Button", function()
                print("Clicked!")
            end)
        end
    }

    Tabs.Settings = {
        OnOpen = function()
            print("Settings tab opened")
        end
    }

    for name, data in pairs(Tabs) do
        Context:RegisterTab(name, data)
    end

    Context:SetActiveTab("Main")
end
