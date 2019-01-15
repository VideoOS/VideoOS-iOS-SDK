--
-- Created by IntelliJ IDEA.
-- User: yanjiangbo
-- Date: 2017/7/21
-- Time: 下午4:28
-- To change this template use File | Settings | File Templates.

local Native = Native()
local videoWidth, videoHeight = Native:getVideoSize()
local isPortraitScreen = Native:isPortraitScreen()
local screenScale = videoHeight / videoWidth

local positionScaleX = 0.3
local positionScaleY = 0.7
local positionX = videoWidth * positionScaleX
local positionY = videoHeight * positionScaleY
local imageSize = 45
local iconImageUrl = "https://staticcdn.videojj.com/FoAK4bKqsc1VqmkG6oBQKNZro_1U"
local exString = "七七新建-芒果海报"
local lableTextColor = 0x486823
local lableTextBg = 0x001111
local animationType = "rotation"
imageSize = isPortraitScreen and imageSize * screenScale or imageSize
local textLeftPadding = isPortraitScreen and imageSize / 4 * screenScale or imageSize / 4
local textCornerRadius = isPortraitScreen and imageSize / 4 * screenScale or imageSize / 4
local textSize = isPortraitScreen and 15 * screenScale or 15
local textHeight = isPortraitScreen and 30 * screenScale or 30
local textLength = Native:stringDrawLength(exString, textSize)

function startRightRoundAnimation(view, animationType)
    local animation = Animation()
    if (animationType == "rotation") then
        animation:rotation(60, -60)
    elseif (animationType == "alpha") then
        animation:alpha(1, 0.2)
    elseif (animationType == "rotationX") then
        animation:rotation(0, 360)
    end
    animation:duration(2):repeatCount(-1):with(view):start()
end

function startLableAnimation(label, positionScaleX, textLength)
    local startX, startY, sizeX, sizeY = label:frame();
    if positionScaleX > 0.5 then
        label:frame(startX + textLength, startY, sizeX, sizeY)
        Animation():translation(-textLength, 0):duration(0.5):repeatCount(0):with(label):start()
    else
        label:frame(startX - textLength, startY, sizeX, sizeY)
        Animation():translation(textLength, 0):duration(0.5):repeatCount(0):with(label):start()
    end
end

function initLable()
    local textBgView = View()
    if positionScaleX > 0.5 then
        textBgView:frame(0, (imageSize - textHeight) / 2, textLength + textLeftPadding * 2, textHeight)
    else
        textBgView:frame(imageSize - textLeftPadding, (imageSize - textHeight) / 2, textLength + textLeftPadding * 2, textHeight)
    end
    textBgView:backgroundColor(lableTextBg)
    textBgView:cornerRadius(textCornerRadius)

    local exLabel = Label()
    exLabel:frame(textLeftPadding, 0, textLength, textHeight);
    exLabel:text(exString)
    exLabel:textSize(textSize)
    exLabel:textColor(lableTextColor)
    exLabel:lineCount(1)
    exLabel:textAlign(TextAlign.LEFT)
    exLabel:onClick(function()
        Native:sendAction("turn://haibao_detail.lua")
    end)
    textBgView:addView(exLabel)
    return textBgView
end

function initIcon()

    local iconImage = Image()
    if positionScaleX > 0.5 then
        iconImage:frame(textLeftPadding + textLength, 0, imageSize, imageSize)
    else
        iconImage:frame(0, 0, imageSize, imageSize)
    end
    iconImage:image(iconImageUrl)
    iconImage:cornerRadius(imageSize / 2)
    iconImage:onClick(function()
        view:removeFromParent()
    end)
    return iconImage
end

function show(jsonString)
    print(tostring(jsonString))
--    data = toTable(jsonString)
    jsonData = jsonString
--    data = Json.toTable(tostring(jsonString))
--    print("data Table ===" .. jsonData)
    test = jsonData["test1"]
--    print("data test === " .. test)
    local viewWidth = imageSize + textLength + textLeftPadding * 2;
    view = View()
    if positionScaleX <= 0.5 then
        view:frame(positionX, positionY, viewWidth, imageSize);
    else
        view:frame(positionX - viewWidth, positionY, viewWidth, imageSize)
    end
    local lable = initLable()
    local icon = initIcon()
    view:addView(lable)
    view:addView(icon)
    startLableAnimation(lable, positionScaleX, textLength)
    startRightRoundAnimation(icon, animationType)
end











