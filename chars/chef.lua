local Functions = {}

local chefSprite = Sprite.load("smash_ball_chef_effect", "sprites/chef/chef", 1, 0, 17) -- TODO: change to actual frames

function Functions.smashEffect(player, timeLeft)
    if timeLeft > 15 + 1.25 * 60 + 5 * 60 then
        -- disappear
        local frame = timeLeft - (1.25 * 60 + 5 * 60)
        player.alpha = frame / 15
    end
    if timeLeft <= 15 then
        -- "meh" way of doing it since idk if timeLeft ever hits 0 and can't bother to check it
        player.alpha = math.min((16 - timeLeft) / 15, 1)
    end
end

function Functions.getSmashTime(player, timeLeft)
    return 30 + 1.25 * 60 + 5 * 60
end

function Functions.getSmashDraw(player)
    if player:get("smashTimeLeft") == 30 + 1.25 * 60 + 5 * 60 then
        local function chefDraw(handler, frames)
            local x1, y1, x2, y2 = getScreenCorners(player)
            local imageScale = (x2 - x1) / chefSprite.width
            if frames > 15 + 1.25 * 60 + 5 * 60 then
                handler:destroy()
            elseif frames > 15 then
                if frames <= 15 + 0.75 * 60 then
                    -- chef popping up
                    graphics.drawImage{
                        image = chefSprite,
                        x = x1,
                        y = y2 + chefSprite.height * imageScale * (1 - ((frames - 15)/(0.75 * 60))),
                        scale = imageScale,
                        subimage = 1
                    }
                elseif frames <= 15 + 1 * 60 then
                    -- hat effect
                    local imageIndex = math.min(math.floor((frames - (15 + 0.75 * 60))/2) + 2, 15) -- 2, 2, 3, 3, 4, 4, ...
                    graphics.drawImage{
                        image = chefSprite,
                        x = x1,
                        y = y2,
                        scale = imageScale,
                        subimage = imageIndex
                    }
                elseif frames <= 15 + 1.25 * 60 then
                    -- blades sharpen + eyes red
                    local imageIndex = frames - (15 + 1 * 60) + 15
                    graphics.drawImage{
                        image = chefSprite,
                        x = x1,
                        y = y2,
                        scale = imageScale,
                        subimage = imageIndex
                    }
                else
                    -- chopping loop
                    
                end
            end
        end
        graphics.bindDepth(-10000, chefDraw)
    end
end

return Functions