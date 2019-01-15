--获取tabke长度--
function table_leng(t)
    if (t == nil) then
        return 0
    end
    local leng = 0
    for k, v in pairs(t) do
        leng = leng + 1
    end
    return leng;
end
function toTable(data) --string json 转table
    local dataTable
    if (type(data) == 'string') then
        if (System.android()) then
            dataTable = Json:toTable(data)
        else
            dataTable = Native:jsonToTable(data)
        end
    else
        dataTable = data
    end
    return dataTable
end
--四舍五入--
function rounded(decimal)
    decimal = math.floor(decimal)
    if (tostring(decimal) == "nan") then
        return 0
    else
        return decimal
    end
end

--延时执行
function performWithDelay(callback, delay)
    if callback ~= nil and delay ~= nil then
        local timer = Timer()
        timer:interval(delay)
        timer:repeatCount(false)
        timer:delay(delay / 1000)
        timer:callback(callback)
        timer:start()
        return timer
    end
end

--MQTT消息热点关闭方法
function checkMqttHotspotToSetClose(data, callback)
    if data ~= nil and data.from ~= nil and data.from == "mqtt" then
        performWithDelay(callback, data.duration)
    end
end
