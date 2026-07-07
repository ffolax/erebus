local Home = {}

function Home.Load(UI)

    UI:RegisterTab("Home", {

        OnOpen = function()

            print("Opened Home Tab")

        end,

        Build = function()

            local Container = UI:CreateContainer(250)


            UI:AddTitle("Welcome to Erebus")


            UI:AddButton({
                Text = "Test Button",
                Container = Container,

                Callback = function()
                    print("Button clicked!")
                end
            })


            UI:AddToggle({
                Text = "Example Toggle",
                Container = Container,

                Default = false,

                Callback = function(State)
                    print("Toggle:", State)
                end
            })


            UI:AddSlider({
                Text = "Example Slider",
                Container = Container,

                Default = 50,

                Callback = function(Value)
                    print("Slider:", Value)
                end
            })

        end

    })

end

return Home