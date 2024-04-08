local windows = {}
local moveSpeed = 5
local torchlightPanel = nil
local debugText = ''
local AnchorBottom = g_ui.AnchorBottom
local AnchorRight = g_ui.AnchorRight
local verticalDirection = 1
local baseOffsetY = 200
local event = nil

function init()
  g_ui.importStyle('torchlight')
  
  connect(g_game, 'onGameEnd', destroyWindows)

  torchlightPanel = g_ui.loadUI('torchlight', modules.game_interface.getRootPanel())      
  
  main()
end

function terminate()
  disconnect(g_game, 'onGameEnd', destroyWindows)

  destroyWindows()
end

function destroyWindows()
  for _,window in pairs(windows) do
    window:destroy()
  end
  windows = {}
end

-- Define function to move the button
local function moveButton(jumpButton, torchlightWindow)
    local position = jumpButton:getPosition()
    local windowPosition = torchlightWindow:getPosition()
    local windowSize = torchlightWindow:getSize()

    position.x = position.x - moveSpeed -- Move button to the left
    jumpButton:setPosition(position)

    -- Check if button reached left border
    if position.x < windowPosition.x then
        -- Reset button position to the right
        position.x = windowPosition.x + windowSize.width - jumpButton:getWidth() -- Adjust position to keep the button within the window
        jumpButton:setPosition(position)
    end
end

-- Define update function to continuously move the button
local function update(jumpButton, torchlightWindow, debugValueLabel)
    local btnPos = jumpButton:getPosition()
    debugValueLabel:setText(tr('buttonX: ' .. btnPos.x .. ' buttonY: ' .. btnPos.y))
    moveButton(jumpButton, torchlightWindow)
    if event then 
        removeEvent(event)
    end    
    event = scheduleEvent(function() update(jumpButton, torchlightWindow, debugValueLabel) end, 20) -- Call update function every 20 milliseconds
end

function main()
    local torchlightWindow = g_ui.createWidget('TorchlightWindow', rootWidget)
    local jumpButton = torchlightWindow:getChildById('jumpButton')
    local debugValueLabel = torchlightWindow:getChildById('labelNameValue')
    -- Get window position and size
    local windowPosition = torchlightWindow:getPosition()
    local windowSize = torchlightWindow:getSize()

    -- Calculate initial position of the button relative to the bottom-right corner of the window
    local initialPos = { 
        x = windowPosition.x + windowSize.width - jumpButton:getWidth(), 
        y = windowPosition.y + windowSize.height - jumpButton:getHeight() 
    }

    -- Print window position and size
    -- local debugTxt = 'Torchlight window position: x->' .. torchlightWindow:getPosition().x .. ' y->' .. torchlightWindow:getPosition().y .. ' Torchlight window size:' .. windowWidth .. ' ' .. windowHeight
    -- debugValueLabel:setText(tr(debugTxt))

    local currentPos = nil
    jumpButton:setPosition(initialPos)

    torchlightWindow:setText(tr('Torchlight Trial'))

    local function destroy()
        torchlightWindow:destroy()
        table.removevalue(windows, torchlightWindow)
    end

    local jumpFunc = function()
        -- Get window position and size
        if verticalDirection == 1 then verticalDirection = -1 else verticalDirection = 1 end
        local windowPosition = torchlightWindow:getPosition()
        local windowSize = torchlightWindow:getSize()
        currentPos = jumpButton:getPosition()
        local rand = math.random(0, 50)
    
        local posY = currentPos.y + (baseOffsetY + rand) * verticalDirection
        posY = math.max(windowPosition.y, posY) -- Ensure posY doesn't go above the top border of the window
        posY = math.min(windowPosition.y + windowSize.height - jumpButton:getHeight(), posY) -- Ensure posY doesn't go below the bottom border of the window
    
        local pos = { x = windowPosition.x + windowSize.width - jumpButton:getWidth(), y = posY }
        jumpButton:setPosition(pos)
        debugValueLabel:setText(tr('currentY: ' .. currentPos.y .. ' newPosY: ' .. pos.y .. ' btnPos: ' .. jumpButton:getPosition().y))
    end
    
    
    jumpButton.onClick = jumpFunc
    torchlightWindow.onEscape = destroy

    table.insert(windows, torchlightWindow)

    -- Start animation
    update(jumpButton, torchlightWindow, debugValueLabel)
end