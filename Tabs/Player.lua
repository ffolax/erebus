return function(Context)

    Context:AddTitle({
        Text = "Aimbot Settings"
    })

    Context:AddToggle({
        Text = "Aimbot",

        Callback = function(Value)



        end
    })

    local TargetPartDropdown = Context:AddDropdown({

        Text = "Target Part",

        Items = {
            "Head",
            "HumanoidRootPart",
        },

        Callback = function(Value)
            
        end

    })

end