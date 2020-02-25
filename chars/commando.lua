local Functions = {}

function Functions.smashEffect(player, timeLeft)
    --if timeLeft == 20 + 2 * 60 then
    if player:get("smashVariable") == nil then
        player:set("smashVariable", 0)
        for yy = 0, 40 do
            if player:collidesMap(player.x, player.y - yy) then
                break
            end
            player:set("smashVariable", yy)
        end
    end
    if timeLeft > 2 * 60 then
        player.y = player.y - player:get("smashVariable") / 20
    else
        local angle = (timeLeft % 60) * 3
        player:set("smashVariable", -1 * angle)
        player:fireBullet(
            player.x, player.y,
            angle,
            300, 15, Sprite.find("sparks1")
        )
        player:fireBullet(
            player.x, player.y,
            angle + 180,
            300, 15, Sprite.find("sparks1")
        )
    end
end

function Functions.getSmashTime(player, timeLeft)
    return 20 + 2 * 60
end

function Functions.getSmashDraw(player)
    graphics.alpha(0.5)
    if player:get("smashVariable") ~= nil then
        if player:get("smashVariable") < 0 then
            local angle = player:get("smashVariable") * -1
            graphics.color(Color.YELLOW)
            graphics.line(
                player.x + 300 * math.cos(math.rad(angle)),
                player.y + 300 * math.sin(math.rad(angle) * -1),
                player.x - 300 * math.cos(math.rad(angle)),
                player.y - 300 * math.sin(math.rad(angle) * -1)
            )
            player:set("smashVariable", nil)
        end
    end
    graphics.alpha(1)
end

return Functions