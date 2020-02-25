local Functions = {}

local banner = Sprite.load("smash_ball_mercenary_banner", "sprites/mercenary/banner", 1, 0, 0)

function Functions.smashEffect(player, timeLeft)
    if player:get("smashVariable") == nil then
        player:set("smashVariable", #ObjectGroup.find("enemies"):findMatching("smashMarked", 0))
        misc.setTimeStop(60 + 10 * player:get("smashVariable") + 10 * player:get("smashVariable") + 10)
        player.alpha = 0
        player:set("originCoordsX", player.x)
        player:set("originCoordsY", player.y)
    end
    if Sound.find("Watch"):isPlaying() then
        Sound.find("Watch"):stop()
    end
    if misc.getTimeStop() == 1 then
        player.alpha = 1
    end
end

function Functions.getSmashTime(player, timeLeft)
    local count = 0
    local x1, y1, x2, y2 = getScreenCorners(player)
    for _, enemy in ipairs(ObjectGroup.find("enemies"):findAll()) do
        if enemy:isValid() then
            if enemy.x >= x1 and enemy.x <= x2 and enemy.y >= y1 and enemy.y <= y2 then
                count = count + 1
                enemy:set("smashMarked", 0)
            end
        end
    end
    return 60 + 10 * count + 10 * count + 10
end

function Functions.getSmashDraw(player)
    if player:get("smashVariable") ~= nil then
        -- if player:get("smashTimeLeft") > 10 * player:get("smashVariable") + 10 * player:get("smashVariable") + 10 then
            -- local frames = 61 - (player:get("smashTimeLeft") - (10 * player:get("smashVariable") + 10 * player:get("smashVariable") + 10))
        if player:get("smashTimeLeft") == 60 + 10 * player:get("smashVariable") + 10 * player:get("smashVariable") + 10 then
            local function drawBanner(handler, frames)
                if frames > 60 then
                    handler:destroy()
                else
                    local x1, y1, x2, y2 = getScreenCorners(player)
                    graphics.color(Color.BLACK)
                    graphics.alpha(0.5)
                    graphics.rectangle(x1, y1, x2, y2)
                    graphics.alpha(1)
                    -- border
                    graphics.rectangle(x1, y1 + (y2 - y1) * 29 / 90, x2, y2 - (y2 - y1) * 29 / 90)
                    local dX = frames / 60 * (x2 - x1) / 5
                    local coolColor = Color.fromHex(0xAB042F)
                    graphics.color(coolColor)
                    -- background
                    graphics.rectangle(x1, y1 + (y2 - y1) / 3, x2, y2 - (y2 - y1) / 3)
                    graphics.color(Color.lighten(coolColor, 0.3))
                    -- upper stripe
                    graphics.triangle(x1 + (x2 - x1) * 2/5 - dX, y2 - (y2 - y1) * 3 / 6,
                                      x1 + (x2 - x1) * 4/5 - dX, y2 - (y2 - y1) * 4 / 6,
                                      x1 + (x2 - x1) * 4/5 - dX, y2 - (y2 - y1) * 3 / 6)
                    graphics.rectangle(x1 + (x2 - x1) * 4/5 - dX, y2 - (y2 - y1) * 4 / 6,
                                       x2, y2 - (y2 - y1) / 3)
                    -- lower stripe
                    graphics.triangle(x1 + (x2 - x1) * 1/5 - dX, y2 - (y2 - y1) * 2 / 6,
                                      x1 + (x2 - x1) * 3/5 - dX, y2 - (y2 - y1) * 3 / 6,
                                      x1 + (x2 - x1) * 3/5 - dX, y2 - (y2 - y1) * 2 / 6)
                    graphics.rectangle(x1 + (x2 - x1) * 3/5 - dX, y2 - (y2 - y1) * 3 / 6,
                                       x2, y2 - (y2 - y1) / 3)
                    -- mercenary
                    graphics.drawImage{
                        image = banner,
                        x = x1 + (x2 - x1) * 3/10 + dX,
                        y = y1 + (y2 - y1) / 3,
                        scale = ((y2 - y1) / 3) / banner.height
                    }
                    -- TODO: prolly sword
                end
            end
            graphics.bindDepth(-10000, drawBanner)
        end
        --else
        if player:get("smashTimeLeft") <= 10 * player:get("smashVariable") + 10 * player:get("smashVariable") + 10 then
            --local allMarkedEnemies = ObjectGroup.find("enemies"):findMatchingOp("smashMarked", ">", 0)
            local allMarkedEnemies = {}
            for _, enemy in ipairs(ObjectGroup.find("enemies"):findAll()) do
                if enemy:isValid() then
                    if enemy:get("smashMarked") ~= nil then
                        if enemy:get("smashMarked") > 0 then
                            table.insert(allMarkedEnemies, enemy)
                            --allMarkedEnemies[enemy:get("smashMarked")] = enemy
                        end
                    end
                end
            end
            local prevEnemy = nil
            for i, enemy in ipairs(allMarkedEnemies) do
                graphics.color(Color.LIGHT_BLUE)
                graphics.circle(enemy.x, enemy.y, math.max(enemy.sprite.width, enemy.sprite.height) / 3, true)
                if i > 1 then
                    graphics.color(Color.WHITE)
                    graphics.line(enemy.x, enemy.y, prevEnemy.x, prevEnemy.y, 1)
                end
                prevEnemy = enemy
            end
            if player:get("smashTimeLeft") > 10 * player:get("smashVariable") + 10 then
                if player:get("smashTimeLeft") % 10 == 0 then
                    --local markedEnemies = ObjectGroup.find("enemies"):findMatching("smashMarked", 0)
                    local markedEnemies = {}
                    for _, enemy in ipairs(ObjectGroup.find("enemies"):findAll()) do
                        if enemy:isValid() then
                            if enemy:get("smashMarked") ~= nil then
                                if enemy:get("smashMarked") == 0 then
                                    table.insert(markedEnemies, enemy)
                                end
                            end
                        end
                    end
                    local enemy = table.irandom(markedEnemies)
                    if enemy ~= nil then
                        if enemy:isValid() then
                            enemy:set("smashMarked", player:get("smashVariable") - #markedEnemies + 1)
                        end
                    end
                end
            else
                if player:get("smashTimeLeft") % 10 == 0 then
                    local currentEnemy = nil
                    for i, enemy in ipairs(allMarkedEnemies) do
                        if enemy:isValid() then
                            if currentEnemy == nil then
                                currentEnemy = enemy
                            else
                                if enemy:get("smashMarked") ~= nil and currentEnemy:get("smashMarked") ~= nil then -- fixes weird bug
                                    if currentEnemy:get("smashMarked") > enemy:get("smashMarked") then
                                        currentEnemy = enemy
                                    end
                                end
                            end
                        end
                    end
                    if currentEnemy ~= nil then
                        player.x = currentEnemy.x
                        player.y = currentEnemy.y
                        currentEnemy:set("smashMarked", currentEnemy:get("smashMarked") * -1)
                        
                        local killMark = currentEnemy:get("smashMarked") + 1
                        if killMark < 0 then
                            local damageEnemy = ObjectGroup.find("enemies"):findMatching("smashMarked", killMark)[1]
                            damageEnemy:set("smashMarked", nil)
                            local bullet = player:fireBullet(damageEnemy.x - 0.5, damageEnemy.y, 0, 1, 15)
                            bullet:set("specific_target", damageEnemy.id)
                        end
                    else
                        player.x = player:get("originCoordsX")
                        player.y = player:get("originCoordsY")
                        player:set("originCoordsX", nil)
                        player:set("originCoordsY", nil)

                        local damageEnemy = ObjectGroup.find("enemies"):findMatchingOp("smashMarked", "<", 0)[1]
                        local bullet = player:fireBullet(damageEnemy.x - 0.5, damageEnemy.y, 0, 1, 15)
                        bullet:set("specific_target", damageEnemy.id)
                        damageEnemy:set("smashMarked", nil)
                    end
                end
            end
        end
    end
end

return Functions