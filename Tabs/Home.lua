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

    Context:AddButton({
        Text = "Rejoin",

        Callback = function()

            local TeleportService = game:GetService("TeleportService")
            local LocalPlayer = game:GetService("Players").LocalPlayer

            TeleportService:TeleportToPlaceInstance(
                game.PlaceId,
                game.JobId,
                LocalPlayer
            )

        end
    })

    Context:AddButton({
        Text = "Server Hop",

        Callback = function()

            local HttpService = game:GetService("HttpService")
            local TeleportService = game:GetService("TeleportService")
            local Players = game:GetService("Players")

            local PlaceId = game.PlaceId
            local CurrentJobId = game.JobId

            local Cursor = ""
            local ValidServers = {}

            local MAX_PAGES = 20
            local PagesSearched = 0

            while true do

                PagesSearched += 1

                if PagesSearched >= MAX_PAGES then
                    break
                end

                local Url = ("https://games.roblox.com/v1/games/%d/servers/Public?sortOrder=Asc&limit=100"):format(PlaceId)

                if Cursor ~= "" then
                    Url ..= "&cursor=" .. HttpService:UrlEncode(Cursor)
                end

                local Success, Response = pcall(function()
                    return game:HttpGet(Url)
                end)

                if not Success then
                    warn("[EREBUS] Failed to fetch server list.")
                    return
                end

                local Data = HttpService:JSONDecode(Response)

                for _, Server in ipairs(Data.data) do

                    if Server.id ~= CurrentJobId
                    and Server.playing < Server.maxPlayers
                    and Server.playing > 0 then

                        table.insert(ValidServers, Server.id)

                    end

                end

                if not Data.nextPageCursor or Data.nextPageCursor == "" then
                    break
                end

                Cursor = Data.nextPageCursor

                task.wait(0.1)

            end

            if #ValidServers == 0 then
                warn("[EREBUS] No available servers found.")
                return
            end

            local RandomServer = ValidServers[math.random(1, #ValidServers)]

            TeleportService:TeleportToPlaceInstance(
                PlaceId,
                RandomServer,
                Players.LocalPlayer
            )

        end
    })

end