return function(Context, contentFrame)

    local Container = Context:CreateContainer(250)

    Context:AddTitle("Welcome to Erebus")

    Context:AddButton({
        Text = "Test Button",
        Container = Container,

        Callback = function()
            print("Clicked!")
        end
    })

    Context:AddToggle({
        Text = "Example Toggle",
        Container = Container,

        Callback = function(state)
            print("Toggle:", state)
        end
    })

end