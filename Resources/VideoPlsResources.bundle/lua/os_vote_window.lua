--
-- Created by IntelliJ IDEA.
-- User: videojj_pls
-- Date: 2018/10/29
-- Time: 2:36 PM
-- To change this template use File | Settings | File Templates.
--
require "os_config"
require "os_string"
require "os_constant"
require "os_util"
require "os_track"
voteWindow = object:new()
local adTypeName = "voteWindow"
local scale = getScale()
local OS_ICON_WEDGE_CLOSE = "iVBORw0KGgoAAAANSUhEUgAAAE8AAABPCAYAAACqNJiGAAAABHNCSVQICAgIfAhkiAAADc5JREFUeJzdnGtzFNcRhp/Rru5C3AwGDAZsjIIvEJOyq+KKU+Wq5Kfkl9r+wAdSYGIFLBOELXETEhK6X08+vN06s6OZ3dnVrCTcVacWLTOzc97py3tOd08SQvgX0A/82cYQMAVMA/8G7gA/AdvAVpIkgT+YhBCGgRPAReCvNs4jLIaB74EfgPvAa2AmSZKNOgJuAOgFakCP/bvPvh+ysQ4EYOvAZtVlCSEkQILmO4jm6VjUbfTYp2NSs3OoI23rBS4DJ+1k7EI7dsxJ4CnwNIQwD+y86xoYQuhBYPQBV4AvgOvAJwiLE0TAzgEfAUvIAueAdQevhgA6aQcPAWfQ0zgBvI/Mdx54izTwnQYPzXkAmeVlZKq3gNPAe8gie2ycR3NfBt4AT0BaNWQHDBBNdSD1I/12zFuEOMBcCGEB4F3TQNO4GnAMgXIO+NTGdTT3QTvGpd/GHrOdQuoJ0eZdBpA2Anxun6eAB+gp7IQQ3hkTNh/nCnIeuGljzP4eRJgkmVNXUKB4gZRoCztwmkZTTcsAQnzE/j4OjCIN/NXviXfHhB28YaRxN4F/ILd0EoGXBQ4awVtEfo86oiMDKDgM2sFuuj32dx9RA9eAZyj6vgReWhAJR1UDQwg1NNdBFBwuIzMdQ8AdJ/o4lxVgwcYE8D9kpfOkNO8O0ro6Cg79CKj+1IUS9LRqCPUl5DPu24UWEfjbFc65SnHffgIB9hUC7xL5wIHm+BswCYwjAKeQu9oF7ye78En0FIbs5BGkcYld2Pmef3fWLvIKqfR6CGE9SZIjA2CKxzlruAD8CfgagehzcuACUgCnI5PAPeAhMJkkyYv09et24DricXeQQ/TgcBJp3FDmnBN2UzeQGY8SeeASR8CEc3jcGALuc/TgB1GgTPu4DWDGxi8IuHsoLixlf6OOtCegyc8T6chx+6zRCF4vAm8Ygd5vf9eRBq6iB3LY/i/L475CGnfWRtqnu2ygoPALYhQO3qqNBqmbhmyZ039r359C2rSGgOgjLlFqqRs7n/reeWA/MH9YPLAFjxtDGudLMJc1FCBeAY8RcOPAk6yppqWe+vcO0pY5O3kORdUlpNonbKTJ4zDRJ24gPzkO/GzjMHig065LwG0b14Crdn91GucAWjU8tuHaNkW0wlzZBc8mGExjlhGPW0dP8Cwx4qZJtDvcYbtpX9LNA4+ILuEgwetlL497z74bLDhngUbg7iVJMt/qh+oF3+/Y50siHbmBwDzP3iBSQ0/1LHrKC/b9NDAdQpili0HEeFyvjY/tXj9Fi/xR5Eqy2raKNGsOWcs9+3yBrKil7AEvSZIQQnATfkmkI2t2E758yYJ3zP7fqcpx4K6dN093g0g6OFwDvkXgnSeClw0Oq+jhPkZ07R6ytiU6BQ8aTHgeEeDXdhO+TdNDJM0+Bolm4bs0q8CsXWMxhLBcJQ+04JAgrT+DzHMM7RR9krqnNI/bsPEK7Y78hPzzr0mSTLXz+0Vmu3t/yISdB9ZRVN1APm4EaVzal/QRqcsNYBMB/1/gcQhhnQr2Aw043+m4iDTtM/tNpyLZRf424nAv2Bsc9vC4VtIUPJvgtk34KdLAOeKTPmsTyAPvGAJ5GGnhit3kJtUEEV/kjyDwbgPfIZrlgSu7yHfwsjxuESlIW9JK83SXSbJtK4dVBNa43dw1oo9zNu9mDDIjn8AzpLXPgdlONxMsOHiAumjjFjLXy8SHmQ4QK0iz5ojAjaO161ySJKV8XFZKgef3jYCaRz5inhhVa+TzwKHUuV8iU3IOuEhnPLDXrnMGmeptBNxHxA2ObHBYIC7yXdueIDA79sGlwcvwwJ8RjwNF1ZN2rWOZ09I8MEEbD76Me2LH7NCeOI97D/m475DG+e/kyQKNwN1rtnIoK+1oXlp2EIWZRnRkFTnqDTQpB82lhkAOaKt7EZnXNDAVQnhLExPO4XHX0CL/BvJxTqHSksfjHthv7lmndiJtg5fhgdOIx82iQOAaBnvBG0Xmtk4087vIFy3TnAdmeZwnay4g8AbIJ8FZHjduv3c44EGDCc8i37eIwPHd5sBeHuja6BsNxxBoMwjQ5SwPtP24HmJ0P4M07hZaejmPSwO3YdfL8riJJEl+62S+RdKp2bp4EFlEPG4FRdUvkQZ6ziOthYPItGsIvH7gA+RDH4UQ1oh+0CPnVQTWLUR+P7RrZvfjQA/jKdr5dR/3jBaL/E5kX+ClNHAZmccUoiMDKDgEYtWBS1FSaQ059Q2i+WZ53D+Rxo5SnKxxOnKfCJ67hUplv5oH7PLAdeT3niMzqaPgsI5u3PfRipJKb+zzOfKhK0jDriGtu0ZMRjdL1owj4B4ijVtOkmSzinlmpRLwTDyIzCLwXiNzriGgfOIu2aTSJtLQX5DJvUTR9G80mqrX06QlnaxxbZtEYHYtp1IZeDmbCU+IW/THiKuCoqRSLyp1cHPuQzzuG2S26Y0HKE7WPADGkyR5VdXciqRKzXPxzQSIPHDZBhQnlUbt31sIwFm0cijicc2SNZVQkVZSOXgpHrhD3K2YQQA0Syp5VB5FK4YNpLEnkBbuK1nTDemG5u0mfWzlsIyCxge0TipBXHpBjKbpqOrgtJWs6YZ0BbyUuF9aRjzOo+omUdtG2bs6yKMgLnPINJ8Qte03usDjWklXwcvwwEfIqa8h8zxthw3ln10oczQuue6xz92RTqXbmgfs8sA15KeeIz81goLDKI27IXlat23HbiEKM4F43DSw2Ol+3H7lQMAzSfPACftuBAWH9KZpnmwjjXUS7eC9oWSyphtykOC5rCDt6UNAlpn8DvKTa4j4ztg11ml/P7AyORDwLFnjZbsfo+Lpz20cp7nWQczO1dCS7+923mOUVFrkEIrMD0rzEuJmwGXgL2hP7jSRHDcT38/rQzssnm4Ecb1lDqFCtavgZZI1V9Ey6wu0Vr1IBCSbHtxG5ujnO0H2fLD7zzdoF2cSJZW6WpmQlW5rXjpZc5NYdHOJ4mTNFvJtm8TK9LSkk0rLxDWxJ6UOrLjoIMDzFUPZohsHb41o7tmMXKviogMJIpWDV5CsGaN80c1LREcWkKlfR6aal1QqKi6abJVUqkK6oXl5yZqbaD+uTNHNhI0ZVM3ZR9SkssVF3q3T1QrVysBrUnTjjSJuqq2Kbh7aeIm09wwxkpYtLvqdgqRSlVIJeC2Kbi6Q31lTVHQzjaKo18f8aH8vU764aAntAzoPrKS4KCtVaV6zoptTNGqcS7Oimw1kqk+RH3xL1MIyxUV9yEVsUW1xUYPsC7ySRTde6uVSuugmVVw0iehI2eIiX855kfq+iouKZL+al+ZxnxGLbq4SeVw2srZTdOP7gZ5UKltcdAZp3TrVFBflShXgDRPB+46Y5dp30U1OZUI7xUWeH66iuChX2gYv1VmTV3TjneJFyZpOi248qdROcVEv+yguKiOdaJ4nb4ZRVP0W1QB7LUlecPDImc7kj1MyWZNJKk0iLfwd+U7ngWfI71QaQQCOoMh/B/ndZfbZbFgavExnzSVUaf4pevrXiBUBaf+TTtZMEDP5k+3mVQuSSt6ptIm00jt7skml94nkPd2xvmD1htudaGAp8HI6pG8Ti26cx+UV3eQla54RnX4nkk4qPUagzRP74I6zN4gUdaw/srHWSRApq3nZDul2im6yyZp9Fd2ULC4ayZxWtrioOvByOqSvIFNtp+jG6+MqLbppUVwUEJCtOta9uGgKdSq1xQNbaV62Q/pr5OO8eLps0c0E3UkPFhUXjRDXumWKix4gENvqWM8Fr0SHdHY/rlXRTaUVmS5NiosuEBsMyxQXgR54Wx3re8Br0iH9BY2dNWlpq0O6C5ItLirbse75kzH00NvqWM/TvPR+3BWkbdkO6eyS61CLbnKKi1Yo17HuxUW+cdBWx/oueE06pG+gJ+PON90hfWSKbnJ4IJTrWIcYpdvqWK/bD+a96eYWilwfEnlcNjgcmaKblLgJL1C+uGgA+T4vTu9BZP4RTd5c5JqX5XG3iG+6cdUuy+MOpejGJdVs6OBN0rq4yFOgnlg/hbBYosmbi+r24r1eGnncdYrfdONPMsvjpjjEopsc8fqWDXRvD+z7MaSFWR7oVQ2nkKIsElcuuW8u8nekDKJo+g1x69zf7pM11RX2vszAO6TbbrvslhR0KrlLcS06TWPVqbd5OQ3zd+fdtdHAA+to93cYPRFfr7bqkHbgxumgQ/qgpETHerrFoVlSaQmtYl4DqyGE1SRJduooNTiAlly+1Z1d5Bcla15wMDxuv1LUse6tDqdo1DhoTCpdQa5sBc35BbDm4PlrL08jIMt2SLs2Hmlp0rHeQ/Rx2VaFdFLpCpq/b2rMYuBdoPENZmU6pKfKvHfkqElOx/pD5LIWU4flJZWOETOBuy/u8oW/d+m00yH9rkq6Y/0RUo55ImB5SaUaMd25y3cdvB7ySXBXOqQPU5q8uegcxUmlOo0rrN13hn5vn+fQ6qIfmesK2koaJxZPH0hzyAFK+s1F3jh9xYa3fNWJ78fyMpAN7D9+QGh+hNS3HznU1+hVjxNI+yrrkD4KkvPmoruIjlxHwcHbtjzv+x9iAdIuePeRvXu7eh8xHE+h4PBOm2qRFPBAz6x5mcgA0rgJlLFbJfXay9fEndU39m/nQF6q9UcX54GrSGm2iZ3kvUgzZ4jABYAkhOC7rH5gYgfsNo4cpfeAdlMyCX1f7yZEPrvFEXil5x9C/g8Xlid2yMH3cQAAAABJRU5ErkJggg=="
local OS_ICON_PRELOAD = "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"
local OS_NO_LOGIN_INFO = "您还未登录,请先登录"

local function getHotspotExposureTrackLink(data, index)
    if (data == nil or index == nil) then
        return nil
    end
    local hotspotTrackLinkTable = data.infoTrackLink
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
    local hotspotTrackLinkTable = data.infoTrackLink
    if (hotspotTrackLinkTable == nil) then
        return nil
    end
    local indexHotspotTrackLinkTable = hotspotTrackLinkTable[index]
    if (indexHotspotTrackLinkTable == nil) then
        return nil
    end
    return indexHotspotTrackLinkTable.clickTrackLink
end

local function closeView()
    Native:widgetEvent(eventTypeClose, voteWindow.id, adTypeName, actionTypeNone, "")
    Native:destroyView()
end

local function mathPercent(num)
    if (type(num) ~= 'number' or type(num) == 'inf') then
        return 0, "0.0%"
    end
    if (num == 0 or num == 0.0 or tostring(num) == "inf") then
        return 0, "0.0%"
    end
    local floorNum = math.floor(num * 1000 + 0.5) * 0.1
    local percentNum = math.floor(floorNum)
    if (percentNum < floorNum) then
        return percentNum, floorNum .. "%"
    else
        return percentNum, floorNum .. ".0%"
    end
end

local function calculateVoteCount()

    local len = 0
    if voteWindow.voteCount ~= nil then
        for k, v in pairs(voteWindow.voteCount) do
            len = len + v
        end
    end

    voteWindow.totalVote = len
    if voteWindow.totalVote == 0 then
        voteWindow.totalVote = 1
    end
end

local function translationAnim(x, y)
    local anim = Animation():translation(x, y):duration(0.3)
    return anim
end

local function startViewTranslationAnim(view, x, y, table)
    if (view == nil) then
        return nil
    end
    if table ~= nil then
        return translationAnim(x, y):with(view):callback(table):start()
    else
        return translationAnim(x, y):with(view):start()
    end
end

local function getUserVoteInfo(callback)

    local businessInfo = {
        userId = Native:getIdentity(),
        creativeId = voteWindow.data.creativeId
    }

    local paramData = {
        businessParam = businessInfo,
        commonParam = Native:commonParam()
    }

    local paramDataString = Native:tableToJson(paramData)
    --     print("==[LuaView] "..userInfoTable.uid)
    -- print("[LuaView] "..OS_HTTP_GET_MOBILE_QUERY)
    -- print("[LuaView] "..Native:aesEncrypt(paramDataString, OS_HTTP_PUBLIC_KEY, OS_HTTP_PUBLIC_KEY))
    Native:post(OS_HTTP_GET_MOBILE_QUERY, {
        bu_id = buId,
        device_type = deviceType,
        data = Native:aesEncrypt(paramDataString, OS_HTTP_PUBLIC_KEY, OS_HTTP_PUBLIC_KEY)
    }, function(response, errorInfo)
        voteWindow.loadingCount = voteWindow.loadingCount - 1
        if voteWindow.loadingCount <= 0 then
            voteWindow.voteLoadingView:hide()
        end

        if (response == nil) then
            voteWindow.voteErrorView:show()
            return
        end
        -- print("luaview getUserVoteInfo 11"..Native:tableToJson(response))
        responseData = Native:aesDecrypt(response.encryptData, OS_HTTP_PUBLIC_KEY, OS_HTTP_PUBLIC_KEY)
        print("luaview " .. responseData)
        response = toTable(responseData)
        if (response.resCode ~= "00") then
            voteWindow.voteErrorView:show()
            return
        end
        local dataTable = response.businessInfo
        if (dataTable == nil) then
            local showLinkUrl = getHotspotExposureTrackLink(voteWindow.data, 1)
            if (showLinkUrl ~= nil) then
                Native:get(showLinkUrl)
            end
            if (voteWindow.launchPlanId ~= nil) then
                osTrack(voteWindow.launchPlanId, 2, 1)
            end
            if callback ~= nil then
                callback()
            end
            return
        end
        if dataTable.isVote == true then
            voteWindow.section = dataTable.vote
            showVoteResult()
        else
            local showLinkUrl = getHotspotExposureTrackLink(voteWindow.data, 1)
            if (showLinkUrl ~= nil) then
                Native:get(showLinkUrl)
            end
            if (voteWindow.launchPlanId ~= nil) then
                osTrack(voteWindow.launchPlanId, 2, 1)
            end
        end
    end)
end

local function postUserVoteInfo(voteIndex)

    local businessInfoTable = {
        isVote = true,
        vote = voteIndex
    }
    local businessParamTable = {
        userId = Native:getIdentity(),
        creativeId = voteWindow.data.creativeId,
        businessInfo = businessInfoTable
    }

    local paramData = {
        businessParam = businessParamTable,
        commonParam = Native:commonParam()
    }

    local paramDataString = Native:tableToJson(paramData)
    print("[LuaView] " .. paramDataString)
    print("[LuaView] " .. OS_HTTP_POST_MOBILE_QUERY)
    print("[LuaView] " .. Native:aesEncrypt(paramDataString, OS_HTTP_PUBLIC_KEY, OS_HTTP_PUBLIC_KEY))
    Native:post(OS_HTTP_POST_MOBILE_QUERY, {
        bu_id = buId,
        device_type = deviceType,
        data = Native:aesEncrypt(paramDataString, OS_HTTP_PUBLIC_KEY, OS_HTTP_PUBLIC_KEY)
    }, function(response, errorInfo)
        print("luaview postUserVoteInfo")
        if (response == nil) then
            return
        end
        print("luaview postUserVoteInfo 11" .. Native:tableToJson(response))
        responseData = Native:aesDecrypt(response.encryptData, OS_HTTP_PUBLIC_KEY, OS_HTTP_PUBLIC_KEY)
        print("luaview " .. responseData)
        response = toTable(responseData)
        if (response.resCode ~= "00") then
            return
        end
        local dataTable = response.launchInfoList
        if (dataTable == nil) then
            return
        end
    end)
end

local function getVoteCountInfo()

    local businessInfoTable = {}
    for k, v in pairs(voteWindow.data.data.voteList) do
        businessInfoTable[k] = {
            action = "count",
            condition = {
                {
                    key = "vote",
                    value = k,
                    operator = "equal"
                }
            }
        }
    end

    local businessParamTable = {
        creativeId = voteWindow.data.creativeId,
        businessInfo = businessInfoTable
    }

    local paramData = {
        businessParam = businessParamTable,
        commonParam = Native:commonParam()
    }

    local paramDataString = Native:tableToJson(paramData)
    print("[LuaView] " .. paramDataString)
    print("[LuaView] " .. OS_HTTP_GET_COMMON_QUERY)
    --print("[LuaView] "..Native:aesEncrypt(paramDataString, OS_HTTP_PUBLIC_KEY, OS_HTTP_PUBLIC_KEY))
    Native:post(OS_HTTP_GET_COMMON_QUERY, {
        bu_id = buId,
        device_type = deviceType,
        data = Native:aesEncrypt(paramDataString, OS_HTTP_PUBLIC_KEY, OS_HTTP_PUBLIC_KEY)
    }, function(response, errorInfo)
        print("luaview getVoteCountInfo")

        voteWindow.loadingCount = voteWindow.loadingCount - 1
        if voteWindow.loadingCount <= 0 then
            voteWindow.voteLoadingView:hide()
        end

        if (response == nil) then
            voteWindow.voteErrorView:show()
            return
        end
        print("luaview getVoteCountInfo 11")
        print("luaview getVoteCountInfo 11" .. Native:tableToJson(response))
        responseData = Native:aesDecrypt(response.encryptData, OS_HTTP_PUBLIC_KEY, OS_HTTP_PUBLIC_KEY)
        print("luaview " .. responseData)
        response = toTable(responseData)
        if (response.resCode ~= "00") then
            voteWindow.voteErrorView:show()
            return
        end
        local dataTable = response.commonResult
        if (dataTable == nil) then
            return
        end
        voteWindow.voteCount = dataTable
        --如果需要显示投票结果，显示投票结果
        if voteWindow.needShowVoteResult ~= nil and voteWindow.needShowVoteResult == true then
            calculateVoteCount()
            voteWindow.voteWindowScrollview:reload()
        end
    end)
end

--未上传时传递index，对应count+1，已上传不需要+1
function showVoteResult(index)
    local clickLinkUrl = getHotspotClickTrackLink(voteWindow.data, 1)
    if (clickLinkUrl ~= nil) then
        Native:get(clickLinkUrl)
    end
    if (voteWindow.launchPlanId ~= nil) then
        osTrack(voteWindow.launchPlanId, 3, 1)
    end
    if voteWindow.voteCount == nil then
        voteWindow.isVoted = true
        voteWindow.needShowVoteResult = true
        return
    end
    if index ~= nil then
        voteWindow.voteCount[index] = voteWindow.voteCount[index] + 1
        voteWindow.section = index
        postUserVoteInfo(index)
    end

    calculateVoteCount()
    voteWindow.isVoted = true
    voteWindow.voteWindowScrollview:reload()
end

local function voteClickEvent(section, row)
    -- local userInfoTable = Native:getUserInfo()
    -- if (userInfoTable == nil or userInfoTable.uid == nil or userInfoTable.uid == "") then
    --     Toast(OS_NO_LOGIN_INFO)
    --     Native:requireLogin(function(userInfo)
    --         voteWindow.loadingCount = voteWindow.loadingCount + 1
    --         voteWindow.voteLoadingView:show()
    --         getUserVoteInfo(function()
    --             postUserVoteInfo(row)
    --             showVoteResult(row)
    --         end)
    --     end)
    --     return
    -- end

    showVoteResult(row)
end

local function setLuaViewSize(luaview, isPortrait) --设置当前容器大小
    if (luaview == nil) then
        return
    end
    local screenWidth, screenHeight = System.screenSize()
    if (isPortrait) then
        luaview:frame(0, 0, math.min(screenWidth, screenHeight), math.max(screenWidth, screenHeight))
        luaview:align(Align.BOTTOM)
    else
        luaview:frame(0, 0, math.max(screenWidth, screenHeight), math.min(screenWidth, screenHeight))
        luaview:align(Align.RIGHT)
    end
end

local function setVoteViewSize(data, voteWindowView, voteWindowContentView, isPortrait) --设置当前容器大小
    if (data == nil or voteWindowView == nil or voteWindowContentView == nil) then
        return
    end
    local screenWidth, screenHeight = System.screenSize()
    if (isPortrait) then
        voteWindowView:frame(0, 0, voteWindow.portraitWidth, voteWindow.portraitHeight)
        -- voteWindowView:align(Align.BOTTOM)
        voteWindowContentView:frame(0, 0, voteWindow.portraitWidth, voteWindow.portraitHeight)
        voteWindowContentView:align(Align.BOTTOM)
        if System.ios() then
            voteWindowView:frame(0, math.max(screenWidth, screenHeight) - voteWindow.portraitHeight, voteWindow.portraitWidth, voteWindow.portraitHeight)
        else
            voteWindowView:align(Align.BOTTOM)
        end
    else
        voteWindowView:frame(0, 0, 215 * scale, math.min(screenWidth, screenHeight))
        voteWindowContentView:frame(0, 0, 200 * scale, math.min(screenWidth, screenHeight))
        voteWindowContentView:align(Align.RIGHT)
        if System.ios() then
            voteWindowView:frame(math.max(screenWidth, screenHeight) - 215 * scale, 0, 215 * scale, math.min(screenWidth, screenHeight))
        else
            voteWindowView:align(Align.RIGHT)
        end
    end
end

local function setVoteLoadingViewSize(data, voteLoadingView, voteLoading, isPortrait) --设置当前容器大小
    if (data == nil or voteLoadingView == nil or voteLoading == nil) then
        return
    end
    local screenWidth, screenHeight = System.screenSize()
    if (isPortrait) then
        voteLoadingView:frame(0, 0, voteWindow.portraitWidth, voteWindow.portraitHeight)
    else
        voteLoadingView:frame(0, 0, 215 * scale, math.min(screenWidth, screenHeight))
    end
    voteLoadingView:align(Align.RIGHT)
    voteLoading:frame(0, 0, 40, 40)
    voteLoading:align(Align.CENTER)
end

local function setVoteErrorViewSize(data, voteErrorView, voteErrorMessage, isPortrait) --设置当前容器大小
    -- if (data == nil or voteErrorView == nil or voteErrorMessage == nil) then
    --     return
    -- end
    local screenWidth, screenHeight = System.screenSize()
    if (isPortrait) then
        voteErrorView:frame(0, 0, voteWindow.portraitWidth, voteWindow.portraitHeight)
        voteErrorMessage:frame(0, voteWindow.portraitHeight * 0.7, math.min(screenWidth, screenHeight), 40)
    else
        voteErrorView:frame(0, 0, 200 * scale, math.min(screenWidth, screenHeight))
        voteErrorMessage:frame(0, math.min(screenWidth, screenHeight) * 0.7, 215 * scale, 40)
    end
    voteErrorView:align(Align.RIGHT)
end

local function setVoteIconViewSize(data, voteIconView, isPortrait)
    if (data == nil or voteIconView == nil) then
        return
    end
    if (isPortrait) then
        voteIconView:xy(21 * scale, 30 * scale)
    else
        voteIconView:xy(0, 27 * scale)
    end
end

local function setVoteTopViewSize(data, voteWindowTopLabel, voteWindowTopCloseView, isPortrait) --设置当前容器大小
    if (data == nil or voteWindowTopLabel == nil or voteWindowTopCloseView == nil) then
        return
    end
    if (isPortrait) then
        voteWindowTopCloseView:show()
        voteWindowTopLabel:frame(62 * scale, 34 * scale, 300 * scale, 25 * scale)
        voteWindowTopLabel:textSize(18)
    else
        voteWindowTopCloseView:hide()
        voteWindowTopLabel:frame(20 * scale, 33 * scale, 170 * scale, 20 * scale)
        voteWindowTopLabel:textSize(14)
    end
end

local function setVoteScrollviewSize(data, voteWindowScrollview, isPortrait) --设置当前容器大小
    if (data == nil or voteWindowScrollview == nil) then
        return
    end
    if (isPortrait) then
        local screenWidth, screenHeight = System.screenSize()
        voteWindowScrollview:frame(0, voteWindow.portraitHeight * 0.206, voteWindow.portraitWidth, voteWindow.portraitHeight * 0.794)
        voteWindowScrollview:miniSpacing(15 * scale)
    else
        voteWindowScrollview:frame(0, 90 * scale, 200 * scale, 285 * scale)
        voteWindowScrollview:miniSpacing(10 * scale)
    end
    voteWindowScrollview:reload()
end

--屏幕旋转--
local function rotationScreen(isPortrait)
    setLuaViewSize(voteWindow.luaview, isPortrait)
    setVoteViewSize(voteWindow.data, voteWindow.voteWindowView, voteWindow.voteWindowContentView, isPortrait)
    setVoteIconViewSize(voteWindow.data, voteWindow.voteWindowIcon, isPortrait)
    setVoteTopViewSize(voteWindow.data, voteWindow.voteWindowTopLabel, voteWindow.voteWindowTopCloseView, isPortrait)
    setVoteScrollviewSize(voteWindow.data, voteWindow.voteWindowScrollview, isPortrait)
    setVoteLoadingViewSize(voteWindow.data, voteWindow.voteLoadingView, voteWindow.voteLoading, isPortrait)
    setVoteErrorViewSize(voteWindow.data, voteWindow.voteErrorView, voteWindow.voteErrorMessage, isPortrait)
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
            voteWindow.voteWindowScrollview:reload()
        end
    }
    media:mediaCallback(callbackTable)
    return media
end

local function getSectionCount(data)
    if (data == nil) then
        return 0
    end
    local dataTable = data.data
    if (dataTable == nil) then
        return 0
    end
    local voteRule = dataTable.voteRule
    if (voteRule ~= nil) then
        return 2
    else
        return 1
    end
end

local function getRowCount(data, section)
    if (data == nil) then
        return 0
    end
    local dataTable = data.data
    if (dataTable == nil) then
        return 0
    end
    local voteList = dataTable.voteList
    if (voteList == nil) then
        return 0
    end
    if (section == 1) then
        return table_leng(voteList)
    else
        return 1
    end
end

local function getStateCellSize(data)
    if (data == nil) then
        return 0, 0
    end
    local voteRule = data.voteRule
    if (voteRule == nil) then
        return 0, 0
    end
    local isPortrait = Native:isPortraitScreen()
    if (isPortrait) then
        local textWidth, textHeight = Native:stringSizeWithWidth(voteRule, 334 * scale, 14)
        local screenWidth, screenHeight = System.screenSize()
        return math.min(screenWidth, screenHeight), screenHeight + 30 * scale
    else
        local textWidth, textHeight = Native:stringSizeWithWidth(voteRule, 160 * scale, 12)
        return 200 * scale, textHeight + 20 * scale
    end
end

local function createInitCell(cell, section, row)
    cell.lineTopView = View()
    cell.lineTopView:backgroundColor(0x4A90E2)
    cell.rootView = View()
    cell.rootView:backgroundColor(0x000000, 0.24)
    cell.iconLayout = View()
    cell.iconLayout:borderWidth(scale)
    cell.iconLayout:borderColor(0x494949)
    cell.iconView = Image(Native)
    cell.iconView:placeHolderImage(Data(OS_ICON_PRELOAD))
    cell.iconView:scaleType(ScaleType.CENTER_CROP)
    cell.nameView = Label()
    cell.nameView:textColor(0xFFFFFF)
    cell.nameView:textAlign(TextAlign.LEFT)

    cell.voteTagView = View() -- 投票进度
    cell.voteTagView:backgroundColor(0x4A90E2)
    cell.voteTagView:hide()

    cell.percentView = Label()
    cell.percentView:textColor(0xF5F5F5)
    cell.percentView:text("100.0%")
    cell.percentView:textAlign(TextAlign.LEFT)
    cell.percentView:hide()

    --    cell.voteView = Image(Native)
    --    cell.voteView:scaleType(ScaleType.FIT_XY)
    cell.voteView = Label()
    cell.voteView:textColor(0xFFFFFF)
    cell.voteView:text("投票")
    cell.voteView:backgroundColor(0x4A90E2)
    cell.voteView:textAlign(TextAlign.CENTER)
    cell.voteView:hide()
    cell.lineBottomView = View()
    cell.lineBottomView:backgroundColor(0x4A90E2)
    cell.lineBottomView:hide()
    cell.lineTopView:hide()
    cell.iconLayout:addView(cell.iconView)
end

local function createInitStateCell(cell, section, row)
    cell.stateView = Label()
    if (System.android()) then
        cell.stateView:textColor(0x5cFFFFFF)
    else
        cell.stateView:textColor(0xFFFFFF, 0.36)
    end
    if (System.android()) then
        cell.stateView:maxLines(100)
    else
        cell.stateView:lines(100)
    end
    cell.stateView:textAlign(TextAlign.LEFT)
end

local function createCellLandscapeSize(data, cell, section, row)
    --    cell.rootView1:frame(0, 0, 200 * scale, 50 * scale)
    cell.rootView:frame(0, 0, 200 * scale, 50 * scale)
    cell.iconLayout:frame(20 * scale, 5 * scale, 40 * scale, 40 * scale)
    cell.iconView:frame(scale, scale, 38 * scale, 38 * scale)
    cell.nameView:frame(70 * scale, 0, 120 * scale, 50 * scale)
    cell.nameView:textSize(12)


    if (voteWindow.isVoted) then
        cell.voteTagView:show()
        cell.percentView:show()
        cell.voteView:hide()
        local percent, percentText = mathPercent(voteWindow.voteCount[row] / voteWindow.totalVote)
        local percentWidth = percent * (90 * scale / 100) --90 * scale为最大宽度
        if (percentWidth == 0) then
            percentWidth = 6 * scale
        end
        cell.voteTagView:frame(70 * scale, 36 * scale, percentWidth, 6 * scale)
        cell.voteTagView:cornerRadius(3 * scale)

        cell.percentView:frame(75 * scale + percentWidth, 34 * scale, 31.5 * scale, 11 * scale)
        cell.percentView:textSize(8)
        cell.percentView:text(percentText)
        if (voteWindow.section == row) then
            if (cell.lineBottomView:isHide()) then
                cell.lineBottomView:show()
            end
            if (cell.lineTopView:isHide()) then
                cell.lineTopView:show()
            end
            cell.lineTopView:frame(0, 0, 200 * scale, scale)
            cell.lineBottomView:frame(0, 48 * scale, 200 * scale, scale)
            cell.rootView:frame(0, scale, 198 * scale, 50 * scale)
            --            if System.android() then
            --                cell.rootView1:margin(scale, scale, scale, scale)
            --                cell.rootView1:borderWidth(scale)
            --                cell.rootView1:borderColor(0x4A90E2)
            --            else
            --                cell.rootView:borderWidth(scale)
            --                cell.rootView:borderColor(0x4A90E2)
            --            end
        else
            if (cell.lineBottomView:isShow()) then
                cell.lineBottomView:hide()
            end
            if (cell.lineTopView:isShow()) then
                cell.lineTopView:hide()
            end
            cell.rootView:frame(0, 0, 200 * scale, 50 * scale)
            --            if System.android() then
            --                cell.rootView1:margin(0, 0, 0, 0)
            --                cell.rootView1:borderWidth(0)
            --                cell.rootView1:borderColor(0x4A90E2)
            --            else
            --                cell.rootView:borderWidth(0)
            --                cell.rootView:borderColor(0x4A90E2)
            --            end
        end
    else
        if (cell.voteTagView:isShow()) then
            cell.voteTagView:hide()
        end
        if (cell.percentView:isShow()) then
            cell.percentView:hide()
        end
        if (cell.voteView:isHide()) then
            cell.voteView:show()
        end
        cell.voteView:frame(144 * scale, 15 * scale, 48 * scale, 20 * scale)
        cell.voteView:cornerRadius(10 * scale)
        cell.voteView:textSize(12)
    end


    if (data == nil) then
        return
    end
    local imageUrl = data.imageUrl
    if (imageUrl ~= nil) then
        cell.iconView:image(imageUrl)
    end
    local title = data.title
    if (title ~= nil) then
        cell.nameView:text(title)
    end
    --    local btnImageUrl = voteWindow.data.data.voteBtnImage
    --    if (btnImageUrl ~= nil) then
    --        cell.voteView:image(btnImageUrl)
    --    end
    cell.voteView:onClick(function()
        --TODO 投票逻辑添加
        voteClickEvent(section, row)
    end)
end

local function createStateCellLandscapeSize(data, cell, section, row)

    if (data == nil) then
        return
    end

    local voteRule = data.voteRule
    if (System.android()) then
        cell.stateView:margin(20 * scale, 0, 20 * scale, 10 * scale)
    else
        local textWidth, textHeight = Native:stringSizeWithWidth(voteRule, 200 * scale - 21 * scale * 2, 12)
        cell.stateView:frame(20 * scale, 10 * scale, textWidth, textHeight + 5 * scale)
    end

    cell.stateView:textSize(12)

    if (voteRule ~= nil) then
        cell.stateView:text(voteRule)
    end
end

local function createCellPortraitSize(data, cell, section, row)
    local screenWidth, screenHeight = System.screenSize()
    cell.rootView:frame(0, 0, math.min(screenWidth, screenHeight), 75 * scale)
    cell.iconLayout:frame(22 * scale, 7.5 * scale, 60 * scale, 60 * scale)
    cell.iconView:frame(scale, scale, 58 * scale, 58 * scale)
    cell.nameView:frame(104 * scale, 0, 246 * scale, 75 * scale)
    cell.nameView:textSize(18)

    if (voteWindow.isVoted) then
        if (cell.voteTagView:isHide()) then
            cell.voteTagView:show()
        end
        if (cell.percentView:isHide()) then
            cell.percentView:show()
        end
        if (cell.voteView:isShow()) then
            cell.voteView:hide()
        end
        local percent, percentText = mathPercent(voteWindow.voteCount[row] / voteWindow.totalVote)
        local percentWidth = percent * (205 * scale / 100) --205 * scale为最大宽度
        if (percentWidth == 0) then
            percentWidth = 10 * scale
        end
        cell.voteTagView:frame(104 * scale, 57 * scale, percentWidth, 10 * scale)
        cell.voteTagView:cornerRadius(5 * scale)

        cell.percentView:frame(109 * scale + percentWidth, 52 * scale, 64.5 * scale, 20 * scale) --109 * scale其它偏移量
        cell.percentView:textSize(14)
        cell.percentView:text(percentText)
        if (voteWindow.section == row) then
            if (cell.lineBottomView:isHide()) then
                cell.lineBottomView:show()
            end
            if (cell.lineTopView:isHide()) then
                cell.lineTopView:show()
            end
            cell.lineTopView:frame(0, 0, math.min(screenWidth, screenHeight), scale)
            cell.lineBottomView:frame(0, 74 * scale, math.min(screenWidth, screenHeight), scale)
            cell.rootView:frame(0, scale, math.min(screenWidth, screenHeight), 73 * scale)
            --            if System.android() then
            --                cell.rootView1:margin(scale, scale, scale, scale)
            --                cell.rootView1:borderWidth(scale)
            --                cell.rootView1:borderColor(0x4A90E2)
            --            else
            --                cell.rootView:borderWidth(scale)
            --                cell.rootView:borderColor(0x4A90E2)
            --            end
        else
            if (cell.lineBottomView:isShow()) then
                cell.lineBottomView:hide()
            end
            if (cell.lineTopView:isShow()) then
                cell.lineTopView:hide()
            end
            cell.rootView:frame(0, 0, math.min(screenWidth, screenHeight), 75 * scale)
            --            if (System.android()) then
            --                cell.rootView1:margin(0, 0, 0, 0)
            --                cell.rootView1:borderWidth(0)
            --            else
            --                cell.rootView:borderWidth(0 * scale)
            --                cell.rootView:borderColor(0x4A90E2)
            --            end
        end
    else
        if (cell.voteTagView:isShow()) then
            cell.voteTagView:hide()
        end
        if (cell.percentView:isShow()) then
            cell.percentView:hide()
        end
        if (cell.voteView:isHide()) then
            cell.voteView:show()
        end
        cell.voteView:frame(277 * scale, 22.5 * scale, 72 * scale, 30 * scale)
        cell.voteView:cornerRadius(15 * scale)
        cell.voteView:textSize(18)
    end



    if (data == nil) then
        return
    end
    local imageUrl = data.imageUrl
    if (imageUrl ~= nil) then
        cell.iconView:image(imageUrl)
    end
    local title = data.title
    if (title ~= nil) then
        cell.nameView:text(title)
    end
    --    local btnImageUrl = voteWindow.data.data.voteBtnImage
    --    if (btnImageUrl ~= nil) then
    --        cell.voteView:image(btnImageUrl)
    --    end

    cell.voteView:onClick(function()
        --TODO 投票逻辑添加
        voteClickEvent(section, row)
    end)
end

local function createStateCellPortraitSize(data, cell, section, row)

    if (data == nil) then
        return
    end
    local voteRule = data.voteRule

    if (System.android()) then
        cell.stateView:margin(21 * scale, 0, 21 * scale, 15 * scale)
    else
        local screenWidth, screenHeight = System.screenSize()
        local cellWidth = math.min(screenWidth, screenHeight)
        local textWidth, textHeight = Native:stringSizeWithWidth(voteRule, cellWidth - 21 * scale * 2 - 2 * scale, 14)
        cell.stateView:frame(21 * scale, 15 * scale, cellWidth - 21 * scale * 2, textHeight + 5 * scale)
    end
    cell.stateView:textSize(14)


    if (voteRule ~= nil) then
        cell.stateView:text(voteRule)
    end
end

--全局父控件
local function createLuaView(isPortrait)
    local luaView
    -- if System.android() then
    --     luaView = View()
    -- else
    --     luaView = ThroughView()
    -- end
    luaView = View()
    setLuaViewSize(luaView, isPortrait)
    return luaView
end

--投票云窗大小控件
local function createVoteView(data, isPortrait)
    local voteWindowView = View()
    local voteWindowContentView = View()
    voteWindowContentView:backgroundColor(0x2F2F2F)
    setVoteViewSize(data, voteWindowView, voteWindowContentView, isPortrait)

    voteWindowView:addView(voteWindowContentView)
    return voteWindowView, voteWindowContentView
end

--投票loading控件
local function createVoteLoadingView(data, isPortrait)
    local voteLoadingView = View()
    voteLoadingView:backgroundColor(0x000000, 0.4)
    local voteLoading = LoadingIndicator()
    voteLoading:start()
    setVoteLoadingViewSize(data, voteLoadingView, voteLoading, isPortrait)
    voteLoadingView:addView(voteLoading)
    voteLoadingView:hide()
    voteLoadingView:onClick(function()
    end)
    return voteLoadingView, voteLoading
end

--投票错误控件
local function createVoteErrorView(data, isPortrait)
    local voteErrorView = View()
    voteErrorView:backgroundColor(0x000000, 0.4)

    local voteErrorMessage = Label()
    voteErrorMessage:textColor(0xFFFFFF)
    voteErrorMessage:text("服务器出错了，请稍后再试")
    voteErrorMessage:textAlign(TextAlign.CENTER)
    local voteLoading = LoadingIndicator()

    setVoteErrorViewSize(data, voteErrorView, voteErrorMessage, isPortrait)
    voteErrorView:addView(voteErrorMessage)
    voteErrorView:hide()
    voteErrorView:onClick(function()
        voteErrorView:hide()
    end)
    return voteErrorView, voteErrorMessage
end

local function createVoteIconView(data, isPortrait)
    local voteWindowIcon = Image(Native)
    voteWindowIcon:scaleType(ScaleType.CENTER_CROP)
    voteWindowIcon:size(30 * scale, 30 * scale)
    voteWindowIcon:placeHolderImage(Data(OS_ICON_PRELOAD))
    voteWindowIcon:cornerRadius(15 * scale)
    setVoteIconViewSize(data, voteWindowIcon, isPortrait)
    return voteWindowIcon
end

local function createVoteTopView(data, isPortrait)

    local voteWindowTopLabel = Label()
    local title = "快来Pick你喜欢的小姐姐吧"
    voteWindowTopLabel:textColor(0xF5F5F5)
    voteWindowTopLabel:text(title)

    local voteWindowTopCloseView = View()
    voteWindowTopCloseView:frame(0, 0, 37 * scale, 36 * scale)
    voteWindowTopCloseView:align(Align.RIGHT)
    voteWindowTopCloseView:hide()

    local voteWindowTopCloseImage = Image(Native)
    voteWindowTopCloseImage:frame(0, 0, 15 * scale, 15 * scale)
    voteWindowTopCloseImage:scaleType(ScaleType.CENTER_CROP)
    voteWindowTopCloseImage:image(Data(OS_ICON_WEDGE_CLOSE))
    voteWindowTopCloseImage:align(Align.BOTTOM)

    voteWindowTopCloseView:addView(voteWindowTopCloseImage)

    setVoteTopViewSize(data, voteWindowTopLabel, voteWindowTopCloseView, isPortrait)
    return voteWindowTopLabel, voteWindowTopCloseView
end

local function createVoteScrollview(data, isPortrait)
    local dataTable = voteWindow.data.data
    local voteTable = dataTable.voteList
    local voteWindowScrollview = CollectionView {
        Section = {
            SectionCount = function()
                -- 返回页面区块的个数（不同区块的种类数）
                return getSectionCount(voteWindow.data)
            end,
            RowCount = function(section)
                -- 返回每个区块对应有的坑位数
                return getRowCount(voteWindow.data, section)
            end
        },
        Cell = {
            Id = function(section, row)
                -- 返回每个区块对应额坑位ID
                if (section == 1) then
                    return "VoteCell"
                elseif (section == 2) then
                    if (System.android()) then
                        return "VoteState"
                    else
                        return "VoteStateIOS"
                    end
                end
            end,
            VoteCell = {
                Size = function(section, row)
                    local isPortrait = Native:isPortraitScreen()
                    if (isPortrait) then
                        local screenWidth, screenHeight = System.screenSize()
                        return math.min(screenWidth, screenHeight), 75 * scale
                    else
                        return 200 * scale, 50 * scale
                    end
                end,
                Init = function(cell, section, row)
                    createInitCell(cell, section, row)
                end,
                Layout = function(cell, section, row)
                    local isPortrait = Native:isPortraitScreen()
                    if (isPortrait) then

                        createCellPortraitSize(voteTable[row], cell, section, row)
                    else
                        createCellLandscapeSize(voteTable[row], cell, section, row)
                    end
                end
            },
            VoteState = {
                Sizes = function(section, row)
                    return 0, 0
                end,
                Init = function(cell, section, row)
                    createInitStateCell(cell, section, row)
                end,
                Layout = function(cell, section, row)
                    local isPortrait = Native:isPortraitScreen()
                    if (isPortrait) then
                        createStateCellPortraitSize(dataTable, cell, section, row)
                    else
                        createStateCellLandscapeSize(dataTable, cell, section, row)
                    end
                end
            },
            VoteStateIOS = {
                Size = function(section, row)
                    local voteRule = dataTable.voteRule
                    local isPortrait = Native:isPortraitScreen()
                    if voteRule == nil then
                        return 0, 0
                    end
                    if (isPortrait) then
                        local screenWidth, screenHeight = System.screenSize()
                        local cellWidth = math.min(screenWidth, screenHeight)
                        local textWidth, textHeight = Native:stringSizeWithWidth(voteRule, cellWidth - 42 * scale, 14)
                        return cellWidth, textHeight + 5 * scale + 30 * scale
                    else
                        local cellWidth = 200 * scale
                        local textWidth, textHeight = Native:stringSizeWithWidth(voteRule, cellWidth - 40 * scale, 12)
                        return cellWidth, textHeight + 5 * scale + 20 * scale
                    end
                end,
                Init = function(cell, section, row)
                    createInitStateCell(cell, section, row)
                end,
                Layout = function(cell, section, row)
                    local isPortrait = Native:isPortraitScreen()
                    if (isPortrait) then
                        createStateCellPortraitSize(dataTable, cell, section, row)
                    else
                        createStateCellLandscapeSize(dataTable, cell, section, row)
                    end
                end
            }
        },
        Callback = {
            -- 整个CollectionView的事件回调
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
    setVoteScrollviewSize(data, voteWindowScrollview, isPortrait)
    return voteWindowScrollview
end


local function onCreate(data)
    registerMedia()

    local isPortrait = Native:isPortraitScreen()
    voteWindow.luaview = createLuaView(isPortrait)
    voteWindow.voteWindowView, voteWindow.voteWindowContentView = createVoteView(data, isPortrait)
    voteWindow.voteWindowIcon = createVoteIconView(data, isPortrait)
    voteWindow.voteWindowTopLabel, voteWindow.voteWindowTopCloseView = createVoteTopView(data, isPortrait)
    voteWindow.voteWindowScrollview = createVoteScrollview(data, isPortrait)
    voteWindow.voteLoadingView, voteWindow.voteLoading = createVoteLoadingView(data, isPortrait)
    voteWindow.voteErrorView, voteWindow.voteErrorMessage = createVoteErrorView(data, isPortrait)

    voteWindow.luaview:addView(voteWindow.voteWindowView)
    voteWindow.voteWindowView:addView(voteWindow.voteWindowIcon)

    voteWindow.voteWindowContentView:addView(voteWindow.voteWindowTopLabel)
    voteWindow.voteWindowContentView:addView(voteWindow.voteWindowTopCloseView)
    voteWindow.voteWindowContentView:addView(voteWindow.voteWindowScrollview)
    voteWindow.voteWindowView:addView(voteWindow.voteLoadingView)
    voteWindow.voteWindowView:addView(voteWindow.voteErrorView)
    local screenWidth, screenHeight = System.screenSize()
    if (isPortrait) then
        if System.ios() then
            voteWindow.voteWindowView:y(math.max(screenWidth, screenHeight))
            voteWindow.anim = startViewTranslationAnim(voteWindow.voteWindowView, 0, -voteWindow.portraitHeight)
        else
            voteWindow.voteWindowView:translation(0, voteWindow.portraitHeight)
            voteWindow.anim = startViewTranslationAnim(voteWindow.voteWindowView, 0, 0)
        end
    else
        if System.ios() then
            voteWindow.voteWindowView:x(math.max(screenWidth, screenHeight))
            voteWindow.anim = startViewTranslationAnim(voteWindow.voteWindowView, -215 * scale, 0)
        else
            voteWindow.voteWindowView:translation(215 * scale, 0)
            voteWindow.anim = startViewTranslationAnim(voteWindow.voteWindowView, 0, 0)
        end
    end

    voteWindow.voteWindowView:onClick(function()
    end)
    voteWindow.luaview:onClick(function()
        local isPortrait = Native:isPortraitScreen()
        if (isPortrait) then
            startViewTranslationAnim(voteWindow.voteWindowView, 0, voteWindow.portraitHeight, {
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
            startViewTranslationAnim(voteWindow.voteWindowView, 215 * scale, 0, {
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
    end)
    voteWindow.voteWindowTopCloseView:onClick(function()
        startViewTranslationAnim(voteWindow.voteWindowView, 0, voteWindow.portraitHeight, {
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
    end)
    local dataTable = voteWindow.data.data
    if (dataTable == nil) then
        return
    end
    local voteTitle = dataTable.voteTitle
    if (voteTitle ~= nil) then
        voteWindow.voteWindowTopLabel:text(voteTitle)
    end
    local voteIcon = dataTable.voteImageUrl
    if (voteIcon ~= nil) then
        voteWindow.voteWindowIcon:image(voteIcon)
    end
    Native:widgetEvent(eventTypeShow, voteWindow.id, adTypeName, actionTypeNone, "")
end

local function setConfig(data)
    if (data == nil) then
        return
    end
    voteWindow.data = data
    voteWindow.isVoted = false
    local screenWidth, screenHeight = System.screenSize()
    local videoWidth, videoHight, marginTop = Native:getVideoSize(0)
    voteWindow.portraitWidth = math.min(screenWidth, screenHeight) --宽
    voteWindow.portraitHeight = math.max(screenWidth, screenHeight) - videoHight - marginTop --高
    local dataTable = voteWindow.data.data
    if (dataTable == nil) then
        return
    end
    local voteListTable = dataTable.voteList
    if (voteListTable == nil) then
        voteWindow.totalVote = 1
        return
    end
end

function show(args)
    if (args == nil or args.data == nil or voteWindow.luaview ~= nil) then
        return
    end
    print("LuaView os vote window" .. Native:tableToJson(args))
    voteWindow.loadingCount = 0
    voteWindow.id = "os_vote_window" .. tostring(args.data.id)
    voteWindow.launchPlanId = args.data.launchPlanId
    if (voteWindow.launchPlanId ~= nil) then
        osTrack(voteWindow.launchPlanId, 1, 1)
    end
    setConfig(args.data)
    onCreate(args.data)

    if args.data.data.voteCount == nil then
        voteWindow.totalVote = 1
        voteWindow.loadingCount = voteWindow.loadingCount + 1
        voteWindow.voteLoadingView:show()
        getVoteCountInfo()
    else
        local voteCount = args.data.data.voteCount
        voteWindow.voteCount = voteCount
        calculateVoteCount()
    end

    --用户已经登录，判定是否在vote热点页面取到用户投票数据
    if args.data.data ~= nil and args.data.data.userVote then
        local userVote = args.data.data.userVote
        if userVote.isVote == true then
            --用户已经投票，判定是否在vote热点页面取到票数
            voteWindow.section = userVote.vote
            if voteWindow.voteCount ~= nil then
                voteWindow.isVoted = true
                voteWindow.voteWindowScrollview:reload()
            else
                voteWindow.needShowVoteResult = true
            end
        else
            local showLinkUrl = getHotspotExposureTrackLink(args.data, 1)
            if (showLinkUrl ~= nil) then
                Native:get(showLinkUrl)
            end
            if (voteWindow.launchPlanId ~= nil) then
                osTrack(voteWindow.launchPlanId, 2, 1)
            end
        end
    else
        voteWindow.loadingCount = voteWindow.loadingCount + 1
        voteWindow.voteLoadingView:show()
        getUserVoteInfo()
    end
end

