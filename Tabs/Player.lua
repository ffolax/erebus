return function(Context)

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