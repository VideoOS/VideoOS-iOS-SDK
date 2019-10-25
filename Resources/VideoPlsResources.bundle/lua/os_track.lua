require "os_config"
require "os_string"
--数据统计--
--local OS_TRICK_SSID = "ssid=" --ssid为""写死
--local OS_TRICK_PROJ = "proj=" .. Native:platformID() --playfromId
--local OS_TRICK_CH = "ch=" --栏目ID为""写死
--local OS_TRICK_VID = "vid=" .. Native:nativeVideoID() --房间号
--local OS_TRICK_CAT = "cat=" --事件类型 1曝光 9点击
--local OS_TRICK_TID = "tid=" --子组件的id可为空写死
--local OS_TRICK_CID = "cid=" --资源的ID
--local OS_TRICK_PTID = "ptid=" --跳转前的tid(tagId(infoid))资源的ID
--local OS_TRICK_PCID = "pcid=" --跳转前的cid(contanierId(viewid))""写死
--local OS_TRICK_TS = "ts=0" --时间跨度
--统计方法调用--
function osTrack(launchPlanId, eventType, type)
    local vid = Native:nativeVideoID()
    if (vid == nil) then
        return
    end
    if (launchPlanId == nil) then
        return
    end
    if (eventType == nil) then
        return
    end
    if (type == nil) then
        return
    end

    local params = {}
    local appkey = Native:appKey()
    if appkey ~= nil then
        params = {
            videoId = vid,
            type = tostring(type),
            eventType = tostring(eventType),
            launchPlanId = tostring(launchPlanId),
            appKey = tostring(appkey)
        }
    else
        params = {
            videoId = vid,
            type = tostring(type),
            eventType = tostring(eventType),
            launchPlanId = tostring(launchPlanId)
        }
    end

    local paramDataString = Native:tableToJson(params)
    
    Native:post(OS_HTTP_GET_STARTS, {
        bu_id = buId,
        device_type = deviceType,
        data = Native:aesEncrypt(paramDataString, OS_HTTP_PUBLIC_KEY, OS_HTTP_PUBLIC_KEY)
    })
end

function osThirdPartyTrack(url)
    if (url ~= nil and string.match(tostring(url), "http") == "http") then
        Native:get(url, nil, nil, false)
    end
end