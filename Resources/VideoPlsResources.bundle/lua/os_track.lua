require "os_config"

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
--sdk
--统计方法调用--
function osTrack(cat, dg, ise)
    --https://va.videojj.com/track/v6/va.gif
    local proj = Native:platformID()
    if (proj == nil) then
        proj = ""
    end
    local vid = Native:nativeVideoID()
    if (vid == nil) then
        vid = ""
    end
    if (cat == nil) then
        cat = ""
    end
    if (dg == nil) then
        cid = ""
    end
    if (ise == nil) then
        ise = ""
    end

    local s, h = System.screenSize()
    local rs = s .. "x" .. h
    local trickTable = {
        ssid = "",
        proj = proj,
        ch = "",
        vid = vid,
        cat = cat,
        dg = dg,
        ise = ise,
        tid = "",
        cid = "",
        ptid = "",
        pcid = "",
        rs = rs,
        bu = "videoos"
    }

    --    local trackUrl = "http://va.videojj.com/track/v6/va.gif"
    local trackUrl = "http://test-va.videojj.com/track/v6/va.gif"
--    if System.ios() then
--        if Native:isDebug() > 1 then
--            trackUrl = "http://test-va.videojj.com/track/v6/va.gif"
--        end
--    end

    Native:get(trackUrl,
        trickTable,
        nil,
        false)
end

function osThirdPartyTrack(url)
    if (url ~= nil and string.match(tostring(url), "http") == "http") then
        Native:get(url, nil, nil, false)
    end    
end