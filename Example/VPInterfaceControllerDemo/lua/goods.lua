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
local shelvesTable = object:new()
local errorPageTable = object:new()
local shelvesListTable = object:new()
local shelvesTabTable = object:new()
local orderTabTable = object:new()
local carTabTable = object:new()
local entranceTable = object:new()
local mainTable = object:new()
local totalControl = object:new()
---------------------------- 公用变量定义-------------------

local ServerHost = "https://plat.videojj.com/"
local PreHost = "https://pre-plat.videojj.com/"
local TestHost = "https://test-plat.videojj.com/"
local DevHost = "https://dev-plat.videojj.com/"

local showType = "goods"
local Native = Native(showType,
    {
        Callback = {
            -- goodsData return
            updateCartCount = function(cartCount, totalCount)
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
            end,
            statusBarHidden = function()
            end
        }
    })

local function split(s, p)
    local rt= {}
    string.gsub(s, '[^'..p..']+', function(w) table.insert(rt, w) end )
    return rt
end

local stringVersion = System:osVersion()
local versionTable = split(stringVersion, ".")
local osVersion = tonumber(versionTable[1])

local screenWidth, screenHeight = System.screenSize()
local tempMaxSide = math.max(screenWidth, screenHeight)
local tempMinSide = math.min(screenWidth, screenHeight)
local localWidth, localHeight = Native:getVideoSize()
screenWidth = math.max(tempMaxSide, localWidth)
screenHeight = math.max(tempMinSide, localHeight)

local scale = screenHeight / 375

local rootWidth = math.floor(screenHeight * 200 / 375)
local tabHeight = math.floor(42 * scale)
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

local isShowAddCartSuccess = false

local shelfID = nil;

local SSID = Native:getSSID()
local videoID = Native:nativeVideoID()

-- webViewIsLarge false: listHeight true: rootHeight
local webViewIsLarge = false

-----------------http request--------------------------

function loadShelvesData()
        loadingTable:start()
        isLoaindg = true
        local isDebug = Native:isDebug()
        local debugType = type(isDebug)
        local host = nil
        if debugType == "boolean" then
            host = isDebug and TestHost or ServerHost
        else
            if isDebug == 0 then
                host = ServerHost
            elseif isDebug == 1 then
                host = PreHost
            elseif isDebug == 2 then
                host = TestHost
            else
                host = DevHost
            end
        end
        Native:get(
            host,
            "shelf/" .. Native:platformID(),
            {
                video = videoID
            },
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
    webView = VideoPlsWebView({
        Callback = {
            start = function()
            end,
            loadComplete = function(title, error)
                if error ~= nil then
                    -- need retry ? or bool to notice?
                    webViewSuccess = false
                else
                    webViewSuccess = true
                end
            end
        },
        JSCallMethodString = {
            method = function()
                return {"getUserInfo", "setUserInfo", "getCartData", "setCartData", "close", "screenChange", "getIdentity"}
            end
        },
        JSCallMethod = {
            getUserInfo = function()
                local userInfoJson = Native:getUserInfo()
                return userInfoJson
            end,
            setUserInfo = function(dict)
                Native:setUserInfo(dict)
            end,
            getCartData = function()
                local cartData = Native:getAllCartData()
                return cartData
            end,
            setCartData = function(dict)
                Native:updateCartData(dict)
            end,
            close = function(dict)
                -- dict is number value
                if dict == 1 then
                    shelvesTable:show()
                    webViewTable:hide()
                end
            end,
            screenChange = function(dict)
                local url = dict
                url = string.gsub(url, "#", "&ssid=" .. SSID .. "#", 1)
                Native:sendAction("GoodsList://" .. Native:base64Encode("openWebView"), url)
                if webView then
                    webView:destroyView()
                end
                Native:destroyView()
            end,
            getIdentity = function()
                local identityString = Native:getIdentity()
                local versionString = "0"
                if Native.getStoreVersion then
                    versionString = Native:getStoreVersion()
                end
                local dict = {
                                identity = identityString,
                                ssid = SSID,
                                ext = {screen = 0},
                                sdkVersion = versionString
                             }
                return dict
            end
        }
    })
    webView:progressColor("FFE9595E")
    webView:size(rootWidth, listHeight)
    webView:align(Align.RIGHT)
    return webView
end

function webViewTable:sizeChange(isLarge)
    webViewIsLarge = isLarge
    if isLarge then
        self.webPage:frame(0, 0, rootWidth, screenHeight)
        webView:frame(0, 0, rootWidth, screenHeight)
    else
        self.webPage:frame(0, 0, rootWidth, listHeight)
        webView:frame(0, 0, rootWidth, listHeight)
    end
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
        webView:loadUrl("")
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
--去登录按钮
local function goLoginBtn()
    local login = Button(Native)
    local loginWidth =  128 * scale
    local loginHeight = 35 * scale
    login:size(loginWidth, loginHeight)
    login:xy(0, 142 * scale)
    login:align(Align.H_CENTER)
    login:backgroundColor(0x272727)
    login:borderWidth(1)
    login:textSize(12)
    login:textColor(0xDDDDDD)
    login:borderColor(0x5c5c5c)
    login:onClick(function()
        local url = string.reverse(string.gsub(string.reverse(orderUrl), "1=etil", "0=etil", 1))
        url = string.gsub(url, "#", "&ssid=" .. SSID .. "#", 1)
        Native:sendAction("GoodsList://" .. Native:base64Encode("openWebView"), url)
        if webView then
            webView:destroyView()
        end
        Native:destroyView()
    end)
    login:title("去登录")
    return login
end

--提示文字
local function loginTip1()
    local tipTxt = Label()
    tipTxt:textColor(0x919191)
    tipTxt:textSize(10)
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
    tipTxt:textSize(10)
    tipTxt:xy(0, 210 * scale)
    tipTxt:size(190 * scale, 30 * scale)
    tipTxt:textAlign(TextAlign.CENTER)
    tipTxt:align(Align.H_CENTER)
    local ss1 = StyledString("您将进入 ", { fontColor = 0x919191, fontSize = 10 })
    local ss2 = StyledString("竖屏观看", { fontColor = 0xE9595E, fontSize = 10 })
    local ss3 = StyledString(" 哦", { fontColor = 0x919191, fontSize = 10 })
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
        self.goLoginPage:backgroundColor(0x3B3B3B)
        self.goLoginPage:addView(goLoginBtn())
        self.goLoginPage:addView(loginTip1())
        self.goLoginPage:addView(loginTip2())
        mainTable:addView(self.goLoginPage)
    end
end

function goLoginTable:show()
    self:onCreate()
end
----------------------------货架---------------------------------------------
------------------------- 筹备中页面------------------------------------------
-- 筹备图片
local function arrangeImg()
    local img = Image(Native)
    local imgWidth = 80 * scale
    local imgHeight = imgWidth * 57 / 80
    img:image("https://sdkcdn.videojj.com/images/ios/store/arranging@2x.png")
    img:frame(60 * scale, 103 * scale, imgWidth, imgHeight)
    img:align(Align.H_CENTER)
    return img
end

-- 筹备文字
local function arrangeLabel()
    local waitLabel = Label()
    waitLabel:xy(0, 197 * scale)
    local waitWidth = 124 * scale
    local waitHeight = 14 * scale
    waitLabel:xy(38 * scale, 180 * scale)
    waitLabel:size(waitWidth, waitHeight)
    waitLabel:textSize(10)
    waitLabel:text("好货正在筹备 晚点再来看吧")
    waitLabel:textColor(0x919191)
    waitLabel:textAlign(TextAlign.CENTER)
    waitLabel:align(Align.H_CENTER)
    return waitLabel
end

function initArrangePageView()
    local arrangeView = View()
    arrangeView:xy(0, 0)
    arrangeView:size(rootWidth, listHeight)
    arrangeView:addView(arrangeImg())
    arrangeView:addView(arrangeLabel())
    return arrangeView
end

--------------------------详情页---------------------------------
local function openItemWebView(goodsItem)
    webViewTable.webPage:bringToFront()
    webViewTable:sizeChange(true)
    webViewTable:show()
    local url = goodsItem.url
    if osVersion == 8 then
        url = string.gsub(url, "#", "&width=" .. rootWidth .. "#", 1)
    end
    webView:loadUrl(url)
    -- 打开详情页Track
    Native:trackApi(9,
                    {
                        vid = videoID,
                        tid = shelfID .. "_" .. goodsItem.sku_id,
                        ptid = shelfID .. "_productTab",
                        ssid = SSID,
                        ext = "{\"screen\":\"0\"}"
                    })
end

local function addCart(goodsItem, number)
    Native:addCart(goodsItem, number)
    -- 加入购物车Track
    Native:trackApi(9,
                    {
                        vid = videoID,
                        tid = shelfID .. "_addToCartButton",
                        ptid = shelfID .. "_" .. goodsItem.sku_id,
                        ssid = SSID,
                        ext = "{\"screen\":\"0\"}"
                    })

end
--------- 商品货架：全屏橱窗样式  Display window--------------
--橱窗商品列表
local function initDisplayWindowListView()
    local view = ShelvesCardView(Native, shelvesData, 
    {
        Callback = {
            itemOnClick = function(selectedIndex)
                local goodsItem = shelvesData.goods[selectedIndex]
                openItemWebView(goodsItem)
            end,
            itemOnAddCart = function(selectedIndex)
                local goodsItem = shelvesData.goods[selectedIndex]
                addCart(goodsItem, 1)
            end,
            itemOnImmediatelyBuy = function(selectedIndex)
                -- 只是进商详
                local goodsItem = shelvesData.goods[selectedIndex]
                openItemWebView(goodsItem)
            end
        }
    })
    view:xy(0, 0)
    view:size(rootWidth, listHeight)
    view:initView()
    return view
end

-------------------- 列表样式的货架--------------------------
local function initShelvesList()
    local data = shelvesData
    local goods = data.goods
    local count = table.getn(goods)
    local itemWidth = 194 * scale
    local itemHeight = 74 * scale
    local imgSize = 60 * scale
    local imgX = 4 * scale
    local titleX = 71 * scale
    local titleY = 5 * scale
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
            Size = function(section, row)
                return itemHeight
            end,
            Init = function(cell, section, row) -- 初始化cell
                cell.item = View()
                    cell.item:backgroundColor(0xE7E7E7)
                    cell.adsImg = Image(Native)
                    cell.title = Label()
                    cell.title:lineCount(2)
                    cell.title:ellipsize(4)
                    cell.price = Label()
                    cell.car = Button(Native)
                    cell.car:frame(carX, carY, carSize, carSize)
                    cell.car:image("http://sdkcdn.videojj.com/images/android/sub_mall_car_icon.png")
                    cell.car:onClick(function()
                        local goodsItem = shelvesData.goods[row]
                        addCart(goodsItem, 1)
                        shelvesTable:addCartSuccess()
                    end)
                    cell.item:addView(cell.adsImg)
                    cell.item:addView(cell.title)
                    cell.item:addView(cell.price)
                    cell.item:addView(cell.car)
            end,
            Layout = function(cell, section, row) -- cell复用时调用
                local goodsItem = shelvesData.goods[row]
                cell.item:frame(0, 6 * scale, itemWidth, itemHeight - 6 * scale)
                cell.item:align(Align.RIGHT)
                --广告图片
                cell.adsImg:frame(imgX, 0, imgSize, imgSize)
                cell.adsImg:align(Align.V_CENTER)
                cell.adsImg:image(goodsItem.image)
                    
                cell.title:textSize(10)
                cell.title:textColor(0x4A4A4A)
                cell.title:frame(titleX, titleY, 96 * scale, 30 * scale)
                cell.title:text(goodsItem.name)
                    
                cell.price:textColor(0xE9595E)
                cell.price:textSize(14)
                cell.price:frame(titleX, priceY, 100 * scale, 20 * scale)
                cell.price:text("￥" .. goodsItem.price)
            end,
            Callback = function(cell, section, row) -- 用户点击了section和row
                local goodsItem = shelvesData.goods[row]
                openItemWebView(goodsItem)
            end
        }
    end

    setmetatable(tableViewData.Cell, { __index = cellData })
    local tableView = CollectionView(tableViewData)
    tableView:backgroundColor(0x3B3B3B)
    tableView:miniSpacing(1 * scale)
    tableView:size(rootWidth, listHeight)
    local contentView = View()
    contentView:size(rootWidth, listHeight)
    contentView:addView(tableView)
    return contentView
end

function shelvesTable:onCreate()
    if self.shelvesView == nil then
        if shelvesData.type ~= nil then
            goodsType = shelvesData.type
        end
        if #shelvesData.goods == 0 then
            self.shelvesView = initArrangePageView()
        else
            if goodsType == 0 then
                self.shelvesView = initDisplayWindowListView()
            else
                self.shelvesView = initShelvesList()
            end
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

function shelvesTable:onCreateAddCartSuccess()
    if self.addOnCartSuccessView == nil then
        local addCartSuccessView = View()
        addCartSuccessView:frame(0, 299 * scale, 100 * scale , 24 * scale)
        addCartSuccessView:cornerRadius(12 * scale)
        addCartSuccessView:backgroundColor(0x000000, 0.6)
        self.addOnCartSuccessView = addCartSuccessView
        self.shelvesView:addView(self.addOnCartSuccessView)
        self.addOnCartSuccessView:align(Align.H_CENTER)
        local label = Label()
        label:xy(0, 0)
        label:size(100 * scale, 24 * scale)
        label:textColor(0xffffff)
        label:text("加入购物车成功")
        label:textAlign(TextAlign.CENTER)
        label:textSize(11)
        self.addOnCartSuccessView:addView(label)
        self.addOnCartSuccessView:alpha(0)
    end
end

function shelvesTable:addCartSuccess()
    self:onCreateAddCartSuccess()
    if isShowAddCartSuccess then
        return
    end
    isShowAddCartSuccess = true
    self.addOnCartSuccessView:show()
    Animation():alpha(1):duration(0.4):with(self.addOnCartSuccessView):callback(
        {
            onStart = function()
            end,
            onEnd = function()
                Animation():alpha(0):duration(0.4):delay(2):with(self.addOnCartSuccessView):callback(
                    {
                        onStart = function()
                        end,
                        onEnd = function()
                            self.addOnCartSuccessView:alpha(0)
                            self.addOnCartSuccessView:hide()
                            isShowAddCartSuccess = false
                        end
                    }
                ):start()
            end
        }
    ):start()
end
------------------ 导航栏布局-----------------------
--货架tab
function shelvesTabTable:onCreate(tabWidth)
    self.shelvesTab = View()
    self.shelvesTab:size(tabWidth, tabHeight)
    self.shelvesTab:xy(0, 0)
    self.shelvesTab:align(Align.LEFT, Align.H_CENTER)

    self.shelvesBtn = Button(Native)
    self.shelvesBtn:image("https://sdkcdn.videojj.com/images/ios/store/list_shelf_unselected@2x.png")
    self.shelvesBtn:selectedImage("https://sdkcdn.videojj.com/images/ios/store/list_shelf_selected@2x.png")
    self.shelvesBtn:size(tabWidth, tabHeight)
    self.shelvesBtn:align(Align.CENTER)
    self.shelvesBtn:onClick(function()
        shelvesTabTable:selected(true)
        orderTabTable:selected(false)
        carTabTable:selected(false)
        if isError then
            return
        end
        shelvesTable:show()
        webViewTable:hide()
        goLoginTable:hide()

        if isLoaindg then
            return
        end
        -- 货架tab 点击track
        Native:trackApi(9,
                        {
                            vid = videoID,
                            tid = "productTab",
                            ptid = shelfID,
                            ssid = SSID,
                            ext = "{\"screen\":\"0\"}"
                        })

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
    self.orderTab = View()
    self.orderTab:size(tabWidth, tabHeight)
    self.orderTab:xy(tabWidth, 0)

    self.orderBtn = Button(Native)
    self.orderBtn:image("https://sdkcdn.videojj.com/images/ios/store/list_goods_unselected@2x.png")
    self.orderBtn:selectedImage("https://sdkcdn.videojj.com/images/ios/store/list_goods_selected@2x.png")
    self.orderBtn:size(tabWidth, tabHeight)
    self.orderBtn:align(Align.CENTER)
    self.orderBtn:onClick(function()
        shelvesTabTable:selected(false)
        orderTabTable:selected(true)
        carTabTable:selected(false)
        if isError then
            return
        end

        shelvesTable:hide()

        if isLoaindg then
            return
        end
        
        if isLogin then
            webViewTable:sizeChange(false)
            webViewTable:show()
            webView:loadUrl(orderUrl)
        else 
            goLoginTable:show()
            webViewTable:hide()
        end
        -- 订单tab 点击track
        Native:trackApi(9,
                        {
                            vid = videoID,
                            tid = "myOrderTab",
                            ptid = shelfID,
                            ssid = SSID,
                            ext = "{\"screen\":\"0\"}"
                        })
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
    self.carTab = View()
    self.carTab:size(tabWidth, tabHeight)
    self.carTab:xy(tabWidth * 2, 0)

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

    self.carBtn = Button(Native)
    self.carBtn:image("https://sdkcdn.videojj.com/images/ios/store/list_cart_unselected@2x.png")
    self.carBtn:selectedImage("https://sdkcdn.videojj.com/images/ios/store/list_cart_selected@2x.png")
    self.carBtn:size(tabWidth, tabHeight)
    self.carBtn:align(Align.CENTER)
    self.carBtn:onClick(function()
        shelvesTabTable:selected(false)
        orderTabTable:selected(false)
        carTabTable:selected(true)
        if isError then
            return
        end
        shelvesTable:hide()
        webViewTable:show()
        webViewTable:sizeChange(false)
        webView:loadUrl(shoppingCartUrl)
        goLoginTable:hide()
        if isLoaindg then
            return
        end
        -- 购物车tab 点击track
        Native:trackApi(9,
                        {
                            vid = videoID,
                            tid = "shoppingCartIcon",
                            ptid = shelfID,
                            ssid = SSID,
                            ext = "{\"screen\":\"0\"}"
                        })
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

function mainTable:onCreate()
    self.mainPage = View()
    self.mainPage:xy(0, 0)
    self.mainPage:size(rootWidth, screenHeight)
    self.mainPage:align(Align.RIGHT)
    self.mainPage:backgroundColor(0x3B3B3B)
    self.addView = function(self, view)
        self.mainPage:addView(view)
    end
    self.removeView = function(self, view)
        view:removeFromSuper()
    end
    webViewTable:onCreate()
    self.tabLayout = initTabView()
    self:addView(self.tabLayout)
    self:addView(webViewTable.webPage)
    loadingTable:onCreate()
    self:addView(loadingTable.loadingPage)
    loadShelvesData()
end

local function startShowAnimation(view)
    local x, y, width, height = view:frame();
    view:translationX(width)
    Animation():translation(0, 0):duration(0.3):with(view):interpolator(Interpolator.ACCELERATE_DECELERATE):callback():start()
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
                view:translationX(width)
                totalControl.totalView:alpha(0)
                totalControl.totalView:hide()

                if webView then
                    webView:destroyView()
                end
                Native:destroyView()
            end
        }
    ):start()
    Animation():alpha(0):duration(0.01):with(view):delay(0.29):callback():start()
end

-- 初始化页面布局
function show(data)
    if totalControl.totalView == nil then
        local totalView = View()
        totalView:frame(0, 0, screenWidth, screenHeight)
        totalControl.totalView = totalView

        local clickView = View()
        clickView:frame(0, 0, screenWidth, screenHeight)
        clickView:onClick(function()
            startHideAnimation(mainTable.mainPage)
        end)
        totalControl.clickView = clickView

        totalView:addView(clickView)
        mainTable:onCreate()
        totalView:addView(mainTable.mainPage)
        startShowAnimation(mainTable.mainPage)
        -- 货架展示Track
        Native:trackApi(9,
                        {
                            vid = videoID,
                            tid = "",
                            ptid = "",
                            ssid = SSID,
                            ext = "{\"screen\":\"0\"}"
                        })
    end

    if data ~= nil then
        if hasGoods then
            -- refresh data
        else
            -- new data
            isError = false
            hasGoods = true
            shelvesData = data.data
            shelfID = shelvesData.shelfId;
            
            shelvesTable:onCreate()
            shelvesTable:show()

            shoppingCartUrl = shelvesData.h5_shopping_cart
            orderUrl = shelvesData.h5_orders

            if osVersion == 8 then
                shoppingCartUrl = string.gsub(shoppingCartUrl, "#", "&width=" .. rootWidth .. "#", 1)
                orderUrl = string.gsub(orderUrl, "#", "&width=" .. rootWidth .. "#", 1)
            end

            isLogin = Native:getUserInfo() ~= nil
            webViewTable:sizeChange(false)
            shelvesTabTable:selected(true)
            orderTabTable:selected(false)
            carTabTable:selected(false)

            -- 货架请求成功Track
            Native:trackApi(12,
                            {
                                vid = videoID,
                                tid = shelfID,
                                ptid = "",
                                ssid = SSID,
                                ext = "{\"screen\":\"0\"}"
                            })

        end
    end
end
