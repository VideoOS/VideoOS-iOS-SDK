--工具包引入

local object = {}
function object:new(o)
    o = o or {}
    setmetatable(o, self)
    self.__index = self
    return o
end

------------------------ table定义-----------------------
local loadingTable = object:new()
local webViewTable = object:new()
local goLoginTable = object:new()
local shelvesDisplayWindowTable = object:new()
local shelvesTable = object:new()
local emptyViewTable = object:new()
local errorPageTable = object:new()
local shelvesListTable = object:new()
local shelvesTabTable = object:new()
local orderTabTable = object:new()
local carTabTable = object:new()
local entranceTable = object:new()
local mainTable = object:new()
local totalControl = object:new()
---------------------------- 公用变量定义-------------------

local showType = "goods"
local Native = Native(showType,
    {
        Callback = {
            -- goodsData return
            updateCartCount = function(cartCount, totalCount)
                -- body
                if carTabTable.number ~= nil then
                    if totalCount == 0 then
                        carTabTable.number:textSize(8)
                        carTabTable.number:text("0")
                        carTabTable.number:hide()
                    elseif totalCount > 99 then
                        carTabTable.number:textSize(6)
                        carTabTable.number:text("99+")
                        carTabTable.number:show()
                    else
                        carTabTable.number:textSize(8)
                        carTabTable.number:text(tostring(totalCount))
                        carTabTable.number:show()
                    end
                end
            end
        }
    })


local screenWidth, screenHeight = System.screenSize()
local tempMaxSide = math.max(screenWidth, screenHeight)
local tempMinSide = math.min(screenWidth, screenHeight)
screenWidth = tempMaxSide
screenHeight = tempMinSide

local scale = screenHeight / 375

local rootWidth = screenHeight * 200 / 375
local tabHeight = 42 * scale
local listHeight = screenHeight - tabHeight
local goodsType = 0 --0:橱窗 1:列表

local hasGoods = false
local shelvesData = nil

local isLoaindg = false
local isError = false

local webViewSuccess = false

-- webView 全局通用
local webView = nil

local shoppingCartUrl = nil
local orderUrl = nil

local isLogin = false


-----------------http request--------------------------

function loadShelvesData()
        loadingTable:start()
        isLoaindg = true
        Native:get(
            "http://dev-plat.videojj.com/",
            "shelf/" .. Native:appKey(),
            function ( responseObject, errorInfo )
                isLoaindg = false
                loadingTable:stop()
                if( errorInfo ~= nil or responseObject.status ~= 0 ) then
                    isError = true
                    errorPageTable:show()
                else
                    show(responseObject)
                    Native:updateLocalLuaFile(responseObject.data.lua, responseObject.data.lua_md5)
                end
            end
        )
end





------------------------------ LoadingView--------------
function loadingTable:onCreate()
    self.loadingPage = View()
    self.loadingPage:size(rootWidth, listHeight)
    self.loadingPage:align(Align.RIGHT)
    self.loadingPage:backgroundColor(0x454545)

    self.loading = LoadingView()
    self.loading:size(rootWidth, listHeight)
    self.loading:align(Align.CENTER)

    self.loadingPage:addView(self.loading)

    self.start = function()
        self.loadingPage:show()
    end

    self.stop = function()
        self.loadingPage:hide()
    end
    self.loadingPage:hide()
end

--------------------- ---------- WebView-------------------------
function webViewTable:createWebView()
    self.loading = LoadingView()
    self.loading:backgroundColor(0x111111)
    self.loading:frame(0, 0, rootWidth, listHeight)
    self.loading:align(Align.CENTER)
    self.loading:hide()

    webView = VideoPlsWebView({
        Callback = {
            start = function()

                webViewTable.webPage:addView(webViewTable.loading)
                webViewTable.loading:show()

                print("start load")
            end,
            loadComplete = function(title, error)
                webViewTable.loading:hide()
                webViewTable.loading:removeFromSuper()

                if error ~= nil then
                    -- need retry ? or bool to notice?
                    webViewSuccess = false
                    print("load error, error is" .. error)
                else
                    webViewSuccess = true
                    print("load complete, title is " .. title)
                end
            end
        },
        JSCallMethodString = {
            method = function()
                return {"getUserInfo", "setUserInfo", "getCartData", "setCartData", "close", "screenChange"}
            end
        },
        JSCallMethod = {
            getUserInfo = function()
                local userInfoJson = Native:getUserInfo()
                print(userInfoJson)
                return userInfoJson
            end,
            setUserInfo = function(dict)
                Native:setUserInfo(dict)
            end,
            getCartData = function()
                local cartData = Native:getAllCartData()
                print(cartData)
                return cartData
            end,
            setCartData = function(dict)
                Native:updateCartData(dict)
            end,
            close = function()
                shelvesTable:show()
                webViewTable:hide()
            end,
            screenChange = function(dict)
                Native:sendAction("GoodsList://" .. Native:base64Encode("openWebView"), dict)
                Native:destroyView()
            end
        }
    })

    webView:size(rootWidth, listHeight)
    webView:align(Align.RIGHT)

    return webView
end


function webViewTable:onCreate()
    self.webPage = View()
    self.webPage:size(rootWidth, listHeight)
    self.webPage:align(Align.RIGHT)

    self:createWebView()

    self.webPage:addView(webView)

    self.show = function(self)
        self.webPage:show()
    end

    self.hide = function(self)
        self.webPage:hide()
    end

    mainTable:addView(self.webPage)

    self:hide()
end


-------------------------------------------- 错误页面------------------------------------------

-- 错误图片
local function errorImg()
    local img = Image(Native)
    local imgWidth = 103 * scale
    local imgHeight = imgWidth * 99 / 103
    img:image("https://sdkcdn.videojj.com/images/ios/store/shelf_load_error@2x.png")
    img:frame(26 * scale, 64 * scale, imgWidth, imgHeight)
    img:align(Align.H_CENTER)
    return img
end

--点击刷新
local function refreshLabel()
    local refresh = Button(Native)
    refresh:xy(0, 197 * scale)
    local refreshWidth = 128 * scale
    local refreshHeight = 35 * scale
    refresh:size(refreshWidth, refreshHeight)
    refresh:textSize(16)
    refresh:align(Align.H_CENTER)
    refresh:title("点击刷新")
    refresh:titleColor(0xA04B4E)
    refresh:borderWidth(1)
    refresh:borderColor(0xE9595E)
    refresh:onClick(function()
        loadingTable.loadingPage:bringToFront()
        loadShelvesData()
        errorPageTable:hide()
    end)
    return refresh
end


function errorPageTable:hide()
    if self.errorPage then
        self.errorPage:removeFromSuper()
        self.errorPage = nill
    end
end

function errorPageTable:onCreate()
    if self.errorPage == nill then
        self.errorPage = View()
        self.errorPage:size(rootWidth, listHeight)
        self.errorPage:backgroundColor(0x454545)
        self.errorPage:addView(errorImg())
        self.errorPage:addView(refreshLabel())
        mainTable:addView(self.errorPage)
    end
end

function errorPageTable:show()
    self:onCreate()
    self.errorPage:show()
end

-------------------------------------------- 未登录页面------------------------------------------

--去录按钮
local function goLoginBtn()
    local login = Button(Native)
    local loginWidth =  128 * scale
    local loginHeight = 40 * scale
    login:size(loginWidth, loginHeight)
    login:xy(0, 142 * scale)
    login:align(Align.H_CENTER)
    login:backgroundColor(0x272727)
    login:borderWidth(1)
    login:textSize(16)
    login:textColor(0xDDDDDD)
    login:borderColor(0x5c5c5c)

    login:onClick(function()

        Native:sendAction("GoodsList://" .. Native:base64Encode("openWebView"), string.reverse(string.gsub(string.reverse(orderUrl), "1=etil", "0=etil", 1)))
        Native:destroyView()

    end)
    login:title("去登录")
    return login
end

--提示文字
local function loginTip1()
    local tipTxt = Label()
    tipTxt:textColor(0x919191)
    tipTxt:textSize(13)
    tipTxt:xy(0, 190 * scale)
    tipTxt:size(150 * scale, 30 * scale)
    tipTxt:textAlign(TextAlign.CENTER)
    tipTxt:align(Align.H_CENTER)
    tipTxt:text("选择 去登录")
    return tipTxt
end

local function loginTip2()
    local tipTxt = Label()
    tipTxt:textColor(0x919191)
    tipTxt:textSize(13)
    tipTxt:xy(0, 210 * scale)
    tipTxt:size(190 * scale, 30 * scale)
    tipTxt:textAlign(TextAlign.CENTER)
    tipTxt:align(Align.H_CENTER)
    local ss1 = StyledString("您将进入 ", { fontColor = 0x919191, fontSize = 13 })
    local ss2 = StyledString("竖屏观看", { fontColor = 0xE9595E, fontSize = 13 })
    local ss3 = StyledString(" 哦", { fontColor = 0x919191, fontSize = 13 })
    tipTxt:text(ss1 + ss2 + ss3)
    return tipTxt
end

function goLoginTable:hide()
    if self.goLoginPage then
        self.goLoginPage:removeAllViews()
        self.goLoginPage:hide()
        self.goLoginPage:removeFromSuper()
        self.goLoginPage = nill
    end
end

function goLoginTable:onCreate()
    if self.goLoginPage == nill then
        self.goLoginPage = View()
        self.goLoginPage:size(rootWidth, listHeight)
        self.goLoginPage:align(Align.RIGHT)
        self.goLoginPage:backgroundColor(0x454545)
        self.goLoginPage:addView(goLoginBtn())
        self.goLoginPage:addView(loginTip1())
        self.goLoginPage:addView(loginTip2())
        mainTable:addView(self.goLoginPage)
    end
end


function goLoginTable:show()
    self:onCreate()
end

--------- 商品货架：全屏橱窗样式  Display window--------------


--橱窗商品列表
local function initDisplayWindowListView()
    local view = ShelvesCardView(Native, shelvesData, 
    {
        Callback = {
            itemOnClick = function(selectedIndex)
                local goodsItem = shelvesData.goods[selectedIndex]
                webViewTable.webPage:bringToFront()
                webViewTable:show()
                if webViewSuccess then
                    webView:callJS("setCurrentUrl", goodsItem.url)
                else
                    webView:loadUrl(goodsItem.url) 
                end

            end,
            itemOnAddCart = function(selectedIndex)
                local goodsItem = shelvesData.goods[selectedIndex]
                Native:addCart(tostring(goodsItem.sku_id), 1)

            end,
            itemOnImmediatelyBuy = function(selectedIndex)
                -- 只是进商详
                local goodsItem = shelvesData.goods[selectedIndex]
                webViewTable.webPage:bringToFront()
                webViewTable:show()
                if webViewSuccess then
                    webView:callJS("setCurrentUrl", goodsItem.url)
                else
                    webView:loadUrl(goodsItem.url) 
                end

            end
        }
    })
    view:xy(0, 0)
    view:size(rootWidth, listHeight)
    view:align(Align.RIGHT)

    view:initView()
    return view
end


-------------------- 列表样式的货架--------------------------
local function initShelvesList()
    local data = shelvesData
    local goods = data.goods
    local count = table.getn(goods)
    local itemWidth = 194 * scale
    local itemHeight = itemWidth * 68 / 194
    local imgSize = 60 * scale
    local imgX = 4 * scale
    local titleX = 71 * scale
    local titleY = 7 * scale
    local priceY = 41 * scale
    local carSize = 24 * scale
    local carX = screenHeight * 163 / 375
    local carY = 35 * scale
    local tableViewData = {
        Section = {
            SectionCount = 1, -- section数量
            RowCount = function(section)
                if hasGoods then
                    return #shelvesData.goods
                else 
                    return 0
                end
            end
        },
        Cell = {
            --cell是代表一行
            Id = function(section, row) -- 指定section和row对应的Cell类型唯一识别号
                local id = "Cell"
                return id;
            end
        }
    }

    local cellData = function(_, key)
        return {
            --每个item的高度
            Size = function(section, row)
                return itemHeight
            end,
            Init = function(cell, section, row) -- 初始化cell
                cell.item = View()
                    cell.item:backgroundColor(0xffffff)
                    cell.adsImg = Image(Native)
                    cell.title = Label()
                    cell.price = Label()
                    cell.car = Button(Native)

                    cell.car:frame(carX, carY, carSize, carSize)
                    cell.car:image("http://sdkcdn.videojj.com/images/android/sub_mall_car_icon.png")
                    cell.car:onClick(function()
                        local goodsItem = shelvesData.goods[row]
                        Native:addCart(tostring(goodsItem.sku_id), 1)
                    end)


                    cell.item:addView(cell.adsImg)
                    cell.item:addView(cell.title)
                    cell.item:addView(cell.price)
                    cell.item:addView(cell.car)
            end,
            Layout = function(cell, section, row) -- cell复用时调用
                local goodsItem = shelvesData.goods[row]
                cell.item:frame(0, 0, itemWidth, itemHeight)
                cell.item:align(Align.RIGHT)

                --广告图片
                cell.adsImg:frame(imgX, 0, imgSize, imgSize)
                cell.adsImg:align(Align.V_CENTER)
                cell.adsImg:image(goodsItem.image)
                    
                cell.title:textSize(12)
                cell.title:textColor(0x4A4A4A)
                cell.title:frame(titleX, titleY, 100, 20)
                cell.title:text(goodsItem.name)
                    
                cell.price:textColor(0xE9595E)
                cell.price:textSize(14)
                cell.price:frame(titleX, priceY, 100, 20)
                cell.price:text("￥" .. goodsItem.price)

            end,
            Callback = function(cell, section, row) -- 用户点击了section和row

                local goodsItem = shelvesData.goods[row]
                shelvesTable:hide()
                webViewTable:show()
                if webViewSuccess then
                    webView:callJS("setCurrentUrl", goodsItem.url)
                else
                    webView:loadUrl(goodsItem.url) 
                end

            end
        }
    end

    setmetatable(tableViewData.Cell, { __index = cellData })
    local tableView = CollectionView(tableViewData)
    tableView:backgroundColor(0x111111)
    -- tableView:reload()
    tableView:y(8 * scale)
    tableView:miniSpacing(7 * scale)
    tableView:size(rootWidth, listHeight - 8 * scale)
    return tableView
end


function shelvesTable:onCreate()
    if self.shelvesView == nil then
        if shelvesData.type ~= nil then
            goodsType = shelvesData.type
        end

        if goodsType == 0 then
            self.shelvesView = initDisplayWindowListView()
        else
            self.shelvesView = initShelvesList()
        end

        mainTable:addView(self.shelvesView)
    end
end

function shelvesTable:hide()
    if self.shelvesView then
        self.shelvesView:hide()
    end
end

function shelvesTable:show()
    if self.shelvesView then
        self.shelvesView:show()
    end
end


------------------ 导航栏布局-----------------------

--货架tab
function shelvesTabTable:onCreate(tabWidth)

    self.shelvesBtn = Button(Native)

    self.shelvesBtn:image("https://sdkcdn.videojj.com/images/ios/store/list_shelf_unselected@2x.png")
    self.shelvesBtn:selectedImage("https://sdkcdn.videojj.com/images/ios/store/list_shelf_selected@2x.png")

    self.shelvesBtn:size(tabWidth, tabHeight)
    self.shelvesBtn:align(Align.CENTER)

    self.shelvesTab = View()
    self.shelvesTab:size(tabWidth, tabHeight)
    self.shelvesTab:xy(0, 0)
    self.shelvesTab:align(Align.LEFT, Align.H_CENTER)

    self.shelvesBtn:onClick(function()
        shelvesTabTable:selected(true)
        orderTabTable:selected(false)
        carTabTable:selected(false)

        shelvesTable:show()
        webViewTable:hide()
        goLoginTable:hide()

    end)


    self.selected = function(self, selected)
        self.shelvesBtn:selected(selected)
    end

    self.unselected = function(self)
        self.shelvesBtn:selected(false)
    end

    self.shelvesTab:addView(self.shelvesBtn)
    -- 默认有一个被选中
    self:selected(true)
end

--订单tab
function orderTabTable:onCreate(tabWidth)

    self.orderBtn = Button(Native)

    self.orderBtn:image("https://sdkcdn.videojj.com/images/ios/store/list_goods_unselected@2x.png")
    self.orderBtn:selectedImage("https://sdkcdn.videojj.com/images/ios/store/list_goods_selected@2x.png")

    self.orderBtn:size(tabWidth, tabHeight)
    self.orderBtn:align(Align.CENTER)

    self.orderTab = View()
    self.orderTab:size(tabWidth, tabHeight)
    self.orderTab:xy(tabWidth, 0)

    self.orderBtn:onClick(function()
        shelvesTabTable:selected(false)
        orderTabTable:selected(true)
        carTabTable:selected(false)

        shelvesTable:hide()

        if isLogin then
            webViewTable:show()

            if webViewSuccess then
                webView:callJS("setCurrentUrl", orderUrl)
            else
                webView:loadUrl(orderUrl) 
            end
        else 
            goLoginTable:show()
            webViewTable:hide()
        end

    end)


    self.selected = function(self, selected)
        self.orderBtn:selected(selected)
    end

    self.unselected = function(self)
        self.orderBtn:selected(false)
    end

    self.orderTab:addView(self.orderBtn)
end

--购物车tab
function carTabTable:onCreate(tabWidth)

    self.carBtn = Button(Native)

    self.carBtn:image("https://sdkcdn.videojj.com/images/ios/store/list_cart_unselected@2x.png")
    self.carBtn:selectedImage("https://sdkcdn.videojj.com/images/ios/store/list_cart_selected@2x.png")

    self.carBtn:size(tabWidth, tabHeight)
    self.carBtn:align(Align.CENTER)

    self.number = Label()
    local numberSize = 14 * scale
    self.number:size(numberSize, numberSize)
    self.number:textColor(0xffffff)
    self.number:backgroundColor(0xE9595E)
    self.number:textSize(8)
    self.number:textAlign(TextAlign.CENTER)
    self.number:xy(tabWidth - 14 * scale - numberSize, 4 * scale)
    self.number:text("0")
    self.number:cornerRadius(numberSize / 2)

    --购物车tab
    self.carTab = View()
    self.carTab:size(tabWidth, tabHeight)
    self.carTab:xy(tabWidth * 2, 0)

    self.carBtn:onClick(function()
        shelvesTabTable:selected(false)
        orderTabTable:selected(false)
        carTabTable:selected(true)

        shelvesTable:hide()
        webViewTable:show()

        if webViewSuccess then
            webView:callJS("setCurrentUrl", shoppingCartUrl)
        else
            webView:loadUrl(shoppingCartUrl) 
        end

        goLoginTable:hide()

    end)

    self.selected = function(self, selected)
        self.carBtn:selected(selected)
    end

    self.unselected = function(self)
        self.carBtn:selected(false)
    end

    self.carTab:addView(self.carBtn)
    self.carTab:addView(self.number)
end

--底部导航tab
local function initTabView()
    --tab跟布局
    local tabLayout = View()
    tabLayout:size(rootWidth, tabHeight)
    tabLayout:align(Align.BOTTOM, Align.RIGHT)
    tabLayout:backgroundColor(0x282828)

    local tabWidth = rootWidth / 3

    shelvesTabTable:onCreate(tabWidth)
    orderTabTable:onCreate(tabWidth)
    carTabTable:onCreate(tabWidth)

    tabLayout:addView(shelvesTabTable.shelvesTab)
    tabLayout:addView(orderTabTable.orderTab)
    tabLayout:addView(carTabTable.carTab)

    return tabLayout
end

function hideGoodsPage()
    if hasGoods then
        if goodsType == 0 then --橱窗
            shelvesDisplayWindowTable:hide()
        else --列表
            shelvesListTable:hide()
        end
    else
        errorPageTable:hide()
    end
end

function showGoodsPage()
    if hasGoods then
        if goodsType == 0 then --橱窗
            shelvesDisplayWindowTable:show()
        else --列表
            shelvesListTable:show()
        end
    else
        errorPageTable:show()
    end
end

function mainTable:onCreate()
    self.mainPage = View()
    self.mainPage:xy(0, 0)
    self.mainPage:size(rootWidth, screenHeight)
    self.mainPage:align(Align.RIGHT)
    self.mainPage:backgroundColor(0x111111)

    self.addView = function(self, view)
        self.mainPage:addView(view)
    end

    self.removeView = function(self, view)
        view:removeFromSuper()
    end

    webViewTable:onCreate()

    local tabLayout = initTabView()
    self:addView(tabLayout)
    self:addView(webViewTable.webPage)

    loadingTable:onCreate()
    self:addView(loadingTable.loadingPage)


    loadShelvesData()
end


local function startShowAnimation(view)
    local x, y, width, height = view:frame();
    view:translationX(width)
    Animation():translation(0, 0):duration(0.3):with(view):interpolator(Interpolator.ACCELERATE_DECELERATE):callback(
        {
            onStart = function()
            end,
            onEnd = function()
            end
        }
    ):start()
end

local function startHideAnimation(view)
    local x, y, width, height = view:frame();
    view:translationX(0)
    Animation():translation(width, 0):duration(0.3):with(view):interpolator(Interpolator.ACCELERATE_DECELERATE):callback(
        {
            onStart = function()
                view:translationX(0)
            end,
            onEnd = function()
                totalControl.totalView:hide()
                Native:destroyView()
            end
        }
    ):start()
end

-- 初始化页面布局
function show(data)
    if totalControl.totalView == nil then

        totalView = View()
        totalView:frame(0, 0, screenWidth, screenHeight)

        totalControl.totalView = totalView

        local clickView = View()
        clickView:frame(0, 0, screenWidth, screenHeight)

        clickView:onClick(function()
            startHideAnimation(mainTable.mainPage)
        end)

        totalView:addView(clickView)

        mainTable:onCreate()
        totalView:addView(mainTable.mainPage)

        startShowAnimation(mainTable.mainPage)
    end


    if data ~= nil then
        if hasGoods then
            -- refresh data

        else
            -- no data
            if #data.data.goods == 0 then
                isError = true
                errorPageTable:show()
            else
                -- new data
                isError = false
                hasGoods = true
                shelvesData = data.data

                shelvesTable:onCreate()
                shelvesTable:show()

                shoppingCartUrl = shelvesData.h5_shopping_cart
                orderUrl = shelvesData.h5_orders

                isLogin = Native:getUserInfo() ~= nil
                print("login:" .. tostring(isLogin))
                webView:loadUrl(shoppingCartUrl)

                shelvesTabTable:selected(true)
                orderTabTable:selected(false)
                carTabTable:selected(false)

            end

        end


    end

end

function destory()

end



