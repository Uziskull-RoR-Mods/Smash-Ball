-- Made by Uziskull

local empty_sprite = Sprite.load("smash_ball_empty_sprite", "sprites/empty", 1, 0, 0)

function getScreenCorners(player)
    local cameraWidth, cameraHeight = graphics.getGameResolution()
    local stageWidth, stageHeight = Stage.getDimensions()
    local drawX = 0
    if player.x > cameraWidth / 2 then
        drawX = player.x - cameraWidth / 2
        if drawX + cameraWidth > stageWidth then
            drawX = stageWidth - cameraWidth
        end
    end
    local drawY = 0
    if player.y > cameraHeight / 2 then
        drawY = player.y - cameraHeight / 2
        if drawY + cameraHeight > stageHeight then
            drawY = stageHeight - cameraHeight
        end
    end
    
    return drawX, drawY, drawX + cameraWidth, drawY + cameraHeight
end

local chars = {}
chars["Commando"] = require("chars/commando")
chars["Enforcer"] = require("chars/enforcer")
chars["Bandit"] = require("chars/bandit")
chars["Huntress"] = require("chars/huntress")
chars["HAN-D"] = require("chars/han-d")
chars["Engineer"] = require("chars/engineer")
chars["Miner"] = require("chars/miner")
chars["Sniper"] = require("chars/sniper")
chars["Acrid"] = require("chars/acrid")
chars["Mercenary"] = require("chars/mercenary")
chars["Loader"] = require("chars/loader")
chars["CHEF"] = require("chars/chef")


local spawnCooldown = 20 * 60
local orbChance = 20 * 60
local focusedPlayer = nil
local sneakyBoi = nil
local smashEffectHandler = nil

local function drawSmashEffect(handler, frame)
    local player = nil
    for _, p in ipairs(misc.players) do
        if p.id == handler:get("player") then
            player = p
            break
        end
    end
    
    -- dark effect
    local stageWidth, stageHeight = Stage.getDimensions()
    graphics.color(Color.BLACK)
    graphics.alpha(0.5)
    graphics.rectangle(0, 0, stageWidth, stageHeight, false)
    graphics.alpha(1)
    
    -- glowing effect
    local red = (frame % 10) * 25
    local green = (frame % 10) * 25
    local blue = (frame % 10) * 25
    if frame % 60 >= 0 and frame % 60 < 10 then
        green = 255
        blue = 0
    elseif frame % 60 >= 10 and frame % 60 < 20 then
        red = 255
        blue = 0
    elseif frame % 60 >= 20 and frame % 60 < 30 then
        red = 255
        green = 0
    elseif frame % 60 >= 30 and frame % 60 < 40 then
        blue = 255
        green = 0
    elseif frame % 60 >= 40 and frame % 60 < 50 then
        blue = 255
        red = 0
    else
        green = 255
        red = 0
    end
    local rainbowColor = Color.fromRGB(red, green, blue)
    local direction = player:getFacingDirection()
    if direction == 0 then
        direction = 1
    else
        direction = -1
    end
    graphics.drawImage{
        image = player.sprite,
        x = player.x,
        y = player.y,
        color = rainbowColor,
        alpha = 0.8,
        xscale = 1.2 * direction,
        yscale = 1.2
    }
end

local smashStats = {}

local usingSmash = Buff.new("SMAAAAAASH")
usingSmash.sprite = empty_sprite
usingSmash:addCallback("step", function(player, timeLeft)
    player:set("smashTimeLeft", timeLeft)
    -- use timeLeft for final smashes
    local charFunctions = chars[player:get("name")]
    if charFunctions ~= nil then
        charFunctions.smashEffect(player, timeLeft)
    else
        -- custom characters
        
    end
end)
usingSmash:addCallback("end", function(player)
    player:set("smashVariable", nil)
    player:set("smashTimeLeft", nil)

    player:set("pHmax", smashStats[player.id][1])
    player:set("pVmax", smashStats[player.id][2])
    player:set("pVspeed", smashStats[player.id][3])
    player:set("pGravity1", smashStats[player.id][4])
    player:set("pGravity2", smashStats[player.id][5])
        
    spawnCooldown = 20 * 60
    smashEffectHandler:destroy()
    smashEffectHandler = nil
    
    -- add new player POI
    
    
end)

local smashBuff = Buff.new("Standby Form")
smashBuff.sprite = empty_sprite
smashBuff:addCallback("start", function(player)
    smashEffectHandler = graphics.bindDepth(-7, drawSmashEffect)
    smashEffectHandler:set("player", player.id)
end)
smashBuff:addCallback("step", function(player, timeLeft)
    player:setAlarm(5, 10)
    if player:control("ability4") == input.PRESSED and player:get("activity") == 0 then
        
        -- delete player's POI
        
        
        
        -- set time needed for final smash
        local smashTime = 1
        local charFunctions = chars[player:get("name")]
        if charFunctions ~= nil then
            smashTime = smashTime + charFunctions.getSmashTime(player, timeLeft)
        else
            -- custom characters
            
        end
        
        player:set("invincible", smashTime)
        for i = 0, 5 do
            if i ~= 1 then
                if player:getAlarm(i) < smashTime then
                    player:setAlarm(i, smashTime)
                end
            end
        end
        smashStats[player.id] = {
            player:get("pHmax"),
            player:get("pVmax"),
            player:get("pVspeed"),
            player:get("pGravity1"),
            player:get("pGravity2")
        }
        player:set("pHmax", 0)
        player:set("pVmax", 0)
        player:set("pVspeed", 0)
        player:set("pGravity1", 0)
        player:set("pGravity2", 0)
        
        player:applyBuff(usingSmash, smashTime)
        player:removeBuff(smashBuff)
    end
end)
smashBuff:addCallback("end", function(player)
    if not player:hasBuff(usingSmash) then
        -- add new player POI
        
        
        if smashEffectHandler:get("gotAttacked") ~= nil then
            spawnCooldown = 20 * 60
        end
        smashEffectHandler:destroy()
        smashEffectHandler = nil
    end
end)

local smashBall = Object.new("Smash Ball")
smashBall.sprite = Sprite.load("smash_ball_orb_sprite", "sprites/ball", 60, 8, 8)
smashBall:addCallback("create", function(self)
    self:set("angleDest", 0)
    self:set("length", 0)
    self:set("currentLength", 0)
    self:set("speed", 0)
    self:set("life", 0)
    
    sneakyBoi = Object.find("Lizard"):create(self.x, self.y)
    sneakyBoi.xscale = 1/(sneakyBoi.sprite.width) * 10
    sneakyBoi.yscale = 1/(sneakyBoi.sprite.height) * 10
    sneakyBoi:set("smash", 1)
    sneakyBoi.alpha = 0
    sneakyBoi:set("hits", 0)
end)
smashBall:addCallback("draw", function(self)
    if self:get("life") <= 6 then
        local a = 0
        if self:get("life") == 1 or self:get("life") == 6 then
            a = 0.1
        elseif self:get("life") == 2 or self:get("life") == 5 then
            a = 0.2
        elseif self:get("life") == 3 or self:get("life") == 4 then
            a = 0.3
        end
        graphics.color(Color.WHITE)
        graphics.alpha(a)
        local w, h = Stage.getDimensions()
        graphics.rectangle(0, 0, w, h, false)
        graphics.alpha(1)
    end
end)
smashBall:addCallback("step", function(self)
    -- TODO: make sneakyBoi invulnerable to all buffs
    self:set("life", self:get("life") + 1)
    
    if self:get("life") >= 30 * 60 or not sneakyBoi:isValid() then
        self:destroy()
    else
        if self:get("speed") <= 0.1 and self:get("currentLength") < 10 then
            if self.x < focusedPlayer.x - 100 or self.x > focusedPlayer.x + 100 or self.y < focusedPlayer.y - 100 or self.y > focusedPlayer.y + 100 then
                local angleIncrease = 180
                if self.x < focusedPlayer.x then
                    angleIncrease = 360
                end
                local calcAngle = angleIncrease + math.deg(math.atan(
                    (focusedPlayer.y - self.y)/(focusedPlayer.x - self.x)
                ))
                self:set("angleDest", calcAngle)
            else
                self:set("angleDest", math.random(16) * 360 / 16)
            end
            self:set("length", math.random(35) + 35)
            self:set("currentLength", self:get("length"))
            self:set("maxSpeed", math.random(25) / 100 + 0.75)
        end
        if self:get("speed") < self:get("maxSpeed") and self:get("currentLength") >= self:get("length") / 2 then
            self:set("speed", self:get("speed") + 0.005)
            if self:get("speed") > self:get("maxSpeed") then
                self:set("speed", self:get("maxSpeed"))
            end
        elseif self:get("speed") > 0 and self:get("currentLength") < self:get("length") / 2 then
            self:set("speed", self:get("speed") - 0.005)
            if self:get("speed") < 0 then
                self:set("speed", 0)
            end
        end
        
        if self:get("speed") > 0 then
            self:set("currentLength", self:get("currentLength") - self:get("speed") * math.sqrt(math.cos(math.rad(self:get("angleDest")))^2 + math.sin(math.rad(self:get("angleDest")))^2))
            self.x = self.x + self:get("speed") * math.cos(math.rad(self:get("angleDest")))
            self.y = self.y + self:get("speed") * math.sin(math.rad(self:get("angleDest")))
        end
        
        sneakyBoi:setAlarm(2, 2)
        sneakyBoi.x = self.x
        sneakyBoi.y = self.y
    end
end)
smashBall:addCallback("destroy", function(self)
    if sneakyBoi:isValid() then
        sneakyBoi:destroy()
    end
    sneakyBoi = nil
    focusedPlayer = nil
    
    local noBuffsAroundHere = true
    for _, player in ipairs(misc.players) do
        if player:hasBuff(smashBuff) then
            noBuffsAroundHere = false
            break
        end
    end
    if noBuffsAroundHere then
        spawnCooldown = 20 * 60
    end
end)


registercallback("onStep", function()
    if spawnCooldown > 0 then
        spawnCooldown = spawnCooldown - 1
    elseif spawnCooldown == 0 then
        if math.random(5 * 60 + orbChance) == 1 then
            orbChance = 20 * 60
            spawnCooldown = -1
            
            focusedPlayer = misc.players[math.random(#misc.players)]
            
            local coordsY = {}
            for y = focusedPlayer.y - 100, focusedPlayer.y + 100, 10 do
                table.insert(coordsY, y)
            end
            local coordsX = {}
            for x = focusedPlayer.x - 100, focusedPlayer.x + 100, 10 do
                table.insert(coordsX, x)
            end
            smashBall:create(coordsX[math.random(#coordsX)], coordsY[math.random(#coordsY)])
        else
            if orbChance > 0 then orbChance = orbChance - 1 end
        end
    end
end)

registercallback("preHit", function(damager, hit)
    if hit ~= nil then
        if hit == sneakyBoi and isa(damager:getParent(), "PlayerInstance") then
            damager:set("damage", 0)
            -- if doesn't work, try damager:destroy()
            sneakyBoi:set("hits", sneakyBoi:get("hits") + 1)
            if sneakyBoi:get("hits") == 3 then
                damager:getParent():applyBuff(smashBuff, 10 * 60)
                sneakyBoi:destroy()
            end
        else
            for _, p in ipairs(misc.players) do
                if hit == p then
                    if p:hasBuff(smashBuff) and not p:hasBuff(usingSmash) then
                        smashEffectHandler:set("gotAttacked", 1)
                        p:removeBuff(smashBuff)
                        focusedPlayer = p
                        smashBall:create(p.x, p.y)
                    end
                    break
                end
            end
        end
    end
end)

registercallback("onStageEntry", function()
    spawnCooldown = 20 * 60
    orbChance = 20 * 60
end)

registercallback("onPlayerDraw", function(player)
    local charFunctions = chars[player:get("name")]
    if charFunctions ~= nil then
        charFunctions.getSmashDraw(player)
    else
        -- custom characters
    end
end)