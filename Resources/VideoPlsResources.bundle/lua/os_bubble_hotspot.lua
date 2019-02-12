--气泡控件--
require "os_config"
require "os_util"
require "os_string"
require "os_constant"
require "os_track"
bubble = object:new()
bubble.views = {}
local scale = getScale()
local delayTime = 0 --记录延时时间
local bubbleIndex = 0 --记录添加滑动控件的index

local bubbleViewSpace = 10
local bubbleImageSpace = 10
local bubbleAngleWidth = 6 --气泡三角的宽度

local promptShowTime = 1000

local allBubbleIsCreate = false

local imageDefaultBackgroundColor = 0xF2F2F3

local bubbleAnimScale = 1.08

local bubbleShowTime = 15000
local bubbleShowAllTime = 13000

local loadBubbleCount = 0
local totalBubbleCount = 0
local showlaunchPlanCount = 0;
--[[
userType 1 左边用户
userType 2 右边用户
messageType 1 文本
messageType 2 图片
messageType 3 选择
]] --

local function getHotspotExposureTrackLink(data, index)
    if (data == nil or index == nil) then
        return nil
    end
    local hotspotTrackLinkTable = data.hotspotTrackLink
    if (hotspotTrackLinkTable == nil) then
        return nil
    end
    local indexHotspotTrackLinkTable = hotspotTrackLinkTable[index]
    if (indexHotspotTrackLinkTable == nil) then
        return nil
    end
    return indexHotspotTrackLinkTable.exposureTrackLink
end

local function getHotspotClickTrackLink(data, index)
    if (data == nil or index == nil) then
        return nil
    end
    local hotspotTrackLinkTable = data.hotspotTrackLink
    if (hotspotTrackLinkTable == nil) then
        return nil
    end
    local indexHotspotTrackLinkTable = hotspotTrackLinkTable[index]
    if (indexHotspotTrackLinkTable == nil) then
        return nil
    end
    return indexHotspotTrackLinkTable.clickTrackLink
end

local function linkUrl(data) --获取linkUrl
    if (data == nil) then
        return nil
    end
    local link = data.link
    if (link ~= nil and string.match(tostring(link), "http") == "http") then
        return link
    else
        return nil
    end
end

local function closeView()
    if Native:getCacheData(bubble.id) == tostring(eventTypeShow) then
        Native:widgetEvent(eventTypeClose, bubble.id, adTypeName, actionTypeNone, "")
        Native:deleteBatchCacheData({ bubble.id })
    end
    Native:destroyView()
end

local function clickView(url, ise)
    Native:widgetEvent(eventTypeClick, bubble.id, adTypeName, actionTypeOpenUrl, url)
    local clickLinkUrl = getHotspotClickTrackLink(bubble.data, 1)
    if (clickLinkUrl ~= nil) then
        Native:get(clickLinkUrl)
    end
    if (bubble.launchPlanId ~= nil) then
        osTrack(bubble.launchPlanId, 3, 2)
    end
end

local function registerWindow()
    local nativeWindow = nil
    if System.ios() then
        nativeWindow = NativeWindow()
    else
        nativeWindow = nativeWindow
    end
    local callbackTable = {
        onShow = function()
        end,
        onHide = function()
            if (System.ios()) then
                closeView()
            end
        end,
        onHome = function()
            closeView()
        end
    }
    if (nativeWindow == nil and System.android()) then
        nativeWindow = window
    end
    if (nativeWindow == nil) then
        return
    end
    nativeWindow:callback(callbackTable)
    return nativeWindow
end

local function getMessagesTable(data)
    if (data == nil) then
        return nil
    end
    local contentDataTable = data.data
    if (contentDataTable == nil) then
        return nil
    end
    return contentDataTable.messages
end

local function scaleAnim(scale)
    local anim = Animation():scale(scale):duration(0.2)
    return anim
end

local function startViewScaleAnim(view, scale, table)
    if (view == nil) then
        return
    end
    if table ~= nil then
        scaleAnim(scale):with(view):callback(table):start()
    else
        scaleAnim(scale):with(view):start()
    end
end

local function moveAnim(x, y)
    local anim = Animation():translation(x, y):duration(0.5):reverses(true):repeatCount(10000)
    return anim
end

local function startViewMoveAnim(view, x, y, table)
    if (view == nil) then
        return
    end
    if table ~= nil then
        moveAnim(x, y):with(view):callback(table):start()
    else
        moveAnim(x, y):with(view):start()
    end
end

--延时回调--
local function performWithDelay(callback, delay)
    if callback ~= nil and delay ~= nil then
        local timer = Timer()
        timer:interval(delay)
        timer:repeatCount(false)
        timer:delay(delay / 1000)
        timer:callback(callback)
        timer:start()
        return timer
    end
end

local function getScrollViewLocation(data)
    if (data == nil) then
        return 0, 0, 0, 0
    end
    local contentDataTable = data.data
    if (contentDataTable == nil) then
        return 0, 0, 0, 0
    end

    --现在服务器不传位置，固定位置显示
    contentDataTable.width = 0.354
    contentDataTable.ratio = 0.66
    contentDataTable.positionX = 0.0
    contentDataTable.positionY = 0.17

    local screenWidth, screenHeight = System.screenSize()
    local width = 0
    local height = 0
    local x = 0
    local y = 0
    local scaleWidth = contentDataTable.width
    if (scaleWidth ~= nil) then
        width = math.max(screenWidth, screenHeight) * scaleWidth
    end
    --忽略服务器长宽比，采用设计高
    height = math.min(screenWidth, screenHeight) * 247.0 / 375.0
    local scaleX = contentDataTable.positionX
    if (scaleX ~= nil) then
        x = math.max(screenWidth, screenHeight) * scaleX
    end
    local scaleY = contentDataTable.positionY
    if (scaleY ~= nil) then
        y = math.min(screenWidth, screenHeight) * scaleY
    end
    bubble.x = x
    bubble.y = y
    bubble.width = width
    bubble.height = height
    bubble.scale = width / 236.5
    bubble.textDefaultWidth = 141 * bubble.scale
    return x, y, width, height
end

local function createUserTypeLeftWithMessageText(data, index) --左边用户云泡 显示问题
    if (index ~= bubbleIndex + 1) then
        return nil
    end
    local userParent = View()

    local icon = Image(Native)
    icon:image("os_bubble_item_icon_bg")
    icon:placeHolderImage("os_bubble_item_icon_bg")
    icon:frame(0, 18 * bubble.scale, 32 * bubble.scale, 32 * bubble.scale)
    icon:cornerRadius(2.0)

    local nameView = Label(Native)
    nameView:margin(37 * bubble.scale, 17 * bubble.scale, 0, 0)
    nameView:textColor(0xFFFFFF)
    nameView:textSize(12)

    local message = Label(Native)
    message:margin(37 * bubble.scale, 39 * bubble.scale, 41 * bubble.scale, 0)
    message:maxLines(100)
    message:textColor(0x1E1F23)
    message:textSize(12)
    message:backgroundColor("os_message_left_bg")
    message:anchorPoint(0, 0)
    message:scale(0)
    userParent:onLayout(function()
        message:backgroundColor(0xFFFFFF)
        message:backgroundColor("os_message_left_bg")
    end)
    startViewScaleAnim(message, bubbleAnimScale, {
        onStart = function()
        end,
        onCancel = function()
        end,
        onEnd = function()
            startViewScaleAnim(message, 1.0)
        end,
        onPause = function()
        end,
        onResume = function()
        end,
    })
    local avatar = data.avatar
    if (avatar ~= nil) then
        icon:image(avatar)
    end
    local name = data.name
    if (name ~= nil) then
        nameView:text(name)
        if nameView.textShadow then
            nameView:textShadow(0x666666, 5)
        end
    end
    local content = data.content
    if (content ~= nil) then
        message:text(content)
    end
    local marginView = View()
    marginView:margin(bubble.scrollviewWidth, 0, 0, 0)
    userParent:addView(marginView)
    userParent:addView(icon)
    userParent:addView(nameView)
    userParent:addView(message)
    bubbleIndex = bubbleIndex + 1

    userParent:onClick(function()
        createNextBubbleMessage(bubble.messagesTable)
    end)
    return userParent
end

local function createUserTypeLeftWithMessageTextIOS(data, index) --左边用户云泡 显示问题
    if (index ~= bubbleIndex + 1) then
        return nil
    end
    local userParent = ThroughView()
    userParent:frame(0, 0, bubble.scrollviewWidth, bubble.height * 0.5)

    local icon = Image(Native)
    icon:cornerRadius(2.0)
    icon:placeHolderImage("os_bubble_image_default")
    icon:stretch(5, 5)
    icon:frame(0, 18 * bubble.scale, 32 * bubble.scale, 32 * bubble.scale)

    local nameView = Label(Native)
    nameView:frame(37 * bubble.scale, 17 * bubble.scale, bubble.scrollviewWidth - 37 * bubble.scale, 20 * bubble.scale)
    nameView:textColor(0xFFFFFF)
    nameView:textSize(12)

    local messageBackground = ThroughView()
    --messageBackground:backgroundColor(0x0000FF)
    messageBackground:anchorPoint(0, 0)
    userParent:addView(messageBackground)

    local messageBubbleImage = Image(Native)
    messageBubbleImage:placeHolderImage("os_message_left_bg")
    messageBubbleImage:image("os_message_left_bg")
    messageBubbleImage:stretch(22, 16)
    messageBubbleImage:scaleType(ScaleType.FIT_XY)
    messageBackground:addView(messageBubbleImage)

    local message = Label(Native)
    message:frame(37 * bubble.scale, 39 * bubble.scale, 41 * bubble.scale, 0)
    message:lines(0)
    message:textColor(0x1E1F23)
    message:textSize(12)
    messageBackground:addView(message)

    local content = data.content
    if (content ~= nil) then
        message:text(content)
    else
        return nil
    end

    textWidth, textHeight = Native:stringSizeWithWidth(message:text(), bubble.textDefaultWidth, 12)
    message:frame(bubbleAngleWidth + bubbleImageSpace, bubbleImageSpace, textWidth, textHeight)
    messageBubbleImage:frame(0, 0, textWidth + bubbleImageSpace * 2 + bubbleAngleWidth, textHeight + bubbleImageSpace * 2)
    messageBackground:frame(37 * bubble.scale, 39 * bubble.scale, textWidth + bubbleImageSpace * 2 + bubbleAngleWidth, textHeight + bubbleImageSpace * 2)
    userParent:height(messageBackground:y() + messageBackground:height())

    messageBackground:scale(0)
    startViewScaleAnim(messageBackground, bubbleAnimScale, {
        onStart = function()
        end,
        onCancel = function()
        end,
        onEnd = function()
            startViewScaleAnim(messageBackground, 1.0)
        end,
        onPause = function()
        end,
        onResume = function()
        end,
    })
    local avatar = data.avatar
    if (avatar ~= nil) then
        icon:image(avatar)
    end
    local name = data.name
    if (name ~= nil) then
        nameView:text(name)
        if nameView.textShadow then
            nameView:textShadow(0x666666, 5)
        end
    end

    userParent:addView(icon)
    userParent:addView(nameView)
    userParent:addView(messageBackground)
    bubbleIndex = bubbleIndex + 1
    return userParent
end

local function createUserTypeLeftWithMessageImage(data, index) --左边用户云泡 显示问题
    if (index ~= bubbleIndex + 1) then
        return nil
    end
    local userParent = View()

    local icon = Image(Native)
    icon:image("os_bubble_item_icon_bg")
    icon:placeHolderImage("os_bubble_item_icon_bg")
    icon:frame(0, 18 * bubble.scale, 32 * bubble.scale, 32 * bubble.scale)
    icon:cornerRadius(2.0)

    local nameView = Label(Native)
    nameView:margin(37 * bubble.scale, 17 * bubble.scale, 0, 0)
    nameView:textColor(0xFFFFFF)
    nameView:textSize(12)

    local prompt = Image(Native)
    prompt:size(33 * bubble.scale, 33 * bubble.scale)
    prompt:image(OS_ICON_BUBBLE_PROMPT_LEFT)
    prompt:scaleType(ScaleType.FIT_CENTER)
    prompt:hide()

    local message = Image(Native)
    message:image("os_bubble_item_bg")
    message:placeHolderImage("os_bubble_item_bg")
    message:cornerRadius(13.0)

    local messageWidth = 141 * bubble.scale
    local messageHeight
    local aspectRatio = data.aspectRatio
    if (aspectRatio == nil) then
        aspectRatio = 2.5
    end

    local content = data.content
    if (content ~= nil) then
        local dataWidth = content.width
        if dataWidth < messageWidth then
            messageWidth = dataWidth
        end
        aspectRatio = content.width * 1.0 / content.height
    end

    messageHeight = messageWidth / aspectRatio
    message:frame(37 * bubble.scale, 39 * bubble.scale, messageWidth, messageHeight)

    local promptTop = messageHeight * 0.85 + 39 * bubble.scale
    -- prompt:margin(162 * bubble.scale, promptTop, 0, 0)

    local promptTop = message:y() + message:height() - 17 * bubble.scale
    prompt:xy(message:x() + message:width() - 17 * bubble.scale, promptTop)

    if data.link ~= nil and string.match(tostring(data.link), "http") == "http" then
        performWithDelay(function()
            prompt:show()
            startViewMoveAnim(prompt, -prompt:width() * 0.3, -prompt:height() * 0.3, nil)
        end, promptShowTime)
        message:onClick(function()
            clickView(data.link, data.id)
            prompt:hide()
        end)
    end
    userParent:addView(icon)
    userParent:addView(nameView)
    userParent:addView(message)
    userParent:addView(prompt)
    local avatar = data.avatar
    if (avatar ~= nil) then
        icon:image(avatar)
    end
    local name = data.name
    if (name ~= nil) then
        nameView:text(name)
        if nameView.textShadow then
            nameView:textShadow(0x666666, 5)
        end
    end
    local contentImageUrl = data.content.fileUrl
    if (contentImageUrl ~= nil) then
        message:image(contentImageUrl, function(status)
            if status == true then
            end
        end)
    end
    bubbleIndex = bubbleIndex + 1
    userParent:frame(0, 0, bubble.scrollviewWidth, 52 * bubble.scale + messageHeight)

    message:anchorPoint(0, 0)
    message:scale(0)
    startViewScaleAnim(message, bubbleAnimScale, {
        onStart = function()
        end,
        onEnd = function()
            startViewScaleAnim(message, 1.0, {
                onEnd = function()
                end
            })
        end,
    })
    userParent:onClick(function()
        createNextBubbleMessage(bubble.messagesTable)
    end)
    return userParent
end

local function createUserTypeLeftWithMessageImageIOS(data, index) --左边用户云泡 显示问题
    if (index ~= bubbleIndex + 1) then
        return nil
    end
    local userParent = ThroughView()
    userParent:frame(0, 0, bubble.scrollviewWidth, bubble.height * 0.5)

    local icon = Image(Native)
    icon:placeHolderImage("os_bubble_image_default")
    icon:stretch(5, 5)
    icon:frame(0, 18 * bubble.scale, 32 * bubble.scale, 32 * bubble.scale)
    icon:cornerRadius(2.0)

    local nameView = Label(Native)
    nameView:frame(37 * bubble.scale, 17 * bubble.scale, bubble.width - 37 * bubble.scale, 20 * bubble.scale)
    nameView:textColor(0xFFFFFF)
    nameView:textSize(12)

    local prompt = Image(Native)
    prompt:size(33 * bubble.scale, 30 * bubble.scale)
    prompt:placeHolderImage("os_bubble_prompt")
    prompt:image(OS_ICON_BUBBLE_PROMPT_LEFT)
    prompt:hide()

    local message = Image(Native)
    message:placeHolderImage("os_bubble_image_default")
    message:stretch(5, 5)
    message:anchorPoint(0, 0)
    message:cornerRadius(13.0)

    local messageWidth = 141 * bubble.scale
    local messageHeight
    local aspectRatio = data.aspectRatio
    if (aspectRatio == nil) then
        aspectRatio = 2.5
    end

    local content = data.content
    if (content ~= nil) then
        local dataWidth = content.width
        if dataWidth < messageWidth then
            messageWidth = dataWidth
        end
        aspectRatio = content.width * 1.0 / content.height
    end

    messageHeight = messageWidth / aspectRatio
    message:frame(37 * bubble.scale, 39 * bubble.scale, messageWidth, messageHeight)
    local promptTop = message:y() + message:height() - 17 * bubble.scale
    prompt:xy(message:x() + message:width() - 17 * bubble.scale, promptTop)
    userParent:frame(0, 0, bubble.width, prompt:y() + prompt:height())

    if data.link ~= nil and string.match(tostring(data.link), "http") == "http" then
        performWithDelay(function()
            prompt:show()
            startViewMoveAnim(prompt, -prompt:width() * 0.3, -prompt:height() * 0.3, nil)
        end, promptShowTime)
        message:onClick(function()
            clickView(data.link, data.id)
            prompt:hide()
        end)
    end

    message:scale(0)
    startViewScaleAnim(message, bubbleAnimScale, {
        onEnd = function()
            startViewScaleAnim(message, 1.0)
        end,
    })

    userParent:addView(icon)
    userParent:addView(nameView)
    userParent:addView(message)
    userParent:addView(prompt)

    local avatar = data.avatar
    if (avatar ~= nil) then
        icon:image(avatar)
    end
    local name = data.name
    if (name ~= nil) then
        nameView:text(name)
        if nameView.textShadow then
            nameView:textShadow(0x666666, 5)
        end
    end
    local contentImageUrl = data.content.fileUrl
    if (contentImageUrl ~= nil) then
        message:image(contentImageUrl, function(status)
            if status == true then
            end
        end)
    end
    bubbleIndex = bubbleIndex + 1
    return userParent
end

local function createUserTypeRightWithMessageText(data, index) --左边用户云泡 显示问题
    if (index ~= bubbleIndex + 1) then
        return nil
    end
    local userParent = View()

    local message = Label(Native)
    message:textColor(0xFFFFFF)
    message:margin(76 * bubble.scale, 19 * bubble.scale, 0, 0)
    message:maxLines(100)
    message:textSize(12)
    message:align(Align.RIGHT)

    message:backgroundColor("os_message_right_bg")
    message:anchorPoint(bubble.width, 40)
    message:scale(0)
    userParent:onLayout(function()
        message:backgroundColor(0xFFFFFF)
        message:backgroundColor("os_message_right_bg")
    end)
    startViewScaleAnim(message, bubbleAnimScale, {
        onStart = function()
        end,
        onCancel = function()
        end,
        onEnd = function()
            startViewScaleAnim(message, 1.0)
        end,
        onPause = function()
        end,
        onResume = function()
        end,
    })
    userParent:addView(message)
    if (data ~= nil) then
        local content = data.content
        if (content ~= nil) then
            message:text(content)
        end
    end
    bubbleIndex = bubbleIndex + 1
    userParent:onClick(function()
        createNextBubbleMessage(bubble.messagesTable)
    end)
    return userParent
end

local function createUserTypeRightWithMessageTextIOS(data, index) --左边用户云泡 显示问题
    if (index ~= bubbleIndex + 1) then
        return nil
    end

    local userParent = View()
    userParent:frame(0, 0, bubble.scrollviewWidth, bubble.height * 0.5)

    local messageBackground = ThroughView()
    messageBackground:anchorPoint(1, 0)
    userParent:addView(messageBackground)

    local messageBubbleImage = Image(Native)
    messageBubbleImage:placeHolderImage("os_message_right_bg")
    messageBubbleImage:image("os_message_right_bg")
    messageBubbleImage:stretch(16, 16)
    messageBubbleImage:scaleType(ScaleType.FIT_XY)
    messageBackground:addView(messageBubbleImage)

    local message = Label(Native)
    message:frame(5 * bubble.scale, 19 * bubble.scale, 41 * bubble.scale, 0)
    message:lines(0)
    message:textColor(0xFFFFFF)
    message:textSize(12)
    messageBackground:addView(message)

    local content = data.content
    if (content ~= nil) then
        message:text(content)
    else
        return nil
    end

    textWidth, textHeight = Native:stringSizeWithWidth(message:text(), bubble.textDefaultWidth, 12)
    message:frame(bubbleImageSpace, bubbleImageSpace, textWidth, textHeight)
    messageBubbleImage:frame(0, 0, textWidth + bubbleImageSpace * 2 + bubbleAngleWidth, textHeight + bubbleImageSpace * 2)
    messageBackground:frame(bubble.scrollviewWidth - messageBubbleImage:width(), 19, messageBubbleImage:width(), messageBubbleImage:height())
    userParent:height(messageBackground:y() + messageBackground:height())

    messageBackground:scale(0)
    startViewScaleAnim(messageBackground, bubbleAnimScale, {
        onStart = function()
        end,
        onCancel = function()
        end,
        onEnd = function()
            startViewScaleAnim(messageBackground, 1.0)
        end,
        onPause = function()
        end,
        onResume = function()
        end,
    })

    if (data ~= nil) then
        local content = data.content
        if (content ~= nil) then
            message:text(content)
        end
    end
    bubbleIndex = bubbleIndex + 1
    return userParent
end

local function createUserTypeRightWithMessageImage(data, index) --左边用户云泡 显示问题
    if (index ~= bubbleIndex + 1) then
        return nil
    end
    local userParent = View()
    local prompt = Image(Native)
    prompt:size(33 * bubble.scale, 33 * bubble.scale)
    prompt:scaleType(ScaleType.FIT_CENTER)
    prompt:image(OS_ICON_BUBBLE_PROMPT_RIGHT)
    prompt:hide()

    local message = Image(Native)
    message:align(Align.RIGHT)
    message:image("os_bubble_item_bg")
    message:placeHolderImage("os_bubble_item_bg")
    message:cornerRadius(13.0)
    local messageWidth = 141 * bubble.scale
    local messageHeight
    local aspectRatio = data.aspectRatio
    if (aspectRatio == nil) then
        aspectRatio = 2.5
    end

    local content = data.content
    if (content ~= nil) then
        local dataWidth = content.width
        if dataWidth < messageWidth then
            messageWidth = dataWidth
        end
        aspectRatio = content.width * 1.0 / content.height
    end

    messageHeight = messageWidth / aspectRatio
    local promptTop = messageHeight * 0.85 + 19 * bubble.scale
    prompt:margin(70 * bubble.scale, promptTop, 0, 0)
    message:size(messageWidth, messageHeight)
    message:margin(86 * bubble.scale, 19 * bubble.scale, 0, 0)
    if data.link ~= nil and string.match(tostring(data.link), "http") == "http" then
        performWithDelay(function()
            prompt:show()
            startViewMoveAnim(prompt, prompt:width() * 0.3, -prompt:height() * 0.3, nil)
        end, promptShowTime)
        message:onClick(function()
            clickView(data.link, data.id)
            prompt:hide()
        end)
    end
    if (data ~= nil) then
        local contentImageUrl = data.content.fileUrl
        if (contentImageUrl ~= nil) then
            message:image(contentImageUrl, function(status)
                if status == true then
                end
            end)
        end
    end
    userParent:addView(message)
    userParent:addView(prompt)
    bubbleIndex = bubbleIndex + 1
    userParent:frame(0, 0, bubble.scrollviewWidth, 52 * bubble.scale + messageHeight)

    message:anchorPoint(bubble.width, -40)
    message:scale(0)
    startViewScaleAnim(message, bubbleAnimScale, {
        onStart = function()
        end,
        onCancel = function()
        end,
        onEnd = function()
            startViewScaleAnim(message, 1.0, {
                onEnd = function()
                end
            })
        end
    })
    userParent:onClick(function()
        createNextBubbleMessage(bubble.messagesTable)
    end)
    return userParent
end

local function createUserTypeRightWithMessageImageIOS(data, index) --左边用户云泡 显示问题
    if (index ~= bubbleIndex + 1) then
        return nil
    end

    local userParent = ThroughView()
    userParent:frame(0, 0, bubble.scrollviewWidth, bubble.height * 0.5)

    local prompt = Image(Native)
    prompt:size(33 * bubble.scale, 30 * bubble.scale)
    prompt:placeHolderImage("os_bubble_prompt")
    prompt:image(OS_ICON_BUBBLE_PROMPT_RIGHT)
    prompt:hide()

    local message = Image(Native)
    message:placeHolderImage("os_bubble_image_default")
    message:cornerRadius(13.0)
    local messageWidth = 141 * bubble.scale
    local messageHeight
    local aspectRatio = data.aspectRatio
    if (aspectRatio == nil) then
        aspectRatio = 2.5
    end

    local content = data.content
    if (content ~= nil) then
        local dataWidth = content.width
        if dataWidth < messageWidth then
            messageWidth = dataWidth
        end
        aspectRatio = content.width * 1.0 / content.height
    end

    messageHeight = messageWidth / aspectRatio

    message:size(messageWidth, messageHeight)
    --message:margin(86 * bubble.scale, 19 * bubble.scale, 0, 0)
    message:anchorPoint(1, 0)
    message:frame(bubble.scrollviewWidth - messageWidth, 19 * bubble.scale, messageWidth, messageHeight)

    local promptTop = message:y() + message:height() - 17 * bubble.scale
    prompt:xy(message:x() - 16 * bubble.scale, promptTop)

    userParent:height(prompt:y() + prompt:height())

    if data.link ~= nil and string.match(tostring(data.link), "http") == "http" then
        performWithDelay(function()
            prompt:show()
            startViewMoveAnim(prompt, prompt:width() * 0.3, -prompt:height() * 0.3, nil)
        end, promptShowTime)
        message:onClick(function()
            clickView(data.link, data.id)
            prompt:hide()
        end)
    end

    message:scale(0)
    startViewScaleAnim(message, bubbleAnimScale, {
        onStart = function()
        end,
        onCancel = function()
        end,
        onEnd = function()
            startViewScaleAnim(message, 1.0)
        end,
        onPause = function()
        end,
        onResume = function()
        end,
    })
    if (data ~= nil) then
        local contentImageUrl = data.content.fileUrl
        if (contentImageUrl ~= nil) then
            message:image(contentImageUrl, function(status)
                if status == true then
                end
            end)
        end
    end
    userParent:addView(message)
    userParent:addView(prompt)
    bubbleIndex = bubbleIndex + 1
    return userParent
end

local function createParent()
    local luaView
    if System.android() then
        luaView = View()
    else
        luaView = ThroughView()
    end
    local screenWidth, screenHeight = System.screenSize()
    luaView:frame(0, 0, screenWidth, screenHeight)
    return luaView
end

local function createScrollView(data)
    local scrollviewParent = View()
    scrollviewParent:frame(bubble.x, bubble.y, bubble.width, bubble.height)
    --scrollviewParent:backgroundColor(0xFF0000)

    local scrollview = ScrollView()

    scrollview:frame(17 * bubble.scale, 0, bubble.width - 17 * bubble.scale, bubble.height)
    bubble.scrollviewWidth = scrollview:width()
    scrollview:clipsToBounds(true)
    scrollview:masksToBounds(true)
    scrollview:contentSize(bubble.width, bubble.height * 2)
    if (System.android()) then
        scrollview:orientation(0)
    end
    --scrollview:backgroundColor(0x00FF00)
    scrollview:callback {
        Scrolling = function()
            --            print("=response=scrolling=");
        end,
        ScrollBegin = function()
            --            print("=response=ScrollBegin=");
        end,
        ScrollEnd = function()
            --            print("=response=ScrollEnd=");
        end
    };

    scrollviewParent:addView(scrollview)

    return scrollviewParent, scrollview
end

local function createBackView(data)
    local backView = Image(Native)
    backView:frame(bubble.x + bubble.width, bubble.y - 26 * bubble.scale, 26 * bubble.scale, 26 * bubble.scale)
    backView:placeHolderImage("os_bubble_back")
    backView:image(OS_ICON_CLOSE)
    backView:onClick(function()
        closeView()
    end)
    local isShowClose = data.data.isShowClose
    if isShowClose == true then
        backView:show()
    else
        backView:hide()
    end
    return backView
end

local function createAdvertisingView(data)
    local advertisingView = nil
    if (System:ios()) then
        advertisingView = ThroughView()
    else
        advertisingView = View()
    end

    local advertisingViewWidth = 48 * bubble.scale
    local advertisingViewHeight = 20 * bubble.scale
    advertisingView:frame(bubble.x + 17 * bubble.scale, bubble.y + bubble.height + 10 * bubble.scale, advertisingViewWidth, advertisingViewHeight)
    advertisingView:backgroundColor(0x020202, 0.5)

    local advertisingLabel = Label()
    advertisingLabel:frame(0, 0, advertisingViewWidth, advertisingViewHeight)
    advertisingLabel:text("广告")
    advertisingLabel:textAlign(TextAlign.CENTER)
    advertisingLabel:textColor(0xF4F4F4)
    advertisingView:addView(advertisingLabel)

    local isShowAds = data.data.isShowAds
    if isShowAds == true then
        advertisingView:show()
    else
        advertisingView:hide()
    end
    return advertisingView
end

local function getMessageType(messageData) --1左边 text 2.左图 .3.右 text 4.右图 5.选择器
    if (messageData == nil) then
        return -1
    end
    local userType = messageData.userType
    local messageType = messageData.messageType
    if (userType == nil or messageType == nil) then
        return -1
    end
    if (messageType == 3) then
        return 5
    end
    if (userType == 1 and messageType == 1) then
        return 1
    elseif (userType == 1 and messageType == 2) then
        return 2
    elseif (userType == 2 and messageType == 1) then
        return 3
    elseif (userType == 2 and messageType == 2) then
        return 4
    end
    return -1
end

local function delayTimeCount(type)
    if (type == 1) then
        delayTime = delayTime + 2500
    elseif (type == 2) then
        delayTime = delayTime + 3500
    elseif (type == 3) then
        delayTime = delayTime + 2500
    elseif (type == 4) then
        delayTime = delayTime + 3500
    elseif (type == 5) then
        delayTime = delayTime + 2500
    end
end

local function createBubbleOption(message, k)
    if (message == nil) then
        return nil
    end
    local type = getMessageType(message)
    local optionView
    if (type == 1) then
        if (System.ios()) then
            optionView = createUserTypeLeftWithMessageTextIOS(message, k)
        else
            optionView = createUserTypeLeftWithMessageText(message, k)
        end
    elseif (type == 2) then
        if (System.ios()) then
            optionView = createUserTypeLeftWithMessageImageIOS(message, k)
        else
            optionView = createUserTypeLeftWithMessageImage(message, k)
        end
    elseif (type == 3) then
        if (System.ios()) then
            optionView = createUserTypeRightWithMessageTextIOS(message, k)
        else
            optionView = createUserTypeRightWithMessageText(message, k)
        end
    elseif (type == 4) then
        if (System.ios()) then
            optionView = createUserTypeRightWithMessageImageIOS(message, k)
        else
            optionView = createUserTypeRightWithMessageImage(message, k)
        end
    elseif (type == 5) then
        optionView = createUserMessageSelect(message, k)
    end
    return optionView, type
end

local function createAllBubbleOption(messages)
    if (messages == nil) then
        return
    end
    local lastIndex
    for k, v in pairs(messages) do
        local optionView = createBubbleOption(v, k)
        if (optionView ~= nil) then
            bubble.views[bubbleIndex] = optionView
            bubble.scrollview:addView(optionView)
            bubble.scrollview:fullScroll(1)
        end
        lastIndex = k
    end

    if lastIndex ~= nil and lastIndex > 0 and messages[lastIndex].messageType == 3 then
        local buttonMessage = messages[lastIndex]
        if buttonMessage.messageButtons[1].inner_messages ~= nil and buttonMessage.messageButtons[1].inner_messages[1] ~= nil and buttonMessage.messageButtons[1].inner_messages[1].messageType == 2 then
            if (lastIndex + 1 == bubbleIndex + 1) then
                local leftBtnClickFunction = bubble.leftBtnClickFunction
                leftBtnClickFunction()
            end
        elseif buttonMessage.messageButtons[2].inner_messages ~= nil and buttonMessage.messageButtons[2].inner_messages[1] ~= nil and buttonMessage.messageButtons[2].inner_messages[1].messageType == 2 then
            if (lastIndex + 1 == bubbleIndex + 1) then
                local rightBtnClickFunction = bubble.rightBtnClickFunction
                rightBtnClickFunction()
            end
        end
    end
end

local function addBubbleOption(messages)
    if (messages == nil or table_leng(messages) <= 0) then
        return
    end
    print("LuaView addBubbleOption 11")
    local lastIndex
    loadBubbleCount = loadBubbleCount + 1
    if loadBubbleCount > totalBubbleCount then
        return
    end
    print("LuaView addBubbleOption 22")
    local data = messages[loadBubbleCount]
    local optionView, type = createBubbleOption(data, loadBubbleCount)
    if (optionView ~= nil) then
        bubble.views[bubbleIndex] = optionView
        bubble.scrollview:addView(optionView)
        bubble.scrollview:fullScroll(1)
    end
    print("LuaView addBubbleOption 33")
    bubble.loadTimer = performWithDelay(function()
        addBubbleOption(messages)
    end, data.duration * 1000)
    if (bubble.launchPlanId ~= nil and showlaunchPlanCount == 0) then
        if (type == 5 or linkUrl(messages[loadBubbleCount]) ~= nil) then
            showlaunchPlanCount = showlaunchPlanCount + 1
            osTrack(bubble.launchPlanId, 2, 2)
        end
    end
    if 1 == 1 then
        return
    end

    for k, v in pairs(messages) do
        performWithDelay(function()
            local optionView = createBubbleOption(v, k)
            if (optionView ~= nil) then
                bubble.views[bubbleIndex] = optionView
                bubble.scrollview:addView(optionView)
                bubble.scrollview:fullScroll(1)
            end
        end, delayTime)
        delayTimeCount(getMessageType(v))
        lastIndex = k
    end

    if lastIndex ~= nil and lastIndex > 0 and messages[lastIndex].messageType == 3 then
        local buttonMessage = messages[lastIndex]

        if buttonMessage.messageButtons[1].inner_messages ~= nil and buttonMessage.messageButtons[1].inner_messages[1] ~= nil and buttonMessage.messageButtons[1].inner_messages[1].messageType == 2 then
            performWithDelay(function()
                if (lastIndex + 1 == bubbleIndex + 1) then
                    local leftBtnClickFunction = bubble.leftBtnClickFunction
                    leftBtnClickFunction()
                end
            end, delayTime)
        elseif buttonMessage.messageButtons[2].inner_messages ~= nil and buttonMessage.messageButtons[2].inner_messages[1] ~= nil and buttonMessage.messageButtons[2].inner_messages[1].messageType == 2 then
            performWithDelay(function()
                if (lastIndex + 1 == bubbleIndex + 1) then
                    local rightBtnClickFunction = bubble.rightBtnClickFunction
                    rightBtnClickFunction()
                end
            end, delayTime)
        end
    end
end

local function showSelectButtonMessage(index, messages)

    bubbleIndex = index
    for i, view in pairs(bubble.views) do
        if i > bubbleIndex then
            view:removeFromSuper()
        end
    end

    if messages == nil then
        --外链屏蔽自动展开
        bubbleIndex = bubbleIndex + 1
        return
    end
    local sortMessages = {}
    for k, v in pairs(messages) do
        sortMessages[k + bubbleIndex] = v
    end

    delayTime = 0;
    bubble.buttonClick = true
    addBubbleOption(sortMessages)
end

function createUserMessageSelect(data, index) --左边用户云泡 显示问题
    if (index ~= bubbleIndex + 1) then
        return nil
    end

    local userParent = nil
    if (System.ios()) then
        userParent = ThroughView()
        userParent:frame(0, 0, bubble.scrollviewWidth, bubble.height * 0.5)
    else
        userParent = View()
    end

    local selectLeftView = GradientView()
    selectLeftView:frame(53 * scale, 18 * scale, 72 * scale, 24 * scale)
    selectLeftView:gradient(0xF7F7F7, 0xF4F4F4)
    selectLeftView:corner(12 * scale, 12 * scale, 12 * scale, 12 * scale, 12 * scale, 12 * scale, 12 * scale, 12 * scale)
    selectLeftView:stroke(1, 0x4A90E2)
    local selectLeftBtn = Label(Native)
    selectLeftBtn:frame(0, 0, 72 * scale, 24 * scale)
    selectLeftBtn:textAlign(TextAlign.CENTER)
    selectLeftBtn:textColor(0x1D84FD)
    selectLeftBtn:text(data.messageButtons[1].title)
    selectLeftBtn:cornerRadius(20)
    selectLeftBtn:textSize(12)
    selectLeftView:addView(selectLeftBtn)

    local selectRightView = GradientView()
    selectRightView:frame(135.7 * scale, 18 * scale, 72 * scale, 24 * scale)
    selectRightView:gradient(0xF7F7F7, 0xF4F4F4)
    selectRightView:corner(12 * scale, 12 * scale, 12 * scale, 12 * scale, 12 * scale, 12 * scale, 12 * scale, 12 * scale)
    selectRightView:stroke(1, 0x4A90E2)
    local selectRightBtn = Label(Native)
    selectRightBtn:frame(0, 0, 72 * scale, 24 * scale)
    selectRightBtn:textAlign(TextAlign.CENTER)
    selectRightBtn:textColor(0x1D84FD)
    selectRightBtn:text(data.messageButtons[2].title)
    selectRightBtn:textSize(12)
    selectRightView:addView(selectRightBtn)


    local leftBtnClickFunction = function()
        --TODO是否需要合并在一起，如果同时有数据怎么处理
        local linkUrl = linkUrl(data.messageButtons[1])
        if (linkUrl ~= nil) then
            clickView(linkUrl, data.id)
        end
    end
    bubble.leftBtnClickFunction = leftBtnClickFunction
    selectLeftBtn:onClick(leftBtnClickFunction)

    local rightBtnClickFunction = function()
        local linkUrl = linkUrl(data.messageButtons[2])
        if (linkUrl ~= nil) then
            clickView(linkUrl, data.id)
        end
    end
    bubble.rightBtnClickFunction = rightBtnClickFunction
    selectRightView:onClick(rightBtnClickFunction)

    if (System.ios()) then
        userParent:height(selectLeftView:y() + selectLeftView:height())
    else
        local marginView = View()
        marginView:margin(bubble.scrollviewWidth, 0, 0, 0)
        userParent:addView(marginView)
    end

    userParent:addView(selectLeftView)
    userParent:addView(selectRightView)
    bubbleIndex = bubbleIndex + 1
    return userParent
end

local function registerMedia() --监听屏幕方向
    local mediaPausedStatus = false;
    -- body
    -- 注册window callback通知
    local callbackTable = {
        --0: 竖屏小屏幕，1 竖屏全凭，2 横屏全屏
        onPlayerSize = function(type)
            if (bubble.luaview == nil) then
                return
            end
            if (type == 0) then
                bubble.luaview:hide()
            elseif (type == 1) then
                bubble.luaview:hide()
            elseif (type == 2) then
                bubble.luaview:show()
            end
        end,
        onMediaPause = function()
            bubble.luaview:hide()
            bubble.loadTimer:cancel()
            mediaPausedStatus = true
        end,
        onMediaPlay = function()
            if (Native:isPortraitScreen() == false) then
                bubble.luaview:show()
            end
            if (mediaPausedStatus == false) then
                return
            end
            mediaPausedStatus = false
            createNextBubbleMessage(bubble.messagesTable)
        end,
        onMediaProgress = function(progress)
            if bubble.startProgress == nil then
                bubble.startProgress = progress
            end
            if progress - bubble.startProgress >= bubbleShowTime then
                closeView()
                return
            end
            -- if progress - bubble.startProgress >= bubbleShowAllTime then
            --     if (bubble.data == nil) then
            --         return
            --     end
            --     local messagesTable = getMessagesTable(bubble.data)
            --     if (messagesTable == nil) then
            --         return
            --     end
            --     if allBubbleIsCreate == false then
            --         allBubbleIsCreate = true
            --         createAllBubbleOption(messagesTable)
            --     end
            -- end
        end
    }
    local media = Media()
    media:mediaCallback(callbackTable)
    media:startVideoTime()
    return media
end

local function initLoadTime(data)
    print("LuaView initLoadTime")
    local messageData = data.data.messages[loadBubbleCount]
    bubble.loadTimer = performWithDelay(function()
        loadBubbleCount = loadBubbleCount + 1
        bubble.tableView:reload()
        performWithDelay(function()
            bubble.tableView:scrollToCell(1, loadBubbleCount)
        end, 100)
        if loadBubbleCount < totalBubbleCount then
            initLoadTime(data)
        end
    end, messageData.duration * 1000)
end

function itemClick(data)
    if loadBubbleCount >= totalBubbleCount then
        return
    end

    if bubble.loadTimer ~= nil then
        bubble.loadTimer:cancel()
        loadBubbleCount = loadBubbleCount + 1
        bubble.tableView:reload()
        performWithDelay(function()
            bubble.tableView:scrollToCell(1, loadBubbleCount)
        end, 100)
        if loadBubbleCount < totalBubbleCount then
            initLoadTime(data)
        end
    end
end

local function onCreate(data)
    local showLinkUrl = getHotspotExposureTrackLink(data, 1)
    if (showLinkUrl ~= nil) then
        Native:get(showLinkUrl)
    end
    if (bubble.launchPlanId ~= nil) then
        osTrack(bubble.launchPlanId, 1, 2)
    end
    getScrollViewLocation(data)
    bubble.luaview = createParent()
    performWithDelay(function()
        bubble.backview = createBackView(data)
        bubble.luaview:addView(bubble.backview)
    end, 5000)
    totalBubbleCount = table_leng(data.data.messages)
    bubble.scrollviewParent, bubble.scrollview = createScrollView(data)
    bubble.luaview:addView(bubble.scrollviewParent)
    bubble.advertisingView = createAdvertisingView(data)
    bubble.luaview:addView(bubble.advertisingView)

    local messagesTable = getMessagesTable(data)
    if (messagesTable == nil) then
        return
    end
    bubble.messagesTable = messagesTable
    addBubbleOption(messagesTable)
    bubble.scrollviewParent:onClick(function()
        print("LuaView scrollviewParent:onClick")
        createNextBubbleMessage(bubble.messagesTable)
    end)

    if (Native:isPortraitScreen()) then
        bubble.luaview:hide()
    end
end

function createNextBubbleMessage(messagesTable)
    if loadBubbleCount > totalBubbleCount then
        return
    end

    if bubble.loadTimer ~= nil then
        print("LuaView scrollviewParent:onClick")
        bubble.loadTimer:cancel()
        addBubbleOption(messagesTable)
    end
end

local function setBubbleTime(data)
    bubbleShowTime = data.duration
    if bubbleShowTime > 3000 then
        bubbleShowAllTime = bubbleShowTime - 3000
    end
end

function show(args)
    --第二次调用show方法时，直接return
    if (args == nil or bubble.luaview ~= nil) then
        return
    end
    showlaunchPlanCount = 0
    local dataTable = args.data
    if (dataTable == nil) then
        return
    end
    bubble.launchPlanId = dataTable.launchPlanId
    bubble.id = dataTable.id

    setBubbleTime(dataTable)
    Native:widgetEvent(eventTypeShow, bubble.id, bubble.id, adTypeBubble, "") --todo 修改参数为table
    Native:saveCacheData(bubble.id, tostring(eventTypeShow))
    bubble.data = dataTable
    bubble.media = registerMedia()
    bubble.window = registerWindow()
    onCreate(dataTable)
    checkMqttHotspotToSetClose(dataTable, function()
        closeView()
    end)
end