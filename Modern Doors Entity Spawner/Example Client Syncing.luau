-- Uses a modified copy of Vynixu's DOORS Entity Spawner V2 with a built-in Jumpscare option (see the Jumpscare block below)
local Spawner = loadstring(game:HttpGet("https://raw.githubusercontent.com/Tricot676/Doors-Modes/refs/heads/main/Modern%20Doors%20Entity%20Spawner/init.luau"))()
local Communicator = loadstring(game:HttpGet("https://raw.githubusercontent.com/RegularVynixu/Communicator/main/init.luau"))()

-- \\ Services // --

local Players = game:GetService("Players")

-- \\ Variables // --

local LocalPlayer = Players.LocalPlayer
local Host: Player? = nil

local activeClients = {} :: {Player}
local listOfEntities = {
    [1] = Spawner:Create({
        Entity = {
            Name = "Template Entity",
            Asset = "https://github.com/RegularVynixu/DOORS-Entity-Spawner-V2/raw/main/Assets/Entities/Rush.rbxm",
            HeightOffset = 0
        },
        Lights = {
            Flicker = {
                Enabled = true,
                Duration = 1
            },
            Shatter = true,
            Repair = false
        },
        Earthquake = {
            Enabled = true
        },
        CameraShake = {
            Enabled = true,
            Range = 100,
            Values = {1.5, 20, 0.1, 1} -- Magnitude, Roughness, FadeIn, FadeOut
        },
        Movement = {
            Speed = 100,
            Delay = 2,
            Reversed = false
        },
        Rebounding = {
            Enabled = true,
            Type = "Ambush", -- "Blitz"
            Min = 1,
            Max = 1,
            Delay = 2
        },
        Damage = {
            Enabled = true,
		    IgnoreHiding = false,
            Range = 40,
            Amount = 125
        },
        Crucifixion = {
            Type = "Guiding",
            Enabled = true,
            Range = 40,
            Resist = false,
            Break = true
        },
        Death = {
            Type = "Guiding", -- "Curious"
            Hints = {"Death", "Hints", "Go", "Here"},
            Cause = ""
        },
        Jumpscare = {
            Enabled = false, -- Set to true to show a jumpscare when the entity kills the player
            Image1 = "rbxassetid://0", -- Shown during the tease (rbxassetid or a direct image URL)
            Image2 = "rbxassetid://0", -- Shown during the scare (falls back to Image1 if empty)
            Sound1 = { Id = 0, Properties = { Volume = 1 } }, -- Plays when the tease starts (only if Tease is enabled)
            Sound2 = { Id = 0, Properties = { Volume = 1 } }, -- Plays at the scare
            Shake = true,
            Flashing = {
                Enabled = true,
                Color = Color3.fromRGB(255, 255, 255)
            },
            Tease = {
                Enabled = false,
                Min = 1,
                Max = 3
            },
            AspectRatio = 1, -- Image width / height (e.g. 16/9 for wide images, 1 for square)
            Scale = { -- Image HEIGHT as a multiple of the screen height
                Start = 0.7, -- Size when the scare begins
                End = 1.85 -- Size the scare grows to
            }
        }
    })
}

-- \\ Setup // --

Communicator.Config.ExcludeSelf = false

task.spawn(function()
    while true do
        activeClients = Communicator:Ping(1, true)
        
        -- Elect player as Host by UserId
        table.sort(activeClients, function(a: Player, b: Player)
            return a.UserId < b.UserId
        end)

        local host = activeClients[1]
        if host ~= Host then
            print("New Host elected:", host)
        end

        Host = host

        task.wait(10)
    end
end)

Communicator:Listen("SpawnEntity", function(sender: Player, id: number)
    if sender ~= Host then
        -- Ignore commands not sent by Host
        return
    end

    -- Spawn entity with id
    listOfEntities[id]:Run(true)
end)

-- \\ Main // --

while task.wait( math.random(10, 30) ) do
    if LocalPlayer == Host then
        -- Request to summon random entity as Host
        local randomId = math.random(1, #listOfEntities)
        Communicator:Send("SpawnEntity", randomId)
    end
end
