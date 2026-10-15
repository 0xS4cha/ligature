local env = require("src.core.env")
local modules = require("src.modules.index")
local GM = require("src.core.index")
local ArgParser = require("src.core.args")
local Camera = require("src.core.camera")

local flags
local camera

--- @param args string[]
function love.load(args)
    env:Load(".env")
    modules:Load("src/modules")
    
    local parser = ArgParser.new()
    parser:add_argument("ci", { default = false, type = "boolean" })
    flags = parser:parse(args)
    
    GM:InitializeModules()
    love.graphics.setBackgroundColor(0.08, 0.08, 0.10)

    local W, H = love.graphics.getDimensions()
    local imgW, imgH = 1920, 1080
    local initialScale = math.max(W / imgW, H / imgH)
    
    camera = Camera()
    camera.mapW = imgW
    camera.mapH = imgH
    camera.scale = initialScale
    camera.x = (W - imgW * initialScale) / (2 * initialScale)
    camera.y = (H - imgH * initialScale) / (2 * initialScale)
    camera:clamp()
    
    GM.Camera = camera
    if flags.ci then
        love.event.quit()
    end
end

--- @param dt number
function love.update(dt)
    GM:Think(dt)
    camera:update(dt)
end

--- @param x number
--- @param y number
function love.wheelmoved(x, y)
    if not flags or flags.heightmap then return end
    local mouseX, mouseY = love.mouse.getPosition()
    if y > 0 then
        camera:zoom(1.1, mouseX, mouseY)
    elseif y < 0 then
        camera:zoom(0.9, mouseX, mouseY)
    end
end

--- @return void
function love.draw()
    camera:apply()
    love.graphics.setColor(1, 1, 1)

    camera:clear()

    for _, moduleName in pairs(GM.Modules.HasFunction.Draw) do
        GM[moduleName]:Draw()
    end
end

--- @param key string
--- @param scancode string
--- @param isrepeat boolean
--- @return void
function love.keypressed(key, scancode, isrepeat)
    if GM.KeyPressed then
        GM:KeyPressed(key, scancode, isrepeat)
    end
end

--- @param x number
--- @param y number
--- @param button number
--- @param istouch boolean
--- @param presses number
--- @return void
function love.mousepressed(x, y, button, istouch, presses)
    if GM.MousePressed then
        GM:MousePressed(x, y, button, istouch, presses)
    end
end

--- @param x number
--- @param y number
--- @param button number
--- @param istouch boolean
--- @param presses number
--- @return void
function love.mousereleased(x, y, button, istouch, presses)
    if GM.MouseReleased then
        GM:MouseReleased(x, y, button, istouch, presses)
    end
end