local screenWidth, screenHeight = System.screenSize()
local showType = "goods"
local Native = Native(showType)

---------------------------------------------------------------------------------------------------
-------------------------------------- 货架入口页面------------------------------------------------

-- 货架入口
local function shelvesEntrance()
    --local entrSize = screenHeight * 68 / 375
    --local entrView = View()
    --entrView:frame(0, 0, entrSize, entrSize)
    --entrView:align(Align.V_CENTER, Align.LEFT)

    local img = Image(Native)
    -- local img = Image()
    --entrView:addView(img)
    local imgSize = screenHeight * 40 / 375
    img:frame(0, 0, imgSize, imgSize)
    --img:align(Align.CENTER)
    img:left(28)
    img:align(Align.V_CENTER)
    --img:right(screenHeight * 28 / 375)
    img:backgroundColor(0xff00ff)
    img:onClick(function()
        Native:sendAction("turn://" .. Native:base64Encode("goods.lua"))
    end)
    return img
end

---------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------
-- 初始化页面布局
function show(json)
    goodsEntranceView = ThroughView()
    goodsEntranceView:frame(0, 0, screenWidth, screenHeight)
    goodsEntranceImage = shelvesEntrance()
    goodsEntranceView:addView(goodsEntranceImage)
    goodsEntranceView:frame(goodsEntranceImage:frame())
    goodsEntranceImage:xy(0, 0)
    --throughView:align(Align.V_CENTER, Align.RIGHT)
end
-- show()