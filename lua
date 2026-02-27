-- █▀▀ ▄▀█ █░░ ▄▀█ █▀▀ ▀█▀ █ █▀▀   █▀▄ █░█ █▀▄▀█ █▀█ █▀▀ █▀█
-- █▄█ █▀█ █▄▄ █▀█ █▄▄ ░█░ █ █▄▄   █▄▀ █▄█ █░▀░█ █▀▀ ██▄ █▀▄
-- Version v1.7.5
-- https://discord.gg/qy2neXET6W

local env = _G
local Players = game:GetService('Players')
local HttpService = game:GetService('HttpService')
local MarketplaceService = game:GetService('MarketplaceService')
local UserInputService = game:GetService('UserInputService')
local identifyexecutorCall_7 = identifyexecutor()
local gameCall_8 = game.PlaceId
local v9 = MarketplaceService.GetProductInfo(MarketplaceService, gameCall_8)
local v10 = v9.Name.gsub(v9.Name, " ", "-")
local v11 = HttpService:UrlEncode(v10)
local concat_12 = v11 .. ')'
local concat_13 = '/' .. concat_12
local concat_14 = gameCall_8 .. concat_13
local concat_15 = '[Ver página del juego](https://www.roblox.com/games/' .. concat_14
error("[string \"--// Lynox V2 - Logger + GUI (primero loggea,...\"]:82: attempt to call a table value")
