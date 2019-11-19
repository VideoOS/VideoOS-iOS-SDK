--
-- Created by Android studio 3.3.2.
-- Author: lucas
-- Date: 2019/7/2
--

require "os_config"
require "os_string"
require "os_constant"
require "os_util"
require "os_track"
baikeWindow = object:new()
local scale = getScale()
local OS_ICON_WEDGE_CLOSE = "iVBORw0KGgoAAAANSUhEUgAAACkAAAApCAYAAACoYAD2AAAABHNCSVQICAgIfAhkiAAABWJJREFUWIW9mf9vFFUUxT+vDtvdIiIiW0KFKAFCW74KGEpVwv9MoglNTBCIYqpUUkRFgRi+CKVUWlpo2b3+cO50p8O8mSlUb7IJ3Zn37tlz7333vEsgZ2Z2CtgPvAS+BhZDCJZ/723NzAJwHDgMLABXQggPit5NMoveBYaAQ8BHwBIwBkyZ2cxGAjWzBBjxz8fACjBvZiGEcL8QpAP8BDgBDANbgRdAC3gFTG8UUDMbQGR8BuwFtvujjj9fAdb4SpkccoBjmf2aiNFx//uSA34bgAFoA+eAg8DmzOO9wDsO9iJiVyA9Bw8hBousDZwEWmZ2CVh4E0Yd4LDvdQCRkLdBxLCZ2XQI4W8Qk/sRY1sj+zcR0w1UTNNm9mg9QM2s3/0cQwxuKfHV9h9xL/WTuOMllINFvw5gANgFnAG6QMfMntQBmsnBMRTSD0pef+VYFlHYA2B96Ji5BsxU+Esc6BhwBOVPFcDga86iUL9fsWQRuA18BdwNIXRTx4vAlP+KcUR3EaPBgQ0CnwINM/semCti1AEe8U+ag30lAJ8C14HvfM9e4YQQzMxmgGn/7iQKz0Bks5Y/70epciOfo2bWQuffCWAf8XwHkfPcAf4I3AkhdLIvJAAZoJccRAOFKUEM5i2bZysoGvMOsIGiMY4YLAPYQd3mDnAV+DMPkCIAZrYFOIWKZBfx3DPEwl/Az8AFVFT7gM/RsdYsWQ/wD/ALcB54FkJ4WfRSUvDdAgp9FzE1iNjNWwA2ATv93x1gGdiNGGwRz8EuMIdC/AMwW8RgFKSH/pE77UNFUpaj6fHUcJDvAdtiDhH784j9a0RCXAoyA/QJak8NVCRDDrooR9PnVdZFRXLX935YBZCIwzVmZttQpxhDjG2qASZmc8ANYAJ4HEJYrrOokMnIxiuoYncSD33MOsAzFOJJajJYG2QmRxdRz027SH9NH69QMf6KmsYf6wFYC2QKFInSC4iVBvVyENSL76BjprSKY1bWpoqsiyq4Vi65dVBn6qKzdd1WG6TLrRGk4KuEQtb6UR4fBXZ6T1+X1Qq39+I2EqQHKD8H89ZCOXwaMbmExERtq3MEBSRUxxGTZZ0kug0K9z1U3RMhhNpXkVImM3LrBPXkVsxSmddGZy5lMq82SFfUuxxkHbm1RK/yY+doE+XncdQab9W5ihSC9CIZQop6PXLrJbADiYyYzGv587OoqFZlXsyKpFoARlEbHKZabj1FB/V5lHfDwJfoclcl8+4DPyGZ14kxuobJzLXzGLo0VcmttNVNAbPu/HfU389QfhXZhFgfRakSHUBkxywD9O7YB6m+1T1HPX2STKvzFrqMQnkM5WCRHgXl7m56LbYQaDpmSVAOnkM5GLsXgxicR3JrgpxYcAdPzWzCvzruQGIyrwns8ecJcNnMXmSBBg/xYXRQj1Cdg7MoxBepkFsu80ZQkVTJvGWUo1PAN8Aq0MR/6QjKwc2xHehV8XWkqOvIrTngFgrnaZSDseMpvcCNup+bZvY4nWAcRtfP7ZHF0JNbN9GdpFLyw2syr98B7KZ8UjKE+vyMfyxx5yuRRak95w3lVk7mLTnYPSVL0ivGMq6aEuAKKoQOCnne0snCVXTtXLcedOvQG0D0odA2cu/MAr8B36J0EsgQwoOMfErHKE0U4kV6k4VaIY5ZblKSoLt9m16OzqJ0mkRTjFUBkk4w7vuEtYOqvI1CcxvNZl4bfbwl0MuIxVGUg13E4CQwnT8nV88tZzMBvkBn5SKabq0ZHm2Eua8mYvMoysGL5Bh8DWRmg0GkvDto/LahAHNAdwAfoiJ5GEJYKHq3UPT6BiGdD/5XlvoB7L/4b5j/1f4FpBs0xIw/x0gAAAAASUVORK5CYII="
local adTypeName = "BaikeWindow"





local function getWindowExposureTrackLink(data, index)
    if (data == nil or index == nil) then
        return nil
    end
    local infoTrackLinkTable = data.infoTrackLink
    if (infoTrackLinkTable == nil) then
        return nil
    end
    local indexInfoTrackLinkTable = infoTrackLinkTable[index]
    if (indexInfoTrackLinkTable == nil) then
        return nil
    end
    return indexInfoTrackLinkTable.exposureTrackLink
end

local function getWindowClickTrackLink(data, index)
    if (data == nil or index == nil) then
        return nil
    end
    local infoTrackLinkTable = data.infoTrackLink
    if (infoTrackLinkTable == nil) then
        return nil
    end
    local indexInfoTrackLinkTable = infoTrackLinkTable[index]
    if (indexInfoTrackLinkTable == nil) then
        return nil
    end
    return indexInfoTrackLinkTable.clickTrackLink
end



local function generateBannerSize(isPortrait)
    local x, y, w, h = 0, 0, 0, 0
    if (isPortrait) then
        y = baikeWindow.portraitHeight * 0.506
        w = math.ceil(baikeWindow.portraitWidth * 0.554)
        h = w / 1.77
    else
        y = baikeWindow.landscapeHeight * 0.541
        w = math.ceil(baikeWindow.landscapeWidth * 0.8)
        h = w / 1.77
    end
    return x, y, w, h
end
local function setBaikeDescSize(baikeDesc, isPortrait)
    if (isPortrait) then
        baikeDesc:textSize(14)
    else
        baikeDesc:textSize(12)
    end
end

local function setListSize(listView, isPortrait)
    if System.ios() then
        local textSize = 14
        if (isPortrait) then
            textSize = 14
            listView:frame(0, baikeWindow.portraitHeight * 0.178, baikeWindow.portraitWidth * 0.816, baikeWindow.portraitHeight * 0.243)
            local textWidth, textHeight = Native:stringSizeWithWidth(baikeWindow.baikeDesc:text(), baikeWindow.portraitWidth * 0.816, textSize)
            baikeWindow.baikeDesc:frame(0, 0, baikeWindow.portraitWidth * 0.816, textHeight)
            listView:contentSize(baikeWindow.portraitWidth * 0.816, textHeight)
        else
            textSize = 12
            listView:frame(0, baikeWindow.landscapeHeight * 0.186, baikeWindow.landscapeWidth * 0.8, baikeWindow.landscapeHeight * 0.28)
            local textWidth, textHeight = Native:stringSizeWithWidth(baikeWindow.baikeDesc:text(), baikeWindow.landscapeWidth * 0.8, textSize)
            baikeWindow.baikeDesc:frame(0, 0, baikeWindow.landscapeWidth * 0.8, textHeight)
            listView:contentSize(baikeWindow.landscapeWidth * 0.8, textHeight)
        end

    else
        if (isPortrait) then
            listView:frame(0, baikeWindow.portraitHeight * 0.178, baikeWindow.portraitWidth * 0.816, baikeWindow.portraitHeight * 0.243)
        else
            listView:frame(0, baikeWindow.landscapeHeight * 0.186, baikeWindow.landscapeWidth * 0.8, baikeWindow.landscapeHeight * 0.28)
        end
    end

    listView:align(Align.H_CENTER)
end

local function createListView(desc, isPortrait)
    if System.ios() then
        local textScrollView = ScrollView()
        -- textScrollView:backgroundColor(0x800080);

        local textLabel = Label()
        textLabel:textColor(0xFFFFFF)
        baikeWindow.baikeDesc = textLabel
        textLabel:text(desc)
        textLabel:lines(0)

        setBaikeDescSize(textLabel, isPortrait)
        setListSize(textScrollView, isPortrait)
        textScrollView:addView(textLabel)
        return textScrollView
    else
        local cv = CollectionView { --使用一个table来对CollectionView进行初始化
            Section = {
                SectionCount = function()
                    -- 返回页面区块的个数（不同区块的种类数）
                    return 1
                end,
                RowCount = function(section)
                    -- RowCount函数用于返回指定section中的row count,section 从0开始
                    return 1
                end
            },
            Cell = {
                Id = function(section, row)
                    -- 返回每个区块对应的坑位ID，这个ID用于在之后进行对应cell的行为设置
                    return "Label"

                end,
                Label = { -- ID为Label的cell的回调方法，Size为大小设置，Init为初始化方法，Layout为布局方法，Callback为点击回调方法
                    --Size = function(section, row)
                    --        return 0,0
                    --end,
                    Init = function(cell, section, row)
                        cell.title = Label()
                        baikeWindow.baikeDesc = cell.title
                        cell.title:textColor(0xFFFFFF)
                        if (System.android()) then
                            cell.title:maxLines(99)
                        end
                        setBaikeDescSize(cell.title, isPortrait)
                    end,
                    Layout = function(cell, section, row)
                        cell.title:text(desc)
                        -- ios 需要set title 的 frame

                    end
                }
            },
            Callback = {-- 整个CollectionView的事件回调
                Scrolling = function(firstVisibleSection, firstVisibleRow, visibleCellCount)
                    -- 滚动中回调
                end,
                ScrollBegin = function(firstVisibleSection, firstVisibleRow, visibleCellCount)
                    -- 滚动开始回调
                end,
                ScrollEnd = function(firstVisibleSection, firstVisibleRow, visibleCellCount)
                    -- 滚动结束回调
                end
            }
        }
        cv:showScrollIndicator(false)
        setListSize(cv, isPortrait)

        return cv
    end


end

local function createViewPager(urlList, framex, framey, framew, frameh)
    local bgView = View()
    bgView:frame(framex, framey, framew, (frameh + 22))
    local pageItems = {};

    local count = (urlList and #urlList) or 0
    for i = 1, count do
        local pageView = View()
        pageView:backgroundColor(0xA9A9A9, 1.0)
        if (i == 1) then
            pageView:backgroundColor(0xFFFFFF, 1.0)
        end
        local tempx = (framew - (count - 1) * 10 - count * 4) / 2
        pageView:frame((tempx + (i - 1) * 14), (frameh + 9), 4, 4)
        pageView:cornerRadius(2.0)
        bgView:addView(pageView)
        pageItems[i] = pageView
    end

    imageViews = {};
    baikeWindow.imageViews = imageViews
    scrollView = PagerView {
        PageCount = count,
        Pages = {
            Init = function(page, pos)
                page.image = Image(Native)
                if (System.android()) then
                    page.image:cornerRadius(6)
                end
                baikeWindow.imageViews[pos] = page.image
            end,
            Layout = function(page, pos)
                page.image:image(urlList[pos])
                local isPortrait = Native:isPortraitScreen()
                local x, y, w, h = generateBannerSize(isPortrait)
                page.image:frame(0, 0, w, h)
            end
        },
        Callback = {
            Scrolling = function(pageIndex, percent, offset)
            end,

            ScrollEnd = function(pageIndex)
                local PageCount = (baikeWindow.pageItems and #baikeWindow.pageItems) or 0
                for i = 1, PageCount do

                    local tempPageView = baikeWindow.pageItems[i]
                    tempPageView:backgroundColor(0xA9A9A9, 1.0)
                    if (i == pageIndex) then
                        tempPageView:backgroundColor(0xFFFFFF, 1.0)
                    end

                end

            end
        }
    };
    scrollView:frame(0, 0, framew, frameh)
    scrollView:cornerRadius(6.0)
    scrollView:autoScroll(2)

    local imageCount = (baikeWindow.imageViews and #baikeWindow.imageViews) or 0
    baikeWindow.pageItems = pageItems
    baikeWindow.bannerPagerScrollView = scrollView


    bgView:addView(scrollView)
    return bgView

end

local function refreshCollectionView()
    local collectionW, collectionH = baikeWindow.bannerPager:size();
    baikeWindow.bannerPager:size(collectionW, collectionH + 20)
    baikeWindow.bannerPagerScrollView:frame(0, 0, collectionW, collectionH)

    local pageItemCount = (baikeWindow.pageItems and #baikeWindow.pageItems) or 0
    for i = 1, pageItemCount do
        local tempx = (collectionW - (pageItemCount - 1) * 10 - pageItemCount * 4) / 2
        baikeWindow.pageItems[i]:frame((tempx + (i - 1) * 14), (collectionH + 9), 4, 4)
    end

    local imageCount = (baikeWindow.imageViews and #baikeWindow.imageViews) or 0
    for i = 1, imageCount do
        if (baikeWindow.imageViews[i] ~= nil) then
            baikeWindow.imageViews[i]:frame(0, 0, collectionW, collectionH)
        end
    end

    baikeWindow.bannerPager:align(Align.H_CENTER)

end

local function translationAnim(x, y)
    local anim = Animation():translation(x, y):duration(0.3)
    return anim
end

local function startViewTranslationAnim(view, x, y, table)
    if (view == nil) then
        return
    end
    if table ~= nil then
        translationAnim(x, y):with(view):callback(table):start()
    else
        translationAnim(x, y):with(view):start()
    end
end

local function closeView()
    Native:widgetEvent(eventTypeClose, baikeWindow.data.id, adTypeName, actionTypeNone, "")

    Native:destroyView()
end

local function closeViewByScreenDirection()
    local isPortrait = Native:isPortraitScreen()
    if (System.android()) then
        if (isPortrait) then
            startViewTranslationAnim(baikeWindow.baikeWindowView, 0, 438 * scale, {
                onCancel = function()
                    closeView()
                end,
                onEnd = function()
                    closeView()
                end,
                onPause = function()
                    closeView()
                end
            })
        else
            startViewTranslationAnim(baikeWindow.baikeWindowView, 200 * scale, 0, {
                onCancel = function()
                    closeView()
                end,
                onEnd = function()
                    closeView()
                end,
                onPause = function()
                    closeView()
                end
            })
        end
    else
        local screenWidth, screenHeight = Native:getVideoSize(2)
        if (isPortrait) then
            Animate(0.3,
                    function()
                        baikeWindow.baikeWindowView:y(math.max(screenWidth, screenHeight))
                    end,
                    function()
                        closeView()
                    end);
        else
            Animate(0.3,
                    function()
                        baikeWindow.baikeWindowView:x(math.max(screenWidth, screenHeight))
                    end,
                    function()
                        closeView()
                    end);
        end
    end


end

local function setLuaViewSize(luaview, isPortrait)
    --设置当前容器大小
    if (luaview == nil) then
        return
    end
    local screenWidth, screenHeight = Native:getVideoSize(2)
    if (isPortrait) then
        luaview:frame(0, 0, math.min(screenWidth, screenHeight), math.max(screenWidth, screenHeight))
    else
        luaview:frame(0, 0, math.max(screenWidth, screenHeight), math.min(screenWidth, screenHeight))
        if (System.android()) then
            luaview:align(Align.RIGHT)
        end
    end
end

local function setBaikeViewSize(data, baikeWindowView, isPortrait)
    --设置当前容器大小
    if (data == nil or baikeWindowView == nil) then
        return
    end
    local screenWidth, screenHeight = Native:getVideoSize(2)
    if (isPortrait) then
        if (System.android()) then
            baikeWindowView:frame(0, 0, baikeWindow.portraitWidth, baikeWindow.portraitHeight)
            baikeWindowView:align(Align.BOTTOM)
        else
            baikeWindowView:frame(0, math.max(screenWidth, screenHeight) - baikeWindow.portraitHeight, baikeWindow.portraitWidth, baikeWindow.portraitHeight)
            baikeWindowView:align(Align.BOTTOM)
        end
    else
        if (System.android()) then
            baikeWindowView:frame(0, 0, baikeWindow.landscapeWidth + 26 * scale, baikeWindow.landscapeHeight)
            baikeWindowView:align(Align.RIGHT)
        else
            baikeWindowView:frame(math.max(screenWidth, screenHeight) - baikeWindow.landscapeWidth, 0, baikeWindow.landscapeWidth + 26 * scale, baikeWindow.landscapeHeight)
            baikeWindowView:align(Align.RIGHT)
        end
    end
end

local function setTopViewSize(topView, isPortrait)
    --设置当前容器大小
    if (topView == nil) then
        return
    end
    if (isPortrait) then
        topView:backgroundColor(0x333333, 1)
        topView:frame(0, 0, baikeWindow.portraitWidth, baikeWindow.portraitHeight * 0.9)
    else
        topView:backgroundColor(0x000000, 0.8)
        topView:frame(26 * scale, 0, baikeWindow.landscapeWidth, baikeWindow.landscapeHeight * 0.899)
    end
end

local function setBottomViewSize(bottomView, isPortrait)
    if (isPortrait) then
        bottomView:frame(0, 0, baikeWindow.portraitWidth, baikeWindow.portraitHeight * 0.1)
    else
        bottomView:frame(26 * scale, 0, baikeWindow.landscapeWidth, baikeWindow.landscapeHeight * 0.101)
    end
    bottomView:align(Align.BOTTOM)
end

local function setLogoSize(logoImg, logoWrapper, isPortrait)
    if (logoImg == nil or logoWrapper == nil) then
        return
    end
    local wrapperX, wrapperY, logoW, logoH = 0, 0, 0, 0

    if (isPortrait) then
        wrapperX = baikeWindow.portraitWidth * 0.093
        wrapperY = baikeWindow.portraitHeight * 0.055
        logoW = scale * 37
        logoH = scale * 37
        logoWrapper:backgroundColor(0x333333)
    else
        wrapperX = 0
        wrapperY = baikeWindow.landscapeHeight * 0.072
        logoW = 45 * scale
        logoH = 45 * scale
        logoWrapper:backgroundColor(0x000000, 0.8)
        logoWrapper:cornerRadius(52 * scale / 2)
    end
    logoWrapper:frame(wrapperX, wrapperY, 52 * scale, 52 * scale)
    logoImg:cornerRadius(logoW / 2)
    logoImg:size(logoW, logoH)
end

local function setBaikeCloseImageView(baikeCloseLayout, baikeCloseImageView, isPortrait)
    if (baikeCloseLayout == nil or baikeCloseImageView == nil) then
        return
    end
    local size = baikeWindow.portraitHeight * 0.083
    if (isPortrait) then
        baikeCloseLayout:frame(0, 0, size, size)
        baikeCloseImageView:frame(0, 0, 15 * scale, 15 * scale)
        baikeCloseImageView:show()
        baikeCloseLayout:align(Align.RIGHT)
        baikeCloseImageView:align(Align.CENTER)
    else
        baikeCloseImageView:hide()
    end
end

local function setTitleSize(titleLabel, isPortrait)
    if (isPortrait) then
        titleLabel:frame(0, baikeWindow.portraitHeight * 0.074, 200, 24)
    else
        titleLabel:frame(0, baikeWindow.landscapeHeight * 0.08, 200, 24)
    end
    titleLabel:textAlign(TextAlign.CENTER)
    titleLabel:align(Align.H_CENTER)

end

local function setBannerPagerSize(bannerPager, isPortrait)
    local x, y, w, h = generateBannerSize(isPortrait)
    if (bannerPager ~= nil) then
        bannerPager:frame(x, y, w, h)
        refreshCollectionView()
        if System.ios() then
            baikeWindow.bannerPagerScrollView:currentPage(1.0, true)
            local imageCount = (baikeWindow.imageViews and #baikeWindow.imageViews) or 0
            for i = 1, imageCount do
                if (baikeWindow.imageViews[i] ~= nil) then
                    baikeWindow.imageViews[i]:backgroundColor(0xA9A9A9, 1.0)
                end

                if (i == 1) then
                    baikeWindow.imageViews[i]:backgroundColor(0xFFFFFF, 1.0)
                end
            end
        end

    end
    return x, y, w, h

end

local function createBannerPager(data, isPortrait)
    local x, y, w, h = setBannerPagerSize(nil, isPortrait)
    local bannerPager = createViewPager(data.data.inforEdit.encyImage, x, y, w, h)
    bannerPager:align(Align.H_CENTER)
    return bannerPager
end

--屏幕旋转--
local function rotationScreen(isPortrait)
    setLuaViewSize(baikeWindow.luaView, isPortrait)
    setBaikeViewSize(baikeWindow.data, baikeWindow.baikeWindowView, isPortrait)
    setTopViewSize(baikeWindow.TopView, isPortrait)
    setListSize(baikeWindow.scrollView, isPortrait)
    setLogoSize(baikeWindow.logoImg, baikeWindow.logoWrapper, isPortrait)
    setTitleSize(baikeWindow.titleLabel, isPortrait)
    setBannerPagerSize(baikeWindow.bannerPager, isPortrait)
    setBottomViewSize(baikeWindow.bottomView, isPortrait)
    setBaikeCloseImageView(baikeWindow.baikeCloseLayout, baikeWindow.baikeCloseImageView, isPortrait)
    setBaikeDescSize(baikeWindow.baikeDesc, isPortrait)
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


--全局父控件
local function createLuaView(isPortrait)
    local luaView = View()
    setLuaViewSize(luaView, isPortrait)
    return luaView
end

local function createBaikeView(data, isPortrait)
    local baikeWindowView = View()
    setBaikeViewSize(data, baikeWindowView, isPortrait)
    return baikeWindowView
end

local function createTopView(isPortrait)
    local topView = View()
    setTopViewSize(topView, isPortrait)
    return topView
end

local function createBaikeCloseImageView(isPortrait)
    local baikeCloseLayout = View()
    baikeCloseLayout:align(Align.RIGHT)
    local baikeCloseImageView = Image(Native)
    baikeCloseImageView:align(Align.CENTER)
    baikeCloseImageView:scaleType(ScaleType.FIT_XY)
    baikeCloseImageView:image(Data(OS_ICON_WEDGE_CLOSE))
    baikeCloseImageView:hide()
    setBaikeCloseImageView(baikeCloseLayout, baikeCloseImageView, isPortrait)
    baikeCloseLayout:addView(baikeCloseImageView)
    return baikeCloseLayout, baikeCloseImageView
end

local function createTitleView(data, isPortrait)
    local baikeTitle = Label(Native)
    baikeTitle:lines(1)
    baikeTitle:textColor(0xFFFFFF)
    baikeTitle:text(data)
    baikeTitle:textSize(16)
    setTitleSize(baikeTitle, isPortrait)
    return baikeTitle
end

local function createLogoImg(data, isPortrait)

    local logoWrapper = View()

    local baikeLogo = Image(Native)
    baikeLogo:scaleType(ScaleType.CENTER_CROP)
    baikeLogo:image(data.data.hotEditInfor.hotImage)
    setLogoSize(baikeLogo, logoWrapper, isPortrait)

    baikeLogo:align(Align.CENTER)
    logoWrapper:addView(baikeLogo)


    return logoWrapper, baikeLogo
end

local function createBottomView(data, isPortrait)
    local bottomView = View()
    setBottomViewSize(bottomView, isPortrait)
    bottomView:backgroundColor(0x000000)
    local x, y, w, h = bottomView:frame()
    local more = Label()
    more:frame(0, 0, w, 20 * scale)
    more:textAlign(TextAlign.CENTER)
    more:text(data.data.inforEdit.btnTxt)
    more:textColor(0xFFFFFF)
    more:align(Align.CENTER)
    bottomView:addView(more)
    return bottomView
end

local function onCreate(data)
    local exposureTrackLink = getWindowExposureTrackLink(data,1)
    if(exposureTrackLink ~= nil)then
        Native:get(exposureTrackLink)
    end

    if (baikeWindow.launchPlanId ~= nil) then
        osTrack(baikeWindow.launchPlanId, 1, 1)
        osTrack(baikeWindow.launchPlanId, 2, 1)
    end

    local isPortrait = Native:isPortraitScreen()
    baikeWindow.media = registerMedia()

    baikeWindow.luaView = createLuaView(isPortrait)
    baikeWindow.baikeWindowView = createBaikeView(data, isPortrait)

    --baikeWindow.baikeWindowView:backgroundColor(0xFC0D27,0.5)

    baikeWindow.TopView = createTopView(isPortrait)
    baikeWindow.logoWrapper, baikeWindow.logoImg = createLogoImg(data, isPortrait)
    baikeWindow.baikeCloseLayout, baikeWindow.baikeCloseImageView = createBaikeCloseImageView(isPortrait)
    baikeWindow.bottomView = createBottomView(data, isPortrait)

    baikeWindow.titleLabel = createTitleView(data.data.inforEdit.encyTitle, isPortrait)

    baikeWindow.scrollView = createListView(data.data.inforEdit.encyDescribe, isPortrait)

    --baikeWindow.scrollView:backgroundColor(0xE86F5E, 0.5)

    baikeWindow.bannerPager = createBannerPager(data, isPortrait)

    baikeWindow.TopView:addView(baikeWindow.baikeCloseLayout)
    baikeWindow.TopView:addView(baikeWindow.titleLabel)
    baikeWindow.TopView:addView(baikeWindow.scrollView)
    baikeWindow.TopView:addView(baikeWindow.bannerPager)
    baikeWindow.baikeWindowView:addView(baikeWindow.TopView)
    baikeWindow.baikeWindowView:addView(baikeWindow.bottomView)
    baikeWindow.baikeWindowView:addView(baikeWindow.logoWrapper)
    baikeWindow.luaView:addView(baikeWindow.baikeWindowView)

    local screenWidth, screenHeight = Native:getVideoSize(2)
    if (isPortrait) then
        if System.ios() then
            baikeWindow.baikeWindowView:y(math.max(screenWidth, screenHeight))
            local x, y, w, h = baikeWindow.baikeWindowView:frame();
            Animate(0.3,
                    function()
                        baikeWindow.baikeWindowView:y(math.max(screenWidth, screenHeight) - h)
                    end,
                    function()
                    end);
        else
            baikeWindow.baikeWindowView:translation(0, 438 * scale)
            startViewTranslationAnim(baikeWindow.baikeWindowView, 0, 0)
        end

    else
        if System.ios() then
            baikeWindow.baikeWindowView:x(math.max(screenWidth, screenHeight))
            local x, y, w, h = baikeWindow.baikeWindowView:frame();
            Animate(0.3,
                    function()
                        baikeWindow.baikeWindowView:x(math.max(screenWidth, screenHeight) - w)
                    end,
                    function()
                    end);
        else
            baikeWindow.baikeWindowView:translation(200 * scale, 0)
            startViewTranslationAnim(baikeWindow.baikeWindowView, 0, 0)
        end
    end

    baikeWindow.bottomView:onClick(function()
        local clickTrackLink = getWindowClickTrackLink(data,1)
        if(clickTrackLink ~= nil) then
            Native:get(clickTrackLink)
        end

        local linkUrl = baikeWindow.data.data.inforEdit.linkUrl
        if (linkUrl == nil) then
            return
        end
        Native:widgetEvent(eventTypeClick, baikeWindow.data.id, adTypeName, actionTypeOpenUrl, linkUrl)
        if (baikeWindow.launchPlanId ~= nil) then
            osTrack(baikeWindow.launchPlanId, 3, 1)
        end
        closeViewByScreenDirection()
    end)

    baikeWindow.baikeCloseLayout:onClick(function()
        closeViewByScreenDirection()
    end)

    baikeWindow.baikeWindowView:onClick(function()
        -- body
    end)

    if(System.ios())then
        baikeWindow.luaView:onClick(function()
            if (not Native:isPortraitScreen()) then
                closeViewByScreenDirection()
            end
        end)

    else
        baikeWindow.luaView:onClick(function()
            closeViewByScreenDirection()
        end)
    end


end

local function setConfig(data)
    if (data == nil) then
        return
    end
    baikeWindow.data = data
    local screenWidth, screenHeight = Native:getVideoSize(2)
    local videoWidth, videoHight, marginTop = Native:getVideoSize(0)
    baikeWindow.portraitWidth = math.min(screenWidth, screenHeight) -- 宽
    baikeWindow.portraitHeight = math.max(screenWidth, screenHeight) - videoHight - marginTop --高
    baikeWindow.landscapeWidth = math.max(screenWidth, screenHeight) * 0.296  + (20 * scale)-- 横屏宽
    --baikeWindow.landscapeWidth = math.max(screenWidth, screenHeight) * 0.32  -- 横屏宽
    baikeWindow.landscapeHeight = math.min(screenWidth, screenHeight) -- 横屏高
    baikeWindow.launchPlanId = data.launchPlanId
end

function show(args)
    if (args == nil or args.data == nil or baikeWindow.luaView ~= nil) then
        return
    end
    setConfig(args.data)
    onCreate(args.data)
end

