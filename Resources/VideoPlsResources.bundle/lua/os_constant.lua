--数据统计
cat_type_preshow = 10
cat_type_show = 12
cat_type_click_link = 47
cat_type_dg_show = 34
cat_type_click = 9
cat_type_close = 20

--广告事件类型
eventTypeShow = 2
eventTypeClick = 3
eventTypeClose = 4
eventTypeBack = 5

--平台处理类型
actionTypeNone = 0
actionTypeOpenUrl = 1
actionTypePauseVideo = 2
actionTypePlayVideo = 3
actionTypeGetItem = 4

--视频类型
osTypeDefault = 0
osTypeVideoOS = 1
osTypeLiveOS = 2

--页面层次
osHotspotViewPriority = 1
osInfoViewPriority = 2

--容器层级
osTopLevel = 5

--设备类型 1 iOS 2 Android
deviceType = 2
if System.ios() then
	deviceType = 1
end

buId = "videoos"