-- Created by LuaView.
-- Copyright (c) 2017, Alibaba Group. All rights reserved.
--
-- This source code is licensed under the MIT.
-- For the full copyright and license information,please view the LICENSE file in the root directory of this source tree.

--工具包引入

--local goodsSize = require("goodsSize")
--商品详情模块
--local goodDetailModule = require("goodDetail")
--空订单模块
--local emptyOrderModule = require("emptyOrder")
--空的商品货架模块
--local shelvesModule = require("goodsShelves")
--s商品订单列表
--local orderListModule = require("goodOrderListBackup")

---------------------------------------------------------------
---------------------------------------------------------------
local object = {}
local showType = "goods"
local Native = Native(showType)
local goodsListWebView = VideoPlsWebView({
        Callback = {
            start = function()
                print("start load")
            end,
            loadComplete = function(title)
                print("load complete, title is " .. title)
            end
        },
        JSCallMethodString = {
            method = function()
                return {"say", "setUserInfo", "getCartData"}
            end
        },
        JSCallMethod = {
            say = function()
                print("hello world")
            end,
            setUserInfo = function(dict)
                print(dict)
                return dict
            end,
            getCartData = function(dict)
                print(dict)
                return {["test"]="test"}
            end
        }
    })


local shelvesData = nil

function object:new(o)
    o = o or {}
    setmetatable(o, self)
    self.__index = self
    return o
end

------------------------------------------------------------------------------------------------
---------------------------- 大小位置-----------------------------------------------------------
local screenWidth, screenHeight = System.screenSize()
local tempMaxSide = math.max(screenWidth, screenHeight)
local tempMinSide = math.min(screenWidth, screenHeight)
screenWidth = tempMaxSide
screenHeight = tempMinSide
local systemVersion = tonumber(Native:deviceBuildVersion())
local fontScale = math.max(screenWidth, screenHeight) / 667
fontScale = fontScale < 0.75 and 0.75 or (fontScale > 1.5 and 1.5 or fontScale)

local isNotiOS9 = systemVersion >= 10.0 or systemVersion < 9.0
fontScale = isNotiOS9 and fontScale / 1.022 or fontScale


local goodsSize = object:new()

goodsSize.width = screenWidth
goodsSize.height = screenHeight
goodsSize.rootWidth = screenHeight * 200 / 375
goodsSize.rootHeight = screenHeight

--tab导航栏的高度
goodsSize.tabHeight = screenHeight * 42 / 375

--listView的宽高
goodsSize.listWidth = goodsSize.rootWidth;
goodsSize.listHeight = goodsSize.rootHeight - goodsSize.tabHeight

--itemView的宽高
goodsSize.itemWidth = goodsSize.rootWidth - 20
goodsSize.itemHeight = goodsSize.rootHeight - goodsSize.tabHeight - 10
--------------------------------------------------------------------------------------------------
------------------------------------ 空订单页面---------------------------------------------------

-- 提醒图片
local function tipImage()
    local img = Image(Native)
    local imgWidth = screenHeight * 49 / 375
    local imgHeight = imgWidth * 55 / 49
    img:frame(0, screenHeight * 105 / 375, imageWidth, imageHeight)
    img:backgroundColor(0x000000)
    return img
end

--提示文字
local function tipLabel()
    local tipTxt = Label()
    tipTxt:textColor(0x919191)
    tipTxt:textSize(13) -- * fontScale)
    tipTxt:align(Align.H_CENTER)
    tipTxt:frame(0, screenHeight * 180 / 375, 200, 20)
    tipTxt:text("订单是空的，选点好货吧")
    return tipTxt
end

goodsEmptyViewTable = object:new()
function goodsEmptyViewTable:onCreate()
    self.emptyView = View()
    self.emptyView:size(goodsSize.listWidth, goodsSize.listHeight)
    self.emptyView:backgroundColor(0x454545)
    self.emptyView:addView(tipImage())
    self.emptyView:addView(tipLabel())
    self.emptyView:hide()
end

-------------------------------------------------------------------------------------------------
-------------------------------------------- 错误页面------------------------------------------

-- 错误图片
local function errorImg()
    local img = Image(Native)
    local imgWidth = screenHeight * 104 / 375
    local imgHeight = imgWidth * 99 / 104
    img:align(Align.H_CENTER)
    img:frame(screenHeight * 26 / 375, screenHeight * 64 / 375, imgWidth, imgHeight)
    img:backgroundColor(0x000000)
    return img
end

--点击刷新
local function refreshLabel()
    local refresh = Label()
    refresh:textColor(0xA04B4E)
    local refreshWidth = screenHeight * 128 / 375
    local refreshHeight = refreshWidth * 35 / 128
    refresh:frame(0, screenHeight * 197 / 375, refreshWidth, refreshHeight)
    refresh:textSize(13) -- * fontScale)
    refresh:align(Align.H_CENTER)
    refresh:text("点击刷新")
--    refresh:gravity(Gravity.CENTER)
    refresh:borderWidth(1)
    refresh:borderColor(0xE9595E)
    refresh:onClick(function()
    end)
    return refresh
end

goodsListErrorPageTable = object:new()
function goodsListErrorPageTable:onCreate()
    self.errorPage = View()
    self.errorPage:frame(0, 0, goodsSize.listWidth, goodsSize.listHeight)
    self.errorPage:backgroundColor(0x454545)
    self.errorPage:addView(errorImg())
    self.errorPage:addView(refreshLabel())
    self.errorPage:hide()
end

-------------------------------------------------------------------------------------------------
-------------------------------------------- 未登录页面------------------------------------------

--去录按钮
local function goLoginBtn()
    local login = Label()
    local loginWidth = screenHeight * 128 / 375
    local loginHeight = loginWidth * 35 / 128
    login:frame(0, screenHeight * 142 / 375, loginWidth, loginHeight)
    login:align(Align.H_CENTER)
    login:backgroundColor(0x272727)
    login:borderWidth(1)
    login:textSize(16) -- * fontScale)
    login:textColor(0xDDDDDD)
    login:borderColor(0x5c5c5c)
--    login:gravity(Gravity.CENTER)
    login:onClick(function()
    end)
    login:text("去登录")
    return login
end

--提示文字
local function loginTip1()
    local tipTxt = Label()
    tipTxt:textColor(0x919191)
    tipTxt:textSize(13) -- * fontScale)
    tipTxt:align(Align.H_CENTER)
    tipTxt:frame(0, screenHeight * 190 / 375, 100, 20)
    tipTxt:text("选择去登录")
    return tipTxt
end

local function loginTip2()
    local tipTxt = Label()
    tipTxt:textColor(0x919191)
    tipTxt:textSize(13) -- * fontScale)
    tipTxt:frame(0, screenHeight * 210 / 375, 200, 20)
    tipTxt:align(Align.H_CENTER)
    local ss1 = StyledString("您将进入", { fontColor = 0x919191, fontSize = 13 })
    local ss2 = StyledString("竖屏观看", { fontColor = 0xE9595E, fontSize = 13 })
    local ss3 = StyledString("哦", { fontColor = 0x919191, fontSize = 13 })
    tipTxt:text(ss1 + ss2 + ss3)
    return tipTxt
end

goodsListGoLoginTable = object:new()
function goodsListGoLoginTable:onCreate()
    self.goLoginView = View()
    self.goLoginView:size(goodsSize.listWidth, goodsSize.listHeight)
    self.goLoginView:backgroundColor(0x454545)
    self.goLoginView:addView(goLoginBtn())
    self.goLoginView:addView(loginTip1())
    self.goLoginView:addView(loginTip2())
    self.goLoginView:hide()
end

---------------------------------------------------------------------------------------------------
-------------------------------------------- 购物车页面------------------------------------------
goodsListCarListTable = object:new()
function goodsListCarListTable:onCreate(data)
    self.carListView = View()
    self.carListView:align(Align.RIGHT)
    self.carListView:size(goodsSize.listWidth, goodsSize.listHeight)
    self.carListView:backgroundColor(0x454545)

    -- 加入webview
    -- webview loadingUrl

    self.carListView:hide()

end

---------------------------------------------------------------------------------------------------
-------------------------------------------- 订单列表页面------------------------------------------
goodsListOrderListTable = object:new()
function goodsListOrderListTable:onCreate(data)
    self.orderListView = View()
    self.orderListView:align(Align.RIGHT)
    self.orderListView:size(goodsSize.listWidth, goodsSize.listHeight)
    self.orderListView:backgroundColor(0x454545)

    -- 加入webview
    -- webview loadingUrl

    goodsListOrderLabel = Label()

    goodsListOrderLabel:frame(0, 0, 200,  40)
    goodsListOrderLabel:text("订单列表")
    goodsListOrderLabel:textAlign(TextAlign.CENTER)
    goodsListOrderLabel.align(Align.CENTER)

    self.orderListView:addView(goodsListOrderLabel)

    self.orderListView:hide()

end

-----------------------------------------------------------------------------------------------------------------------
------------------------------------------ 详情页面-----------------------------------------------------------------------------

--返回键
local function backBtn()
    local back = Label()
    back:backgroundColor(0xff00ff)
    back:text("<")
    back:textSize(20) -- * fontScale)
    back:onClick(function()
    end)
    return back
end


--图片viewPager
local function picViewPager()
    local scrollViewSize = goodsSize.listWidth
    local pagerView = PagerView({
        PageCount = 4,
        Pages = {
            Init = function(page, pos)
                page.img = Image(Native)
            end,
            Layout = function(page, pos)
                page.img:size(scrollViewSize, scrollViewSize)
                page.img:image("http://staticcdn.videojj.com/FiJ9chHnSgZLi7YaKlxmKXoJGXbl")
                page.img.callback(function()
                    if (pos == 1) then
                        page:looping(true)
                        page:autoScroll(1)
                    elseif (pos == 2) then
                        page:looping(false)
                        page:autoScroll(0)
                    elseif (pos == 3) then
                        page:autoScroll(1, true)
                    elseif (pos == 4) then
                        page:looping(true)
                    end
                end)
            end
        },
        Callback = {
            Scrolling = function(pos, percent, distance)
                Toast("滑动" .. pos)
                print("滚动" .. pos)
            end,
            Selected = function(pos)
                Toast("选中" .. pos)
                print("选中" .. pos)
            end
        }
    })

    pagerView:backgroundColor(0xaaaa0000)
    pagerView:size(scrollViewSize, scrollViewSize)

    return pagerView
end

--图文详情按钮
local function imgTxtDetail()
    local label = Label()
    label:textColor(0xff00ff)
    label:height(20)
    label:text("图文详情")
    label:textSize(12) -- * fontScale)
    label:xy(100, goodsSize.listWidth - 10)
    label:onClick(function()
    end)
    return label
end

--价格
local function price()
    local price = Label()
    price:textColor(0xff00ff)
    price:height(20)
    price:text("￥340")
    price:textSize(20) -- * fontScale)
    price:frame(0, goodsSize.listWidth + 10, 150, 25)
    return price
end

--介绍
local function desc()
    local desc = Label()
    desc:textColor(0xff00ff)
    desc:text("爸爸去哪儿")
    desc:textSize(18) -- * fontScale)
    desc:lineCount(2) -- * fontScale)
    desc:y(goodsSize.listWidth + 28)
    return desc
end

--上面横线
local function topLine()
    local line = Label()
    line:width(goodsSize.listWidth)
    line:xy(0, goodsSize.listWidth + 50)
    line:textSize(10) -- * fontScale)
    line:textColor(0xffffff)
    line:lineCount(1)
    line:text("=================================================")
    return line
end

--下面横线
local function bottomLine()
    local line = Label()
    line:width(goodsSize.listWidth)
    line:xy(0, goodsSize.listWidth + 100)
    line:textSize(10) -- * fontScale)
    line:lineCount(1)
    line:textColor(0xffffff)
    line:text("=================================================")
    return line
end

--规格
local function spec()
    local spec = Label()
    spec:textSize(12) -- * fontScale)
    spec:xy(0, goodsSize.listWidth + 58)
    spec:text("规格")
    spec:textColor(0xffffff)
    return spec
end

--规格列表
local function specList()
    local scrollView = HScrollView()
    scrollView:size(goodsSize.listWidth, 45)
    scrollView:align(Align.H_CENTER)
    scrollView:xy(0, goodsSize.listWidth + 80)
    scrollView:showScrollIndicator(false)
    local txts = { "纪念版", "限定版", "模块" }
    for i = 1, 3 do
        local txt = Label()
        txt:text(txts[i])
        txt:textSize(13) -- * fontScale)
        txt:textColor(0xffffff)
 --       txt:gravity(Gravity.CENTER)
        txt:borderColor(0xffffff)
        txt:borderWidth(1)
        txt:borderDash(4, 2) --边框曲线
        txt:xy((i - 1) * 50, 0)

        scrollView:addView(txt)
    end


    return scrollView
end

--颜色
local function colorLabel()
    local color = Label()
    color:textSize(12) -- * fontScale)
    color:y(goodsSize.listWidth + 110)
    color:text("颜色")
    color:align(Align.LEFT)
    return color
end

--颜色列表
local function colorList()
    local scrollView = HScrollView()
    scrollView:size(goodsSize.listWidth, 40)
    scrollView:align(Align.H_CENTER)
    scrollView:xy(0, goodsSize.listWidth + 130)
    scrollView:showScrollIndicator(false)
    local txts = { "红色", "黄色", "蓝色" }
    for i = 1, 3 do
        local txt = Label()
        txt:text(txts[i])
        txt:textSize(13) -- * fontScale)
        txt:xy((i - 1) * 40, 0)
        txt:borderColor(0xffffff)
        txt:borderWidth(1)
--        txt:gravity(Gravity.CENTER)
        txt:borderDash(4, 2) --边框曲线
        scrollView:addView(txt)
    end
    return scrollView
end

--底部导航栏
local function tabs()
    local tab = View()
    tab:size(goodsSize.listWidth, goodsSize.tabHeight)
    tab:align(Align.BOTTOM)

    --购物车
    local car = Image(Native)
    car:size(goodsSize.tabHeight, goodsSize.tabHeight)
    car:backgroundColor(0xff00ff)
    car:alignLeft()

    --加入购物车
    local addCar = Label()
    addCar:size(goodsSize.listWidth / 2 - goodsSize.tabHeight - 1, goodsSize.tabHeight)
    addCar:textSize(13) -- * fontScale)
    addCar:xy(goodsSize.tabHeight + 1, 0)
--    addCar:gravity(Gravity.CENTER)
    addCar:text("加入购物车")
    addCar:onClick(function()
    end)

    --立即购买
    local buy = Label()
    buy:textSize(13) -- * fontScale)
    buy:textColor(0xffffff)
    buy:size(goodsSize.listWidth / 2, goodsSize.tabHeight)
    buy:align(Align.RIGHT)
    buy:text("立即购买")
--    buy:gravity(Gravity.CENTER)
    buy:backgroundColor(0xff00ff)

    tab:addView(car)
    tab:addView(addCar)
    tab:addView(buy)

    return tab
end

goodsListItemDetailTable = object:new()
function goodsListItemDetailTable:onCreate(data)
    self.detailView = View()
    self.detailView:size(goodsSize.listWidth, goodsSize.height)
    self.detailView:align(Align.RIGHT)

    self.detailLayout = View()
    self.detailLayout:align(Align.RIGHT)
    self.detailLayout:backgroundColor(0x000000)
    self.detailLayout:size(goodsSize.listWidth, goodsSize.height)
    self.detailLayout:addView(picViewPager())
    self.detailLayout:addView(backBtn())
    self.detailLayout:addView(imgTxtDetail())
    self.detailLayout:addView(price())
    self.detailLayout:addView(desc())
    self.detailLayout:addView(topLine())
    self.detailLayout:addView(spec())
    self.detailLayout:addView(specList())
    self.detailLayout:addView(bottomLine())
    self.detailLayout:addView(colorLabel())
    self.detailLayout:addView(colorList())

    self.detailView:addView(self.detailLayout)
    self.detailView:addView(tabs())
    self.detailView:hide()
end


-------------------------------------------------------------------------------------------
----------------------------------- 商品货架：橱窗样式----------------------------------------

local itemArray = {}
local position = 1
local currentIndex = 1
local displayWindowListView

--ListView的itemView
local function initDisplayWindowItemView(index)

    local y = screenHeight * 22 / 375
    local imgWidth = screenHeight * 168 / 375
    local itemWidth = screenHeight * 180 / 375
    local itemHeight = imgWidth * 251 / 168

    local rootView = View()
    rootView:size(itemWidth, itemHeight)
    rootView:align(Align.H_CENTER)
    rootView:xy(0, y)
    --左边layout布局
    local itemLayout = View()
    itemLayout:size(imgWidth, itemHeight)

    --    itemLayout:align(Align.H_CENTER)
    itemLayout:cornerRadius(6)
    --商品图片
    local img = Image(Native)
    img:size(imgWidth, imgWidth)
    img:cornerRadius(6)
    img:image("http://staticcdn.videojj.com/FiJ9chHnSgZLi7YaKlxmKXoJGXbl")

    --商品描述
    local descWidth = screenHeight * 115 / 375
    local descHeight = descWidth * 32 / 115
    local titleX = screenHeight * 8 / 375

    local desc = Label()
    desc:frame(titleX, screenHeight * 174 / 375, descWidth, descHeight)
    desc:textSize(13) -- * fontScale)
    desc:lineCount(2)
    desc:textColor(0x4A4A4A)
    desc:text("decription" .. shelvesData["data"]["goods"][index]["name"])

    --商品价格
    local priceY = screenHeight * 218 / 375
    local price = Label()
    price:frame(titleX, priceY, 100, 20)
    price:textSize(16) -- * fontScale)
    price:textColor(0xE8585B)
    price:text("￥30")

    --立即购买
    local buy = Label()
    buy:textSize(10) -- * fontScale)
    buy:frame(screenHeight * 96 / 375, priceY, screenHeight * 63 / 375, screenHeight * 24 / 375)
    buy:textColor(0xffffff)
    buy:text("立即购买")
    buy:textAlign(TextAlign.CENTER)
--    buy:gravity(Gravity.CENTER)
    buy:cornerRadius(screenHeight * 48 / 375 * 0.2)
    buy:backgroundColor(0xE8585B)


    itemLayout:addView(img)
    itemLayout:addView(desc)
    itemLayout:addView(price)
    itemLayout:addView(buy)
    itemLayout:backgroundColor(0xffffff)
    itemLayout:align(Align.CENTER)

    --购物车icon
    local carIcon = View()
    local carSize = screenHeight * 24 / 375
    local carY = imgWidth - carSize / 2
    carIcon:size(carSize, carSize)
    carIcon:align(Align.RIGHT)
    carIcon:xy(0, carY)
    carIcon:backgroundColor(0xff00ff)

    rootView:addView(itemLayout)
    rootView:addView(carIcon)
    return rootView
end

--橱窗商品列表
local function initDisplayWindowListView()
    local view = View()
    view:size(goodsSize.listWidth, goodsSize.listHeight)
    view:alignRight()

    for i = 1, 1 do
        local item = initDisplayWindowItemView(i)
        view:addView(item)
        itemArray[i] = item
    end
    position = table.getn(shelvesData)
    return view
end


-------------------------------------- 列表样式的货架--------------------------------------------
local function initShelvesList()

    --多少行

    local itemWidth = screenHeight * 194 / 375
    local itemHeight = itemWidth * 68 / 194
    local imgSize = screenHeight * 60 / 375
    local imgX = screenHeight * 4 / 375
    local titleX = screenHeight * 71 / 375
    local titleY = screenHeight * 7 / 375
    local priceY = screenHeight * 41 / 375
    local carSize = screenHeight * 24 / 375
    local carX = screenHeight * 163 / 375
    local carY = screenHeight * 35 / 375
    local tableViewData = {
        Section = {
            SectionCount = function()
                -- 返回页面区块的个数（不同区块的种类数）
                return 1
            end,
            RowCount = function(section)
                if shelvesData == nil then
                    return 0
                else 
                    return #shelvesData["data"]["goods"]
                end
            end
        },
        Cell = {
            --cell是代表一行
            Id = function(section, row) -- 指定section和row对应的Cell类型唯一识别号
                local id = "Cell"
                return id;
            end,

            Cell = {
                Size = function(section, row)
                    return itemHeight
                end,
                Init = function(cell, section, row) -- 初始化cell
                    cell.item = View()
                    cell.item:backgroundColor(0xffffff)
                    cell.adsImg = Image(Native)
                    cell.title = Label()
                    cell.price = Label()
                    cell.car = Image(Native)

                    cell.item:addView(cell.adsImg)
                    cell.item:addView(cell.title)
                    cell.item:addView(cell.price)
                    cell.item:addView(cell.car)

                end,
                Layout = function(cell, section, row) -- cell复用时调用
                    cell.item:frame(0, 0, itemWidth, itemHeight)
                    cell.item:align(Align.RIGHT)

                    --广告图片
                    cell.adsImg:frame(imgX, 0, imgSize, imgSize)
                    cell.adsImg:align(Align.V_CENTER)
                    cell.adsImg:image("http://staticcdn.videojj.com/FiJ9chHnSgZLi7YaKlxmKXoJGXbl")
                    
                    cell.title:textSize(12) -- * fontScale)
                    cell.title:textColor(0x4A4A4A)
                    cell.title:frame(titleX, titleY, 100, 20)
                    cell.title:text("可口可乐" .. shelvesData["data"]["goods"][row]["name"])
                    
                    cell.price:textColor(0xE9595E)
                    cell.price:textSize(14) -- * fontScale)
                    cell.price:frame(titleX, priceY, 100, 20)
                    cell.price:text("￥100")
                    
                    --购物车图片
                    cell.car:frame(carX, carY, carSize, carSize)
                cell.car:backgroundColor(0x000000)
                    
                end,
                Callback = function(cell, section, row) -- 用户点击了section和row
                    print("元表Section " .. section .. ", Row " .. row)
                end
            }
        }
    }
    local tableView = CollectionView(tableViewData)
--    tableView:reload()
    -- tableView:y(screenHeight * 8 / 375)
    tableView:miniSpacing(screenHeight * 7 / 375)
    tableView:size(goodsSize.listWidth, goodsSize.listHeight)
    return tableView
end


goodsListShelvesView = object:new()

function goodsListShelvesView:createCollectionView()
    -- 根据data, 生成 橱窗 或者 列表
    math.randomseed(tostring(os.time()):reverse():sub(1, 6))
    if(math.random(10) < 5) then
        self.collectionView = initDisplayWindowListView()
    else
        self.collectionView = initShelvesList()
    end

    self.shelvesView:addView(self.collectionView)
end

-- 货架列目标总控
function goodsListShelvesView:onCreate()
    if self.shelvesView ~= nil then
        return
    end
    if self.shelvesView == nil then
        self.shelvesView = View()
        self.shelvesView:size(goodsSize.rootWidth, goodsSize.rootHeight)
        self.shelvesView:alignRight()
        self.shelvesView:backgroundColor(0x000000, 0.4)

        if shelvesData == nil or shelvesData == "error" then
            return
        end

        self:createCollectionView()
        
    end
end


----------------------------------------------------------------------------------------------------
---------------------------------- 导航栏布局---------------------------------------------------------------

--货架tab
goodListsShelvesButton = nil
local function initShelvesTab(tabWidth)
    goodListsShelvesButton = Button(Native)
    goodListsShelvesButton:frame(0, 0, tabWidth, goodsSize.tabHeight)
    goodListsShelvesButton:image("https://sdkcdn.videojj.com/images/ios/store/list_shelf_unselected@2x.png")
    goodListsShelvesButton:selectedImage("https://sdkcdn.videojj.com/images/ios/store/list_shelf_selected@2x.png")
    goodListsShelvesButton:align(Align.LEFT, Align.H_CENTER)

    goodListsShelvesButton:onClick(function()
        goodsListShelvesView.shelvesView:show()
        goodsListOrderListTable.orderListView:hide()
        goodsListCarListTable.carListView:hide()

        goodListsShelvesButton:selected(true)
        goodListsOrderButton:selected(false)
        goodListsCarButton:selected(false)
    end)

    goodListsShelvesButton:selected(true)

    return goodListsShelvesButton
end

--订单tab
goodListsOrderButton = nil
local function initOrderTab(tabWidth)
    goodListsOrderButton = Button(Native)
    goodListsOrderButton:frame(0, 0, tabWidth, goodsSize.tabHeight)
    goodListsOrderButton:image("https://sdkcdn.videojj.com/images/ios/store/list_goods_unselected@2x.png")
    goodListsOrderButton:selectedImage("https://sdkcdn.videojj.com/images/ios/store/list_goods_selected@2x.png")
    goodListsOrderButton:align(Align.CENTER)

    goodListsOrderButton:onClick(function()
        goodsListShelvesView.shelvesView:hide()
        goodsListOrderListTable.orderListView:show()
        goodsListCarListTable.carListView:hide()

        goodListsShelvesButton:selected(false)
        goodListsOrderButton:selected(true)
        goodListsCarButton:selected(false)
    end)

    return goodListsOrderButton

end

--购物车tab
goodListsCarButton = nil
local function initCarTab(tabWidth)

    goodListsCarButton = Button(Native)
    goodListsCarButton:frame(0, 0, tabWidth, goodsSize.tabHeight)
    goodListsCarButton:image("https://sdkcdn.videojj.com/images/ios/store/list_cart_unselected@2x.png")
    goodListsCarButton:selectedImage("https://sdkcdn.videojj.com/images/ios/store/list_cart_selected@2x.png")
    goodListsCarButton:align(Align.RIGHT)

    goodListsCarButton:onClick(function()
        goodsListShelvesView.shelvesView:hide()
        goodsListOrderListTable.orderListView:hide()
        goodsListCarListTable.carListView:show()

        goodListsShelvesButton:selected(false)
        goodListsOrderButton:selected(false)
        goodListsCarButton:selected(true)


        goodsListCarListTable.carListView:addView(goodsListWebView)
        goodsListWebView:frame(goodsListCarListTable.carListView:frame())
        -- goodsListWebView:loadUrl("http://cytron.oss-cn-beijing.aliyuncs.com/pages/vmall/dev/index.html#detail?sku=297&project_id=566638eebb54b35300809730")
        goodsListWebView:loadUrl("http://cytroncdn.videojj.com/pages/zhanqiMall/dev/index.html#debug")
        -- goodsListWebView:loadUrl("http://192.168.2.232:5002/?sku=12225&project_id=566638eebb54b35300809730")
        

    end)

    return goodListsCarButton

end


--底部导航tab
local function initTabView()
    --tab跟布局
    tabLayout = View()
    tabLayout:size(goodsSize.rootWidth, goodsSize.tabHeight)
    tabLayout:align(Align.BOTTOM, Align.RIGHT)
    tabLayout:backgroundColor(0x282828)

    local tabWidth = goodsSize.rootWidth / 3

    tabLayout:addView(initShelvesTab(tabWidth))
    tabLayout:addView(initOrderTab(tabWidth))
    tabLayout:addView(initCarTab(tabWidth))

    return tabLayout
end

---------------------------------------------------------------------------------------------------
------------------------------------ 点击货架入口时打开的侧边栏---------------------------------------------------

goodsListMainTable = object:new()
function goodsListMainTable:onCreate()
    self.mainView = View()
    self.mainView:frame(0, 0, goodsSize.rootWidth, goodsSize.rootHeight)
    self.mainView:align(Align.RIGHT)
    self.mainView:backgroundColor(0xffffff)


    goodsListShelvesView:onCreate()
    if goodsListShelvesView.shelvesView ~= nil then
        self.mainView:addView(goodsListShelvesView.shelvesView)
    end

    goodsListOrderListTable:onCreate()
    self.mainView:addView(goodsListOrderListTable.orderListView)

    goodsListCarListTable:onCreate()
    self.mainView:addView(goodsListCarListTable.carListView)

    --    goLoginTable:onCreate()
    --    mainView:addView(goLoginTable.goLoginView)
    --    errorPageTable:onCreate()
    --    mainView:addView(errorPageTable.errorPage)
    --商品详情
    --    itemDetailTable:onCreate()
    --    mainView:addView(itemDetailTable.detailView)
    --添加导航栏
    self.mainView:addView(initTabView())
    --self.mainView:hide()
end


---------------------------------------------------------------------------------------------------
-------------------------------------- 加载页面-----------------------------------------------------
goodsListLoadingView = nil
local function initLoadingView()
    if goodsListLoadingView == nil then
        goodsListLoadingView = CustomLoading()
        goodsListLoadingView:frame(0, 0, goodsSize.rootWidth, goodsSize.listHeight)
        goodsListLoadingView:backgroundColor(0x111111)

        goodsListMainTable.mainView:addView(goodsListLoadingView)
    end

    if goodsListErrorView ~= nil then
        goodsListErrorView:hide()
    end
    goodsListLoadingView:show()
end

----------------------------------刷新页面api------------------------------------------------
function httpGetshelves()
end

local function refreshAPI()
    initLoadingView()
    httpGetshelves()
end

---------------------------------------------------------------------------------------------------
-------------------------------------- 出错页面-----------------------------------------------------

goodsListErrorView = nil
local function initErrorView()
    if goodsListErrorView == nil then
        goodsListErrorView = View()
        goodsListErrorView:frame(0, 0, goodsSize.rootWidth, goodsSize.listHeight)
        goodsListErrorView:backgroundColor(0x111111)

        goodsListRefreshButton = Button(Native)
        goodsListRefreshButton:frame(0, 0, 120, 50)
        goodsListRefreshButton:align(Align.CENTER)

        goodsListRefreshButton:title("点击刷新")
        goodsListRefreshButton:borderWidth(1)
        goodsListRefreshButton:borderColor(0xff0000)
        goodsListRefreshButton:titleColor(0xff0000)
        goodsListRefreshButton:fontSize(16) -- * fontScale)
        goodsListRefreshButton:onClick(function()
            refreshAPI()
        end)

       goodsListErrorView:addView(goodsListRefreshButton)

       goodsListMainTable.mainView:addView(goodsListErrorView)
    end

    if goodsListLoadingView ~= nil then
        goodsListLoadingView:hide()
    end
    goodsListErrorView:show()
end

---------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------
--local totalView
-- 初始化页面布局
local function startShowAnimation(view)
    local x, y, width, height = view:frame();
    --view:frame(x + width, startY, sizeX, sizeY)
    view:translationX(width)
    --Animation():translation(width, 0):duration(0):with(view):start()
    Animation():translation(0, 0):duration(0.3):with(view):interpolator(Interpolator.ACCELERATE_DECELERATE):start()
end

local function startHideAnimation(view)
    local x, y, width, height = view:frame();
    --view:frame(x + width, startY, sizeX, sizeY)
    view:translationX(0)
    --Animation():translation(width, 0):duration(0):with(view):start()
    Animation():translation(width, 0):duration(0.3):with(view):interpolator(Interpolator.ACCELERATE_DECELERATE):callback(
        {
            onStart = function()
                view:translationX(0)
            end,
            onEnd = function()
                goodsListTotalView:hide()
                Native:destroyView()
            end
        }
    ):start()
end

function show(json)
end

function httpGetshelves()
        Native:get(
            "http://dev-plat.videojj.com/",
            "shelf/566638eebb54b35300809730",
            -- {
            --     channel = "",
            --     video = ""
            -- },
            function ( responseObject, errorInfo )
                -- responseObject -> table , errorInfo -> string
                -- local str = tostring( responseObject );
                -- print(str);
                -- local object = Json:toTable(str);
                if( errorInfo ~= nil or responseObject["status"] ~= 0 ) then
                    show("error")
                else
                    show(responseObject)
                end
            end
        )
end

goodsListTotalView = nil
function show(data)

    -- 创建view
        if goodsListTotalView == nil then
            goodsListTotalView = View()
            goodsListTotalView:frame(0, 0, screenWidth, screenHeight)

            local clickView = View()
            clickView:frame(0, 0, screenWidth, screenHeight)

            goodsListMainTable:onCreate()

            -- 点击view
            clickView:onClick(function()
                startHideAnimation(goodsListMainTable.mainView)
            end)

            goodsListTotalView:addView(clickView)
            goodsListTotalView:addView(goodsListMainTable.mainView)
            startShowAnimation(goodsListMainTable.mainView)

            httpGetshelves()

        end

    if data == nil then
        initLoadingView()
    elseif data == "error" then
        initErrorView()
    else
        if goodsListErrorView ~= nil then
            goodsListErrorView:hide()
        end
        if goodsListLoadingView ~= nil then
            goodsListLoadingView:hide()
        end

        shelvesData = data
        if goodsListMainTable ~= nil then
            goodsListShelvesView:onCreate()
            if goodsListShelvesView.collectionView == nil then
                goodsListShelvesView:createCollectionView()
            end
        end

    end
end
