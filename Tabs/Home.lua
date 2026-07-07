return function(Context)

    local Container = Context:CreateContainer(250)

    Context:AddStatistics({
        Title = "Statistics",
        Container = Container,

        Stats = {
            {"Players", function()
                return #game:GetService("Players"):GetPlayers()
            end},

            {"FPS", function()
                return math.floor(workspace:GetRealPhysicsFPS())
            end},

            {"Place ID", function()
                return game.PlaceId
            end},
        }
    })

end