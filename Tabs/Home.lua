return function(Context)

    local Container = Context:CreateContainer(250)

    Context:AddStatistics({
        Title = "Statistics",

        Stats = {
            {"Players", function()
                return #Players:GetPlayers()
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