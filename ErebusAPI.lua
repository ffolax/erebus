local API = {}

local HttpService = game:GetService("HttpService")

local FUNCTION_URL =
    "https://mxkmhinrkuycbuktgzwj.supabase.co/functions/v1/heartbeat"

local STATS_URL =
    "https://mxkmhinrkuycbuktgzwj.supabase.co/functions/v1/stats"

local VERSION = "1.0.0"


API.SessionID = HttpService:GenerateGUID(false)


function API:StartSession()

    local Response = request({

        Url = FUNCTION_URL,
        Method = "POST",

        Headers = {
            ["Content-Type"] = "application/json"
        },

        Body = HttpService:JSONEncode({

            session_id = self.SessionID,
            executor = identifyexecutor and identifyexecutor() or "Unknown",
            place_id = game.PlaceId,
            version = VERSION

        })

    })


    if not Response or not Response.Success then

        warn("[EREBUS API] Failed starting session.")

        if Response then
            warn(Response.StatusCode, Response.Body)
        end

        return false

    end


    print("[EREBUS API] Session started!")

    return true

end



function API:Heartbeat()

    request({

        Url = FUNCTION_URL,
        Method = "POST",

        Headers = {
            ["Content-Type"] = "application/json"
        },

        Body = HttpService:JSONEncode({

            session_id = self.SessionID,
            executor = identifyexecutor and identifyexecutor() or "Unknown",
            place_id = game.PlaceId,
            version = VERSION

        })

    })

end



API.CachedStats = nil


function API:GetStats()

    return self.CachedStats

end



function API:StartStatsLoop()

    task.spawn(function()

        while true do

            local Response = request({

                Url = STATS_URL,
                Method = "GET",

            })


            if Response and Response.Success then

                local Success, Data = pcall(function()

                    return HttpService:JSONDecode(Response.Body)

                end)


                if Success then

                    self.CachedStats = Data

                end

            end


            task.wait(10)

        end

    end)

end


return API