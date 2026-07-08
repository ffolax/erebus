function GetExecutor()

    if identifyexecutor then
        local ok, result = pcall(identifyexecutor)

        if ok then
            return result
        end
    end

    return "Unknown"

end

function GetBankRobbed()

    local Robberies = game.workspace:FindFirstChild("Robberies")

    if Robberies and Robberies:FindFirstChild("BankRobbery") then

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

function GetClubRobbed()

    local Robberies = workspace:FindFirstChild("Robberies")

    if Robberies and Robberies:FindFirstChild("Club Robbery") then

        local Club = Robberies["Club Robbery"]:FindFirstChild("Club")

        if not Club then
            return "???"
        end

        local Door = Club:FindFirstChild("Door")

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

function GetJewelerRobbed()

    local Robberies = game.workspace:FindFirstChild("Robberies")

    if Robberies and Robberies:FindFirstChild("Jeweler Safe Robbery") then

        local Jeweler = Robberies["Jeweler Safe Robbery"]:FindFirstChild("Jeweler")
        if not Jeweler then return "???" end
        local Door = Jeweler:FindFirstChild("Door")

        if Door then

            local DoorPivot = Door:GetPivot()

            if DoorPivot.RightVector == Vector3.new(0,0,-1) then

                return "GREEN"

            else

                return "RED"

            end

        end

    end

end

local function QueueErebus()

    local Queue =
        queue_on_teleport
        or queueonteleport
        or (syn and syn.queue_on_teleport)

    if not Queue then
        return
    end

    Queue([[
        loadstring(game:HttpGet("https://raw.githubusercontent.com/ffolax/erebus/main/loader.lua"))()
    ]])

    task.wait(0.25)

end

local Stats = game:GetService("Stats")

local function GetPing()
    return math.floor(game:GetService("Stats").Network.ServerStatsItem["Data Ping"]:GetValue()) .. " ms"
end

return function(Context)

    local Container = Context:CreateContainer(250)
    local API = Context.Services.API

    Context:AddStatistics({

        Title = "Statistics",
        Container = Container,
        Stats = {

            {"Users Online", function()

                local Stats = API:GetStats()

                if not Stats then
                    return "Loading..."
                end

                return tostring(Stats.online_users or 0)

            end},

            {"Total Sessions", function()

                local Stats = API:GetStats()

                if not Stats then
                    return "Loading..."
                end

                return Stats.total_sessions or 0

            end},


            {"Players",function()
                return #game:GetService("Players"):GetPlayers()
            end},


            {"FPS",function()
                return math.floor(workspace:GetRealPhysicsFPS())
            end},


            {"Ping",function()
                return GetPing()
            end},

            {"Place ID",function()
                return game.PlaceId
            end},


            {"Executor",function()
                return GetExecutor()
            end},


            {"Bank",function()
                return GetBankRobbed()
            end},


            {"Club",function()
                return GetClubRobbed()
            end},


            {"Jeweler",function()
                return GetJewelerRobbed()
            end}

        }

    })

    Context:AddButton({
        Text = "Rejoin",

        Callback = function()

            local TeleportService = game:GetService("TeleportService")
            local LocalPlayer = game:GetService("Players").LocalPlayer

            QueueErebus()

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

            local MAX_PAGES = 5
            local PagesSearched = 0

            while true do

                PagesSearched += 1

                if PagesSearched > MAX_PAGES then
                    break
                end

                local Url = ("https://games.roblox.com/v1/games/%d/servers/Public?sortOrder=Asc&limit=100")
                    :format(PlaceId)

                if Cursor ~= "" then
                    Url ..= "&cursor=" .. HttpService:UrlEncode(Cursor)
                end

                local Success, Response = pcall(function()

                    return request({
                        Url = Url,
                        Method = "GET"
                    })

                end)

                if not Success then
                    warn("[EREBUS] Request failed.")
                    return
                end

                if not Response.Success then
                    warn("[EREBUS] HTTP Error:", Response.StatusCode, Response.StatusMessage)
                    return
                end

                local SuccessDecode, Data = pcall(function()
                    return HttpService:JSONDecode(Response.Body)
                end)

                if not SuccessDecode then
                    warn("[EREBUS] Failed to decode JSON.")
                    print(Response.Body)
                    return
                end

                if not Data.data then
                    warn("[EREBUS] Invalid API response.")
                    print(Data)
                    return
                end

                for _, Server in ipairs(Data.data) do

                    if Server.id ~= CurrentJobId
                        and Server.playing > 0
                        and Server.playing < Server.maxPlayers then

                        table.insert(ValidServers, Server.id)

                    end

                end

                if #ValidServers >= 20 then
                    break
                end

                if not Data.nextPageCursor or Data.nextPageCursor == "" then
                    break
                end

                Cursor = Data.nextPageCursor

                task.wait(0.15)

            end

            if #ValidServers == 0 then
                warn("[EREBUS] No servers found.")
                return
            end

            local ServerId = ValidServers[math.random(#ValidServers)]

            QueueErebus()

            TeleportService:TeleportToPlaceInstance(
                PlaceId,
                ServerId,
                Players.LocalPlayer
            )

        end
    })

end
