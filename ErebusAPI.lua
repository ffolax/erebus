local API = {}

local HttpService = game:GetService("HttpService")

local FUNCTION_URL = "https://mxkmhinrkuycbuktgzwj.supabase.co/functions/v1/heartbeat"

API.SessionID = HttpService:GenerateGUID(false)

function API:StartSession()

    local Response = request({
        Url = FUNCTION_URL,
        Method = "POST",

        Headers = {
            ["Content-Type"] = "application/json"
        },

        Body = HttpService:JSONEncode({
            session_id = API.SessionID,
            executor = identifyexecutor and identifyexecutor() or "Unknown",
            place_id = game.PlaceId
        })
    })

    if not Response then
        warn("[EREBUS API] No response from Edge Function.")
        return false
    end

    if not Response.Success then
        warn("[EREBUS API] HTTP Error:", Response.StatusCode)
        warn(Response.Body)
        return false
    end

    print("[EREBUS API] Session started!")
    return true

end

return API