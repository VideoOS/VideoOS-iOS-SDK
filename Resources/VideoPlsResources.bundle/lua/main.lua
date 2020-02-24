--[[
VideoOS - A Mini-App platform based on video player
http://videojj.com/videoos-open/
Copyright (C) 2019  Shanghai Ji Lian Network Technology Co., Ltd

This program is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program. If not, see <http://www.gnu.org/licenses/>.
--]]
--OS入口 TODO是否可在此处判断类型？？？进行跳转--
require "os_string"
require "os_config"
require "os_util"
require "os_constant"
local repeatAdTable = {} --广告轮询集合
local showAdTable = {} --正在展示的table
local checkAdTable = {} --广告是否可以展示
local lastProgress = 0
local bubbleIdList = {}
local targetObjId = nil
local roomId = Native:nativeVideoID()
local adShowInterval = 1000
local adCheckInterval = 5000
local preloadCount = 1
mainNode = object:new()

local function wedgeRepeatTimes(data)
    if (data == nil) then
        return -1
    end
    local dataTable = data.data
    if (dataTable == nil) then
        return -1
    end
    if (dataTable.repeatTimes == nil) then
        return -1
    end
    return tonumber(dataTable.repeatTimes)
end

local function hotspotPriority(data)
    if (data == nil) then
        return osHotspotViewPriority
    end
    local dataTable = data.data
    if (dataTable == nil) then
        return osHotspotViewPriority
    end
    if (dataTable.priority == nil) then
        return osHotspotViewPriority
    end
    return tonumber(dataTable.priority)
end

local function hotspotLevel(data)
    if (data == nil) then
        return nil
    end
    local dataTable = data.data
    if (dataTable == nil) then
        return nil
    end
    if (dataTable.level == nil) then
        return nil
    end
    return tonumber(dataTable.level)
end

local function sendActionWedge(data) --跳转中插处理
    if (data == nil) then
        return
    end
    local repeatTimes = wedgeRepeatTimes(data)
    local priority = hotspotPriority(data)
    local level = hotspotLevel(data)
    if (repeatTimes == -1) then
        if (level == osTopLevel) then
            Native:sendAction(Native:base64Encode("LuaView://topLuaView?template=" .. data.miniAppInfo.template .. "&id=" .. data.id .. "&priority=" .. tostring(priority) .. "&miniAppId=" .. data.miniAppInfo.miniAppId), data)
        else
            Native:sendAction(Native:base64Encode("LuaView://defaultLuaView?template=" .. data.miniAppInfo.template .. "&id=" .. data.id .. "&priority=" .. tostring(priority) .. "&miniAppId=" .. data.miniAppInfo.miniAppId), data)
        end
        print("=response==跳转=" .. tostring(data.template) .. "==id==" .. tostring(data.id) .. "==key=" .. tostring(key))
        return
    end
    local dataTable = data.data
    if (dataTable == nil) then
        return
    end
    local playWedgeCount = dataTable.playWedgeCount
    if (playWedgeCount == nil or playWedgeCount == '') then
        playWedgeCount = 0
    else
        playWedgeCount = tonumber(playWedgeCount)
    end
    if (playWedgeCount >= repeatTimes) then
        return
    end
    playWedgeCount = playWedgeCount + 1
    dataTable.playWedgeCount = playWedgeCount

    if (level == osTopLevel) then
        Native:sendAction(Native:base64Encode("LuaView://topLuaView?template=" .. data.miniAppInfo.template .. "&id=" .. data.id .. "&priority=" .. tostring(priority) .. "&miniAppId=" .. data.miniAppInfo.miniAppId), data)
    else
        Native:sendAction(Native:base64Encode("LuaView://defaultLuaView?template=" .. data.miniAppInfo.template .. "&id=" .. data.id .. "&priority=" .. tostring(priority) .. "&miniAppId=" .. data.miniAppInfo.miniAppId), data)
    end
    
    print("=response==跳转=" .. tostring(data.template) .. "==id==" .. tostring(data.id) .. "==key=" .. tostring(key))
end

local function closeAdView(adId, data)
    if adId == nil or data == nil then
        return
    end
    showAdTable[adId] = nil
    Native:destroyView(adId)
    if Native:getCacheData(adId) == tostring(eventTypeShow) then
        --widgetEvent需要传AdName，这个位置没有AdName，传template
        Native:widgetEvent(eventTypeClose, adId, data.template, actionTypeNone, "")
        Native:deleteBatchCacheData({ adId })
    end
end

local function trackNotice(data, requestType, status, isShow)
    if (data == nil or requestType == nil or status == nil or isShow == nil) then
        return nil
    end

    local paramData = {
        videoId = Native:nativeVideoID(),
        id = data.id,
        launchPlanId = data.launchPlanId,
        createId = data.createId,
        timestamp = data.videoStartTime,
        type = requestType,
        status = status,
        isShow = isShow
    }
    --接口参数文档http://wiki.videojj.com/pages/viewpage.action?pageId=2215044
    Native:commonTrack(4, paramData)
end

local function checkHotspotShow(data)

    if (data == nil) then
        return nil
    end

    local paramData = {
        videoId = Native:nativeVideoID(),
        id = data.id,
        launchPlanId = data.launchPlanId,
        createId = data.createId,
        timestamp = data.videoStartTime,
        commonParam = Native:commonParam()
    }

    local videoInfo = Native:getVideoInfo()

    if videoInfo["extendDict"] ~= nil then
        paramData["videoInfo"] = videoInfo["extendDict"]
    end

    local paramDataString = Native:tableToJson(paramData)
    -- local OS_HTTP_POST_CHECK_HOTSPOT = OS_HTTP_HOST .. "/api/notice"

    -- print("[LuaView] "..paramDataString)
    -- print("[LuaView] "..OS_HTTP_POST_CHECK_HOTSPOT)
    -- print("[LuaView] "..Native:aesEncrypt(paramDataString, OS_HTTP_PUBLIC_KEY, OS_HTTP_PUBLIC_KEY))

    mainNode.request:post(OS_HTTP_POST_CHECK_HOTSPOT, {
        bu_id = buId,
        device_type = deviceType,
        data = Native:aesEncrypt(paramDataString, OS_HTTP_PUBLIC_KEY, OS_HTTP_PUBLIC_KEY)
    }, function(response, errorInfo)
        -- print("luaview getVoteCountInfo")

        local requestType = 0
        local playStatus = 0
        local isShow = 0
        if (response ~= nil) then
            requestType = 1
            -- print("luaview getVoteCountInfo 11"..Native:tableToJson(response))
            responseData = Native:aesDecrypt(response.encryptData, OS_HTTP_PUBLIC_KEY, OS_HTTP_PUBLIC_KEY)
            -- print("luaview " .. Native:tableToJson(data))
            -- print("luaview " .. responseData)
            response = toTable(responseData)
            if (response.resCode == "00") then
                if (response.status == "00") then
                    playStatus = 1
                    if checkAdTable[data.id] ~= nil then
                        checkAdTable[data.id] = true
                    end
                    if data.videoStartTime + adShowInterval > lastProgress then
                        isShow = 1
                    end
                end
            end
        end
        trackNotice(data, requestType, playStatus, isShow)
    end)
end

--轮询添加广告逻辑广告逻辑(注:)
local function dispatchAd(dataTables, position)
    local currentPositionAdInfos = {}
    if (dataTables == nil or table_leng(dataTables) <= 0 or position <= 0) then
        return currentPositionAdInfos
    end
    for key, value in pairs(dataTables) do
        if (value.id ~= nil and value.template ~= nil) then
            --气泡特殊处理，由Activated Time控制出现
            if value.videoActivatedStartTime ~= nil and (tonumber(value.videoActivatedStartTime) <= position and tonumber(value.videoActivatedEndTime) >= position and showAdTable[value.id] == nil) then
                showAdTable[value.id] = value
                currentPositionAdInfos[value.id] = value
                table.insert(bubbleIdList, value.id)
            elseif value.videoStartTime ~= nil and ((tonumber(value.videoStartTime) - adCheckInterval) <= position and tonumber(value.videoStartTime) >= position and checkAdTable[value.id] == nil) then
                checkAdTable[value.id] = false
                checkHotspotShow(value)
            elseif value.videoStartTime ~= nil and (tonumber(value.videoStartTime) <= position and (tonumber(value.videoStartTime) + adShowInterval) >= position and showAdTable[value.id] == nil) and checkAdTable[value.id] == true then
                checkAdTable[value.id] = nil
                showAdTable[value.id] = value
                currentPositionAdInfos[value.id] = value
            elseif ((position >= tonumber(value.videoEndTime) or position <= tonumber(value.videoStartTime)) and showAdTable[value.id] ~= nil) then
                closeAdView(value.id, value)
            else
                --todo
            end
        end
    end
    return currentPositionAdInfos
end

--跳转逻辑--
local function sendNativeViewAction(table)
    if (table == nil) then
        return
    end
    for key, value in pairs(table) do
        if (value.id ~= nil and value.template ~= nil) then
            local template = value.template
            if (template == nil) then
                return
            end
            sendActionWedge(value)
            -- if (template == "os_wedge.lua") then
            --     sendActionWedge(value)
            -- elseif (template == "os_bubble.lua") then
            --     Native:sendAction(Native:base64Encode("LuaView://defaultLuaView?template=" .. value.template .. "&id=" .. value.id), value)
            -- -- elseif (template == "os_cloud.lua") then
            -- else
            --     Native:sendAction(Native:base64Encode("LuaView://defaultLuaView?template=" .. value.template .. "&id=" .. value.id), value)
            -- end
            --print("=response==跳转=" .. tostring(value.template) .. "==id==" .. tostring(value.id) .. "==key=" .. tostring(key))
        end
    end
end

local function registerMedia()
    local media = Media()
    -- body
    -- 注册window callback通知
    local callbackTable = {
        onMediaProgress = function(progress)
            --视频被拖动时，删除所有已经显示的热点
            if lastProgress ~= nil and math.abs(lastProgress - progress) > 1500 then
                checkAdTable = {}
                for key, value in pairs(showAdTable) do
                    closeAdView(key, value)
                end
            end
            lastProgress = progress

            local currentPositionAdInfos = dispatchAd(repeatAdTable, tonumber(progress))
            if (table_leng(currentPositionAdInfos) <= 0) then
                return
            end
            sendNativeViewAction(currentPositionAdInfos)
        end
    }
    media:mediaCallback(callbackTable)
    media:startVideoTime()
    return media
end

local function downloadAndRunLua(data)
    if (data == nil) then
        return
    end
    for k,v in pairs(data) do
        Native:preloadMiniAppLua(v.miniAppInfo, function(status)
            print("preloadMiniAppLua " .. tostring(status))
            if (status == true) then 
                sendNativeViewAction(data)
            end
        end)
    end
end

local function registerMqtt(data)
    if data == nil then
        return
    end
    local emqConfigTable = data.emqConfig
    if emqConfigTable == nil then
        return
    end
    --osTypeVideoOS = 1, osTypeLiveOS = 2, 直播开启Mqtt，点播不开启
    if Native:osType() < osTypeLiveOS then
        return
    end

    local mqtt = Mqtt()
    local topic = {}
    local topicConfig = emqConfigTable.topic
    local appKey = Native:appKey()
    local nativeVideoID = Native:nativeVideoID()
    local topicString
    if (appKey ~= '' and appKey ~= nil and topicConfig ~= '' and topicConfig ~= nil) then
        topicString = topicConfig .. '/' .. appKey .. "-" .. nativeVideoID
        --    elseif (appKey ~= '' and appKey ~= nil and topicConfig == nil) then
        --        topicString = appKey .. "-" .. nativeVideoID
    else
        topicString = nativeVideoID
    end

    if System.ios() then
        topicString = topicString .. '/'
    end
    topic[topicString] = 0
    --print("register "..Native:nativeVideoID())

    onMqttMessage = function(message)
        --print("onMqttMessage"..tostring(message))
        responseData = Native:aesDecrypt(message.encryptData, OS_HTTP_PUBLIC_KEY, OS_HTTP_PUBLIC_KEY)
        --print("luaview "..responseData)

        response = toTable(responseData)
        local dataTable = response.launchInfoList
        if (dataTable == nil) then
            return
        end
        for key, value in pairs(dataTable) do
            if (value.id ~= nil and value.miniAppInfo ~= nil) then
                local showAd = {}
                value.from = "mqtt"
                showAd[value.id] = value
                downloadAndRunLua(showAd)
                --在此关闭中插有问题
            end
        end
    end
    mqtt:mqttCallback(onMqttMessage)
    mqtt:startMqtt(topic, data.emqConfig)
    return mqtt
end

local function getTaglist()

    local paramData = {
        videoId = Native:nativeVideoID(),
        episode = Native:getVideoEpisode(),
        title = Native:getVideoTitle(),
        commonParam = Native:commonParam()
    }

    local videoInfo = Native:getVideoInfo()

    if videoInfo["extendDict"] ~= nil then
        paramData["videoInfo"] = videoInfo["extendDict"]
    end

    local paramDataString = Native:tableToJson(paramData)
    --print("[LuaView] "..paramDataString)
    --print("[LuaView] "..Native:aesEncrypt(paramDataString, OS_HTTP_PUBLIC_KEY, OS_HTTP_PUBLIC_KEY))
    mainNode.request:post(OS_HTTP_GET_TAG_LIST, {
        bu_id = buId,
        device_type = deviceType,
        data = Native:aesEncrypt(paramDataString, OS_HTTP_PUBLIC_KEY, OS_HTTP_PUBLIC_KEY)
    }, function(response, errorInfo)
        --print("luaview getTaglist")
        if (response == nil) then
            return
        end
        responseData = Native:aesDecrypt(response.encryptData, OS_HTTP_PUBLIC_KEY, OS_HTTP_PUBLIC_KEY)
        print("luaview "..responseData)

        response = toTable(responseData)
        if (response.resCode ~= "00") then
            return
        end
        local dataTable = response.launchInfoList
        if (dataTable == nil) then
            return
        end
        
        --下载投放的lua文件
        local luaList = {}
        --按id去重
        for i,v in ipairs(dataTable) do
            if (v.miniAppInfo ~= nil ) then
                luaList[v.miniAppInfo.miniAppId] = v.miniAppInfo
            end
        end

        for k,v in pairs(luaList) do
            Native:preloadMiniAppLua(v)
        end

        --osTypeVideoOS = 1, osTypeLiveOS = 2, 点播按时间点加载，直播直接加载
        if Native:osType() < osTypeLiveOS then
            print("osTypeVideoOS")
            for key, value in pairs(dataTable) do
                if (value.id ~= nil and value.template ~= nil) then
                    table.insert(repeatAdTable, value)
                end
            end
        else
            print("osTypeLiveOS")
            for key, value in pairs(dataTable) do
                if (value.id ~= nil and value.miniAppInfo ~= nil) then
                    local showAd = {}
                    showAd[value.id] = value
                    downloadAndRunLua(showAd)
                end
            end
        end
    end, mainNode.media)
end

local function getSimulationTag()

    local paramData = {
        videoId = Native:nativeVideoID(),
        commonParam = Native:commonParam()
    }

    local extendTable = nil

    local videoInfo = Native:getVideoInfo()

    if videoInfo["extendDict"] ~= nil then
        paramData["videoInfo"] = videoInfo["extendDict"]
        extendTable = videoInfo["extendDict"]
    end

    if extendTable["creativeName"] ~= nil then
        paramData["creativeName"] = extendTable["creativeName"]
    end
    local paramDataString = Native:tableToJson(paramData)
    --print("[LuaView] "..paramDataString)
    --print("[LuaView] "..Native:aesEncrypt(paramDataString, OS_HTTP_PUBLIC_KEY, OS_HTTP_PUBLIC_KEY))
    mainNode.request:post(OS_HTTP_GET_SIMULATION_TAG, {
        bu_id = buId,
        device_type = deviceType,
        data = Native:aesEncrypt(paramDataString, OS_HTTP_PUBLIC_KEY, OS_HTTP_PUBLIC_KEY)
    }, function(response, errorInfo)
        --print("luaview getSimulationTag")
        if (response == nil) then
            return
        end
        responseData = Native:aesDecrypt(response.encryptData, OS_HTTP_PUBLIC_KEY, OS_HTTP_PUBLIC_KEY)
        --print("luaview "..responseData)
        response = toTable(responseData)
        if (response.resCode ~= "00") then
            return
        end
        local dataTable = response.launchInfoList
        if (dataTable == nil) then
            return
        end
        for key, value in pairs(dataTable) do
            if (value.id ~= nil and value.miniAppInfo ~= nil) then
                local showAd = {}
                showAd[value.id] = value
                downloadAndRunLua(showAd)
            end
        end
        --print("getSimulationTag success")
    end, mainNode.media)
end

function getTag()
    local extendJson = Native:getConfigExtendJSONString()
    local extendTable = toTable(extendJson)
    --有素材名称，是模拟显示模板
    if extendTable ~= nil and extendTable["creativeName"] ~= nil and string.len(tostring(extendTable["creativeName"])) > 0 then
        getSimulationTag()
    else
        if Native:osType() == osTypeVideoOS then
            getTaglist()
        end
    end
end

local function getResourcelist()

    local paramData = {
        videoId = Native:nativeVideoID(),
        commonParam = Native:commonParam()
    }

    local videoInfo = Native:getVideoInfo()

    if videoInfo["extendDict"] ~= nil then
        paramData["videoInfo"] = videoInfo["extendDict"]
    end

    local paramDataString = Native:tableToJson(paramData)
    -- print("[LuaView] getResourcelist")
    --print("[LuaView] "..Native:aesEncrypt(paramDataString, OS_HTTP_PUBLIC_KEY, OS_HTTP_PUBLIC_KEY))
    mainNode.request:post(OS_HTTP_GET_RESOURCE_LIST, {
        bu_id = buId,
        device_type = deviceType,
        data = Native:aesEncrypt(paramDataString, OS_HTTP_PUBLIC_KEY, OS_HTTP_PUBLIC_KEY)
    }, function(response, errorInfo)
        if (response == nil) then
            reloadGetResourcelist()
            return
        end
        -- print("luaview getResourcelist")
        responseData = Native:aesDecrypt(response.encryptData, OS_HTTP_PUBLIC_KEY, OS_HTTP_PUBLIC_KEY)
        -- print("luaview "..responseData)

        response = toTable(responseData)
        if (response == nil) then
            reloadGetResourcelist()
            return
        end
        if (response.resCode ~= "00") then
            reloadGetResourcelist()
            return
        end
        local dataTable = response.fileUrlList
        if (dataTable == nil or table_leng(dataTable) == 0) then
            return
        end

        local videoList = {}
        local imageList = {}
        for i, v in ipairs(dataTable) do
            local lowerUrl = string.lower(v)
            local position = string.find(lowerUrl, ".mp4", 1)
            if position ~= nil and position > 0 then
                table.insert(videoList, v)
            else
                table.insert(imageList, v)
            end
        end
        if (table_leng(videoList) > 0) then
            Native:preloadVideo(videoList)
        end
        if (table_leng(imageList) > 0) then
            Native:preloadImage(imageList)
        end
    end, mainNode.media)
end

--预加载接口重试5次，服务器错误也算失败
function reloadGetResourcelist()
    preloadCount = preloadCount + 1

    if preloadCount > 5 then
        return
    end

    getResourcelist()
end

function show(args)
    print("[LuaView] main " .. tostring(roomId))
    if (roomId == nil) then
        return
    end

    mainNode.media = registerMedia()
    mainNode.request = HttpRequest()

    --加载网络请求通用参数
    local paramData = {
        videoId = Native:nativeVideoID(),
        commonParam = Native:commonParam()
    }

    local videoInfo = Native:getVideoInfo()

    if videoInfo["extendDict"] ~= nil then
        paramData["videoInfo"] = videoInfo["extendDict"]
    end

    local paramDataString = Native:tableToJson(paramData)
    --print("luaview "..Native:aesEncrypt(paramDataString, OS_HTTP_PUBLIC_KEY, OS_HTTP_PUBLIC_KEY))
    mainNode.request:post(OS_HTTP_GET_CONFIG, {
        bu_id = buId,
        device_type = deviceType,
        target_id = roomId,
        data = Native:aesEncrypt(paramDataString, OS_HTTP_PUBLIC_KEY, OS_HTTP_PUBLIC_KEY)
    }, function(response, errorInfo)
        if (response == nil) then
            return
        end
        responseData = Native:aesDecrypt(response.encryptData, OS_HTTP_PUBLIC_KEY, OS_HTTP_PUBLIC_KEY)
        --print("luaview "..responseData)
        response = toTable(responseData)
        if (response.resCode ~= "00") then
            return
        end

        if (response.confirmTime ~= nil) then
            adCheckInterval = response.confirmTime * 1000.0
        end

        mainNode.mqtt = registerMqtt(response)
        getTag()
        getResourcelist()
        --TODO 连接MQTT
    end, mainNode.media)
    --获取广告--
    --[[
    Native:get("http://mock.videojj.com/mock/5b029ad88e21c409b29a2114/api/getAds", {}, function(response, errorInfo)
        if (response == nil) then
            return
        end
        if (response.status ~= 0) then
            return
        end
        local dataTable = response.data
        if (dataTable == nil) then
            return
        end
        for key, value in pairs(dataTable) do
            if (value.id ~= nil and value.template ~= nil) then
                table.insert(repeatAdTable, value)
            end
        end
        registerMedia()
    end)
    ]] --
end
