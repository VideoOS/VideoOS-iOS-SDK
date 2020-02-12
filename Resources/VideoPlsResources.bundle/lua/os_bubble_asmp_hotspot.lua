--
-- Create by bolo on 2019/11/6
--
--气泡贴--
require "os_config"
require "os_string"
require "os_constant"
require "os_util"
require "os_track"
bubble = object:new()
local CLOUD_ID_BUBBLE = "0012"
local CLOUD_ID_MIDDLE = "0014"
local adTypeName = "cloud"
local scale = getScale()
local OS_ICON_WEDGE_CLOSE = "iVBORw0KGgoAAAANSUhEUgAAAE8AAABPCAYAAACqNJiGAAAABHNCSVQICAgIfAhkiAAADc5JREFUeJzdnGtzFNcRhp/Rru5C3AwGDAZsjIIvEJOyq+KKU+Wq5Kfkl9r+wAdSYGIFLBOELXETEhK6X08+vN06s6OZ3dnVrCTcVacWLTOzc97py3tOd08SQvgX0A/82cYQMAVMA/8G7gA/AdvAVpIkgT+YhBCGgRPAReCvNs4jLIaB74EfgPvAa2AmSZKNOgJuAOgFakCP/bvPvh+ysQ4EYOvAZtVlCSEkQILmO4jm6VjUbfTYp2NSs3OoI23rBS4DJ+1k7EI7dsxJ4CnwNIQwD+y86xoYQuhBYPQBV4AvgOvAJwiLE0TAzgEfAUvIAueAdQevhgA6aQcPAWfQ0zgBvI/Mdx54izTwnQYPzXkAmeVlZKq3gNPAe8gie2ycR3NfBt4AT0BaNWQHDBBNdSD1I/12zFuEOMBcCGEB4F3TQNO4GnAMgXIO+NTGdTT3QTvGpd/GHrOdQuoJ0eZdBpA2Anxun6eAB+gp7IQQ3hkTNh/nCnIeuGljzP4eRJgkmVNXUKB4gZRoCztwmkZTTcsAQnzE/j4OjCIN/NXviXfHhB28YaRxN4F/ILd0EoGXBQ4awVtEfo86oiMDKDgM2sFuuj32dx9RA9eAZyj6vgReWhAJR1UDQwg1NNdBFBwuIzMdQ8AdJ/o4lxVgwcYE8D9kpfOkNO8O0ro6Cg79CKj+1IUS9LRqCPUl5DPu24UWEfjbFc65SnHffgIB9hUC7xL5wIHm+BswCYwjAKeQu9oF7ye78En0FIbs5BGkcYld2Pmef3fWLvIKqfR6CGE9SZIjA2CKxzlruAD8CfgagehzcuACUgCnI5PAPeAhMJkkyYv09et24DricXeQQ/TgcBJp3FDmnBN2UzeQGY8SeeASR8CEc3jcGALuc/TgB1GgTPu4DWDGxi8IuHsoLixlf6OOtCegyc8T6chx+6zRCF4vAm8Ygd5vf9eRBq6iB3LY/i/L475CGnfWRtqnu2ygoPALYhQO3qqNBqmbhmyZ039r359C2rSGgOgjLlFqqRs7n/reeWA/MH9YPLAFjxtDGudLMJc1FCBeAY8RcOPAk6yppqWe+vcO0pY5O3kORdUlpNonbKTJ4zDRJ24gPzkO/GzjMHig065LwG0b14Crdn91GucAWjU8tuHaNkW0wlzZBc8mGExjlhGPW0dP8Cwx4qZJtDvcYbtpX9LNA4+ILuEgwetlL497z74bLDhngUbg7iVJMt/qh+oF3+/Y50siHbmBwDzP3iBSQ0/1LHrKC/b9NDAdQpili0HEeFyvjY/tXj9Fi/xR5Eqy2raKNGsOWcs9+3yBrKil7AEvSZIQQnATfkmkI2t2E758yYJ3zP7fqcpx4K6dN093g0g6OFwDvkXgnSeClw0Oq+jhPkZ07R6ytiU6BQ8aTHgeEeDXdhO+TdNDJM0+Bolm4bs0q8CsXWMxhLBcJQ+04JAgrT+DzHMM7RR9krqnNI/bsPEK7Y78hPzzr0mSTLXz+0Vmu3t/yISdB9ZRVN1APm4EaVzal/QRqcsNYBMB/1/gcQhhnQr2Aw043+m4iDTtM/tNpyLZRf424nAv2Bsc9vC4VtIUPJvgtk34KdLAOeKTPmsTyAPvGAJ5GGnhit3kJtUEEV/kjyDwbgPfIZrlgSu7yHfwsjxuESlIW9JK83SXSbJtK4dVBNa43dw1oo9zNu9mDDIjn8AzpLXPgdlONxMsOHiAumjjFjLXy8SHmQ4QK0iz5ojAjaO161ySJKV8XFZKgef3jYCaRz5inhhVa+TzwKHUuV8iU3IOuEhnPLDXrnMGmeptBNxHxA2ObHBYIC7yXdueIDA79sGlwcvwwJ8RjwNF1ZN2rWOZ09I8MEEbD76Me2LH7NCeOI97D/m475DG+e/kyQKNwN1rtnIoK+1oXlp2EIWZRnRkFTnqDTQpB82lhkAOaKt7EZnXNDAVQnhLExPO4XHX0CL/BvJxTqHSksfjHthv7lmndiJtg5fhgdOIx82iQOAaBnvBG0Xmtk4087vIFy3TnAdmeZwnay4g8AbIJ8FZHjduv3c44EGDCc8i37eIwPHd5sBeHuja6BsNxxBoMwjQ5SwPtP24HmJ0P4M07hZaejmPSwO3YdfL8riJJEl+62S+RdKp2bp4EFlEPG4FRdUvkQZ6ziOthYPItGsIvH7gA+RDH4UQ1oh+0CPnVQTWLUR+P7RrZvfjQA/jKdr5dR/3jBaL/E5kX+ClNHAZmccUoiMDKDgEYtWBS1FSaQ059Q2i+WZ53D+Rxo5SnKxxOnKfCJ67hUplv5oH7PLAdeT3niMzqaPgsI5u3PfRipJKb+zzOfKhK0jDriGtu0ZMRjdL1owj4B4ijVtOkmSzinlmpRLwTDyIzCLwXiNzriGgfOIu2aTSJtLQX5DJvUTR9G80mqrX06QlnaxxbZtEYHYtp1IZeDmbCU+IW/THiKuCoqRSLyp1cHPuQzzuG2S26Y0HKE7WPADGkyR5VdXciqRKzXPxzQSIPHDZBhQnlUbt31sIwFm0cijicc2SNZVQkVZSOXgpHrhD3K2YQQA0Syp5VB5FK4YNpLEnkBbuK1nTDemG5u0mfWzlsIyCxge0TipBXHpBjKbpqOrgtJWs6YZ0BbyUuF9aRjzOo+omUdtG2bs6yKMgLnPINJ8Qte03usDjWklXwcvwwEfIqa8h8zxthw3ln10oczQuue6xz92RTqXbmgfs8sA15KeeIz81goLDKI27IXlat23HbiEKM4F43DSw2Ol+3H7lQMAzSfPACftuBAWH9KZpnmwjjXUS7eC9oWSyphtykOC5rCDt6UNAlpn8DvKTa4j4ztg11ml/P7AyORDwLFnjZbsfo+Lpz20cp7nWQczO1dCS7+923mOUVFrkEIrMD0rzEuJmwGXgL2hP7jSRHDcT38/rQzssnm4Ecb1lDqFCtavgZZI1V9Ey6wu0Vr1IBCSbHtxG5ujnO0H2fLD7zzdoF2cSJZW6WpmQlW5rXjpZc5NYdHOJ4mTNFvJtm8TK9LSkk0rLxDWxJ6UOrLjoIMDzFUPZohsHb41o7tmMXKviogMJIpWDV5CsGaN80c1LREcWkKlfR6aal1QqKi6abJVUqkK6oXl5yZqbaD+uTNHNhI0ZVM3ZR9SkssVF3q3T1QrVysBrUnTjjSJuqq2Kbh7aeIm09wwxkpYtLvqdgqRSlVIJeC2Kbi6Q31lTVHQzjaKo18f8aH8vU764aAntAzoPrKS4KCtVaV6zoptTNGqcS7Oimw1kqk+RH3xL1MIyxUV9yEVsUW1xUYPsC7ySRTde6uVSuugmVVw0iehI2eIiX855kfq+iouKZL+al+ZxnxGLbq4SeVw2srZTdOP7gZ5UKltcdAZp3TrVFBflShXgDRPB+46Y5dp30U1OZUI7xUWeH66iuChX2gYv1VmTV3TjneJFyZpOi248qdROcVEv+yguKiOdaJ4nb4ZRVP0W1QB7LUlecPDImc7kj1MyWZNJKk0iLfwd+U7ngWfI71QaQQCOoMh/B/ndZfbZbFgavExnzSVUaf4pevrXiBUBaf+TTtZMEDP5k+3mVQuSSt6ptIm00jt7skml94nkPd2xvmD1htudaGAp8HI6pG8Ti26cx+UV3eQla54RnX4nkk4qPUagzRP74I6zN4gUdaw/srHWSRApq3nZDul2im6yyZp9Fd2ULC4ayZxWtrioOvByOqSvIFNtp+jG6+MqLbppUVwUEJCtOta9uGgKdSq1xQNbaV62Q/pr5OO8eLps0c0E3UkPFhUXjRDXumWKix4gENvqWM8Fr0SHdHY/rlXRTaUVmS5NiosuEBsMyxQXgR54Wx3re8Br0iH9BY2dNWlpq0O6C5ItLirbse75kzH00NvqWM/TvPR+3BWkbdkO6eyS61CLbnKKi1Yo17HuxUW+cdBWx/oueE06pG+gJ+PON90hfWSKbnJ4IJTrWIcYpdvqWK/bD+a96eYWilwfEnlcNjgcmaKblLgJL1C+uGgA+T4vTu9BZP4RTd5c5JqX5XG3iG+6cdUuy+MOpejGJdVs6OBN0rq4yFOgnlg/hbBYosmbi+r24r1eGnncdYrfdONPMsvjpjjEopsc8fqWDXRvD+z7MaSFWR7oVQ2nkKIsElcuuW8u8nekDKJo+g1x69zf7pM11RX2vszAO6TbbrvslhR0KrlLcS06TWPVqbd5OQ3zd+fdtdHAA+to93cYPRFfr7bqkHbgxumgQ/qgpETHerrFoVlSaQmtYl4DqyGE1SRJduooNTiAlly+1Z1d5Bcla15wMDxuv1LUse6tDqdo1DhoTCpdQa5sBc35BbDm4PlrL08jIMt2SLs2Hmlp0rHeQ/Rx2VaFdFLpCpq/b2rMYuBdoPENZmU6pKfKvHfkqElOx/pD5LIWU4flJZWOETOBuy/u8oW/d+m00yH9rkq6Y/0RUo55ImB5SaUaMd25y3cdvB7ySXBXOqQPU5q8uegcxUmlOo0rrN13hn5vn+fQ6qIfmesK2koaJxZPH0hzyAFK+s1F3jh9xYa3fNWJ78fyMpAN7D9+QGh+hNS3HznU1+hVjxNI+yrrkD4KkvPmoruIjlxHwcHbtjzv+x9iAdIuePeRvXu7eh8xHE+h4PBOm2qRFPBAz6x5mcgA0rgJlLFbJfXay9fEndU39m/nQF6q9UcX54GrSGm2iZ3kvUgzZ4jABYAkhOC7rH5gYgfsNo4cpfeAdlMyCX1f7yZEPrvFEXil5x9C/g8Xlid2yMH3cQAAAABJRU5ErkJggg=="

local adsButtonWidth = 22 * scale
local adsButtonHeight = 9 * scale
local closeButtonSize = 22 * scale

local function widgetEvent(eventType, adID, adName, actionType, linkUrl, deepLink, selfLink)

    local actionString = ""
    if (linkUrl ~= nil and string.len(linkUrl) > 0) then
        actionString = linkUrl
    elseif (deepLink ~= nil and string.len(deepLink) > 0) then
        actionString = deepLink
    elseif (selfLink ~= nil and string.len(selfLink) > 0) then
        actionString = selfLink
    end

    if Native.widgetNotify then

        local notifyTable = {}

        notifyTable["eventType"] = eventType
        notifyTable["adID"] = adID
        notifyTable["adName"] = adName
        notifyTable["actionType"] = actionType
        notifyTable["actionString"] = actionString

        if (linkUrl ~= nil) then
            notifyTable["linkUrl"] = linkUrl
        end

        if (deepLink ~= nil) then
            notifyTable["deepLink"] = deepLink
        end

        if (selfLink ~= nil) then
            notifyTable["selfLink"] = selfLink
        end

        Native:widgetNotify(notifyTable)
    else
        Native:widgetEvent(eventType, adID, adName, actionType, actionString)
    end
end

local function delay()
    if (bubble.data == nil) then
        return
    end

    local duration = bubble.data.duration
    if (duration ~= nil) then
        bubble.timer = Timer()
        bubble.timer:delay(rounded(duration / 1000.0))
        bubble.timer:callback(function()
            widgetEvent(eventTypeClose, bubble.id, adTypeName, actionTypeNone, "")
            Native:destroyView()
        end)
        bubble.timer:start()
    end
end

local function getTagImage()
    if (bubble.data == nil) then
        return
    end
    local dataTable = bubble.data.data
    if (dataTable == nil) then
        return nil
    end
    return dataTable.imageUrl
end

local function getLinkUrl()
    if (bubble.data == nil) then
        return nil
    end
    local dataTable = bubble.data.data
    if (dataTable == nil) then
        return nil
    end
    local link = dataTable.linkUrl
    if (link ~= nil and string.match(tostring(link), "http") == "http") then
        return link
    else
        return nil
    end
end

local function exposureTrack()
    if (bubble.data == nil) then
        return
    end

    if (bubble.data.launchPlanId ~= nil) then
        osTrack(bubble.data.launchPlanId, 1, 2)
        if (getLinkUrl(data) ~= nil) then
            osTrack(bubble.data.launchPlanId, 2, 2)
        end
    end

    local hotspotTrackLinkTable = bubble.data.hotspotTrackLink
    if (hotspotTrackLinkTable == nil) then
        return
    end

    for i, v in ipairs(hotspotTrackLinkTable) do
        local showLinkUrl = v.exposureTrackLink
        if (showLinkUrl ~= nil) then
            -- print("luaView showLinkUrl " .. tostring(showLinkUrl))
            Native:get(showLinkUrl)
        end
    end
end

local function clickTrack()
    if (bubble.data == nil) then
        return
    end

    if (bubble.data.launchPlanId ~= nil) then
        osTrack(bubble.data.launchPlanId, 3, 2)
    end

    local hotspotTrackLinkTable = bubble.data.hotspotTrackLink
    if (hotspotTrackLinkTable == nil) then
        return nil
    end

    for i, v in ipairs(hotspotTrackLinkTable) do
        local clickLinkUrl = v.clickTrackLink
        -- print("luaView clickLinkUrl " .. tostring(clickLinkUrl))
        if (clickLinkUrl ~= nil) then
            Native:get(clickLinkUrl)
        end
    end
end

local function getVideoSize(isPortrait)
    local videoWidth, videoHeight
    local screenWidth, screenHeight = Native:getVideoSize(2)
    if (isPortrait) then
        videoWidth, videoHeight = Native:getVideoSize(0)
    else
        videoWidth = math.max(screenWidth, screenHeight)
        videoHeight = math.min(screenWidth, screenHeight)
    end
    return videoWidth, videoHeight;
end

local function setLuaViewSize(luaview, isPortrait) --设置当前容器大小
    if (luaview == nil) then
        return
    end
    local screenWidth, screenHeight = Native:getVideoSize(2)
    if (isPortrait) then
        local videoWidth, videoHight, y = Native:getVideoSize(0)
        if System.android() then
            y = 0.0
        end
        luaview:frame(0, y, math.min(screenWidth, screenHeight), videoHight)
    else
        luaview:frame(0, 0, math.max(screenWidth, screenHeight), math.min(screenWidth, screenHeight))
    end
    luaview:alignRight()
end

local function setUpSideParentSize(isPortrait)
    local videoWidth, videoHeight = getVideoSize(isPortrait)
    local width = 200 * scale
    local height = 226 * scale
    bubble.sideParent:size(width, height)
    bubble.sideParent:align(Align.V_CENTER)
    bubble.sideParent:x(videoWidth - width - 15 * scale)
end

--屏幕旋转--
local function rotationScreen(isPortrait)
    if (bubble.luaView == nil) then
        return
    end
    if (isPortrait) then
        if (bubble.luaView:isShow()) then
            bubble.luaView:hide()
        end
    else
        if (bubble.luaView:isHide()) then
            bubble.luaView:show()
            setLuaViewSize(bubble.luaView, isPortrait)
            setUpSideParentSize(isPortrait)
        end
    end
end

local function setUpCloseAndAdsSize()
    bubble.closeView:align(Align.RIGHT)
    bubble.adsBtn:align(Align.BOTTOM)
end

local function registerMedia()
    local media = Media()
    -- body
    -- 注册window callback通知
    local callbackTable = {
        --0: 竖屏小屏幕，1 竖屏全凭，2 横屏全屏
        onPlayerSize = function(type)
            if (type == 0) then
                rotationScreen(true)
            elseif (type == 1) then
                rotationScreen(true)
            elseif (type == 2) then
                rotationScreen(false)
            end
        end
    }
    media:mediaCallback(callbackTable)
    return media
end

local function startAnimation()
    Animation():alpha(1.0):duration(2.0):with(bubble.sideParent):start()
end

local function createAdsButton() --创建底部'广告'标识
    local view = GradientView()
    view:backgroundColor(0x000000, 0.5)
    view:size(adsButtonWidth, adsButtonHeight)
    view:corner(0, 0, 0, 0, 0, 0, 8 * scale, 8 * scale)
    local adsLabel = Label()
    adsLabel:size(adsButtonWidth, adsButtonHeight)
    adsLabel:textSize(7)
    adsLabel:textAlign(TextAlign.CENTER)
    adsLabel:textColor(0x9B9B9B)
    adsLabel:text("广告")
    view:addView(adsLabel)
    return view
end

local function createCloseButton()
    local closeView = View()
    closeView:size(closeButtonSize, closeButtonSize)
    local closeImage = Image(Native)
    closeImage:size(closeButtonSize / 2, closeButtonSize / 2)
    closeImage:align(Align.CENTER)
    closeImage:image(Data(OS_ICON_WEDGE_CLOSE))
    closeView:addView(closeImage)
    return closeView
end

local function createSideParent(isPortrait)
    local sideParent = View()
    sideParent:backgroundColor(0x000000, 0.8)
    sideParent:cornerRadius(8 * scale)
    bubble.sideParent = sideParent
    setUpSideParentSize(isPortrait)
    sideParent:alpha(0)
    return sideParent
end

local function createLuaView(isPortrait)
    local luaView
    if System.android() then
        luaView = View()
    else
        luaView = ThroughView()
    end
    setLuaViewSize(luaView, isPortrait)
    return luaView
end

local function createCloudImage()
    local image = Image(Native)
    image:scaleType(ScaleType.FIX_XY)
    local radii = 8 * scale
    if (System.android()) then
        print("createCloudImage hasMethod:::"..tostring(image.cornerRadii))
        if (image.cornerRadii) then
            image:cornerRadii(radii, radii, radii, radii, 0, 0, 0, 0)
        else
            image:cornerRadius(radii)
        end
    end
    local imageUrl = getTagImage()
    if (imageUrl == nil) then
        return
    end
    image:image(imageUrl, function(status, width, height)
        print("image display status:" .. tostring(status))
        if (status) then
            local isPortrait = Native:isPortraitScreen()
            rotationScreen(isPortrait)
            -- 曝光统计
            exposureTrack()
        end
    end)
    bubble.sideParent:addView(image)
    image:size(200 * scale, 122.3 * scale)
end

local function createDesc()
    local desc = Label()
    desc:textColor(0x8E9091)
    desc:textSize(11 * scale)
    desc:lineCount(3)
    desc:ellipsize(Ellipsize.END)
    local descData = Native:decode(bubble.data.desc)
    desc:text(descData)
    bubble.sideParent:addView(desc)
    desc:frame(9 * scale, 143 * scale, 185 * scale, 60 * scale)
end

local function createDetailAction(closeEvent)
    local detail = Label()
    detail:textColor(0xFFF5A623)
    detail:textSize(12 * scale)
    detail:borderColor(0x3a3737)
    detail:borderWidth(1 * scale)
    detail:text("查看详情")
    detail:cornerRadius(2 * scale)
    if (System.android()) then
        detail:gravity(Gravity.CENTER)
    else
        detail:textAlign(TextAlign.CENTER)
    end
    bubble.sideParent:addView(detail)
    detail:frame(136 * scale, 202 * scale, 55 * scale, 21 * scale)
    detail:onClick(closeEvent)
end

local function createTitle()
    local title = Label()
    title:textColor(0xffffff)
    title:textSize(15 * scale)
    local slogan = Native:decode(bubble.data.slogan)
    title:text(slogan)
    title:lineCount(1)
    title:ellipsize(Ellipsize.END)
    bubble.sideParent:addView(title)
    title:frame(9 * scale, 128 * scale, 185 * scale, 20 * scale)
end

local function sendAction2SideBar(ext)
    bubble.timer:cancel()
    bubble.timer:callback(nil)
    if Native:getCacheData(bubble.id) == tostring(eventTypeShow) then
        widgetEvent(eventTypeClose, bubble.id, adTypeName, actionTypeNone, "")
        Native:deleteBatchCacheData({ bubble.id })
    end

    Native:destroyView()

    ext["linkUrl"] = bubble.data.data.linkData.linkUrl
    ext["deepLink"] = bubble.data.data.linkData.deepLink
    local template = "os_web_side_bar_asmp.lua"
    local id = CLOUD_ID_MIDDLE
    local miniAppId = bubble.data.data.miniAppId
    if (miniAppId == nil or string.len(miniAppId) == 0) then
        if (bubble.data.miniAppInfo ~= nil) then
            miniAppId = bubble.data.miniAppInfo.miniAppId
        end
    end
    if (miniAppId == nil) then
        Native:sendAction(Native:base64Encode("LuaView://defaultLuaView?template=" .. template ..
                "&id=" .. id .. "&priority=" .. tostring(osInfoViewPriority)), ext)
    else
        Native:sendAction(Native:base64Encode("LuaView://defaultLuaView?template=" .. template ..
                "&id=" .. id .. "&priority=" .. tostring(osInfoViewPriority) .. "&miniAppId=" ..
                miniAppId), ext)
    end
end

local function canOpenMiddle()
    return bubble.data.ext ~= nil and tonumber(bubble.data.ext.jump_type) == 2
            and bubble.data.ext.middle_page_url ~= nil
            and string.len(bubble.data.ext.middle_page_url) > 0
end

local function onCreate()
    local isPortrait = Native:isPortraitScreen()

    local closeCloud = function()
        if Native:getCacheData(bubble.id) == tostring(eventTypeShow) then
            widgetEvent(eventTypeClose, bubble.id, adTypeName, actionTypeNone, "")
            Native:deleteBatchCacheData({ bubble.id })
        end
        Native:destroyView()
    end

    local closeEvent = function()
        local linkData = bubble.data.data.linkData
        print("linkData::" .. Native:tableToJson(linkData))
        if (linkData == nil) then
            return
        end
        if ((linkData.linkUrl == nil or linkData.linkUrl == "")
                and (linkData.deepLink == nil or linkData.deepLink == "")
                and (linkData.selfLink == nil or linkData.selfLink == "")) then
            return
        end
        -- 点击统计
        clickTrack()

        if (Native:isPortraitScreen() or not canOpenMiddle()) then
            widgetEvent(eventTypeClick, bubble.id, adTypeName, actionTypeOpenUrl, linkData.linkUrl, linkData.deepLink, linkData.selfLink)
            closeCloud()
        else
            sendAction2SideBar(bubble.data.ext)
        end
    end

    bubble.luaView = createLuaView(isPortrait)
    bubble.sideParent = createSideParent(isPortrait)
    createCloudImage()
    createTitle()
    createDesc()
    createDetailAction(closeEvent)
    bubble.adsBtn = createAdsButton()
    bubble.closeView = createCloseButton()

    bubble.luaView:addView(bubble.sideParent)
    bubble.sideParent:addView(bubble.adsBtn)
    bubble.sideParent:addView(bubble.closeView)
    bubble.closeView:onClick(closeCloud)
    setUpCloseAndAdsSize()
    startAnimation()
    rotationScreen(isPortrait)
end

function show(args)
    if (args == nil) then
        return
    end

    bubble.data = args.data
    if (bubble.data == nil) then
        return
    end
    bubble.id = bubble.data.id .. CLOUD_ID_BUBBLE
    delay()
    widgetEvent(eventTypeShow, bubble.id, adTypeName, actionTypeNone, "")
    Native:saveCacheData(bubble.id, tostring(eventTypeShow))
    registerMedia()
    onCreate()
end