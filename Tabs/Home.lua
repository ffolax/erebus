return function(Context)

    local function GetExecutor()

        if identifyexecutor then
            local ok, result = pcall(identifyexecutor)

            if ok then
                return result
            end
        end

        return "Unknown"

    end

    local function GetBankRobbed()

        local Robberies = game.workspace:FindFirstChild("Robberies")

        if Robberies and Robberies.BankRobbery then

            local LightRed = Robberies.BankRobbery:FindFirstChild("LightRed")

            if LightRed then

                if LightRed.Light.Enabled then

                    return "RED"

                else

                    return "GREEN"

                end

            end

        end

        return "???"

    end

    local function GetClubRobbed()

        local Robberies = game.workspace:FindFirstChild("Robberies")

        if Robberies and Robberies:FindFirstChild("Club Robbery") then

            local Club = Robberies["Club Robbery"]:FindFirstChild("Club")
            if not Club then return end
            local Door = Club.Door

            if Door then

                local DoorPivot = Door:GetPivot()

                if DoorPivot.RightVector == Vector3.new(1,0,0) then

                    return "GREEN"

                else

                    return "RED"

                end

            end

        end

        return "???"

    end

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

            {"Game ID", function()
                return game.GameId
            end},

            {"Place ID", function()
                return game.PlaceId
            end},

            {"Executor", function()
                return GetExecutor()
            end},

            {"Bank", function()
                return GetBankRobbed()
            end},

            {"Club", function()
                return GetClubRobbed()
            end},
        }
    })

end