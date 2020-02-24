require "os_config"
--字符串集合--
-- OS_HTTP_HOST = "http://videopublicapi.videojj.com/videoos-api/"
OS_HTTP_HOST = Native:videoOShost()
-- OS_HTTP_HOST = "http://dev-videopublicapi.videojj.com/videoos-api/"

OS_HTTP_GET_CONFIG = OS_HTTP_HOST .. "/api/config"
OS_HTTP_GET_TAG_LIST = OS_HTTP_HOST .. "/api/v3/queryLaunchInfo"
OS_HTTP_GET_RESOURCE_LIST = OS_HTTP_HOST .. "/api/preloadLaunchInfo"
OS_HTTP_GET_MOBILE_QUERY = OS_HTTP_HOST .. "/api/mobileQuery"
OS_HTTP_POST_MOBILE_QUERY = OS_HTTP_HOST .. "/api/mobileModify"
OS_HTTP_GET_COMMON_QUERY = OS_HTTP_HOST .. "/api/commonQuery"
OS_HTTP_GET_SIMULATION_TAG = OS_HTTP_HOST .. "/simulation/queryInfo"
OS_HTTP_POST_CHECK_HOTSPOT = OS_HTTP_HOST .. "/api/v3/notice"
OS_HTTP_POST_CHECK_HOTSPOT_TRACK = OS_HTTP_HOST .. "/statisticConfirmLaunch"

--数据统计网络相关
OS_HTTP_GET_STARTS = OS_HTTP_HOST .. "/statistic/v2"

--网络请求RSA Public Key
OS_HTTP_PUBLIC_KEY = Native:appSecret() --"MIGfMA0GCSqGSIb3DQEBAQUAA4GNADCBiQKBgQCBlxdQe+B3bCL3+km31ABB23sXUB0A3owEBodWlPeikgfEw/JfbZXuiKFoIqAbjmzpDvAE4PYAU4wBjE01wRNLg4KLJyorGLkx6I6gHE67mZqLryepxZdwd8MwzQCsoN3+PAQYUJz54Flc6e14l/LVDyggw/HN/OD9iXC027IVDQIDAQAB"
--icon url
local OS_ICON_HEAD = "http://videojj-mobile.oss-cn-beijing.aliyuncs.com/resource/os/"
if Native:isDebug() == false then
    OS_ICON_HEAD = "http://videojj-mobile.oss-cn-beijing.aliyuncs.com/resource/os/" --todo 修改为正式地址
end

OS_ICON_CLOSE = OS_ICON_HEAD .. "os_bubble_back@3x.png"
OS_ICON_BUBBLE_PROMPT_LEFT = OS_ICON_HEAD .. "os_bubble_prompt_left@3x.png"
OS_ICON_BUBBLE_PROMPT_RIGHT = OS_ICON_HEAD .. "os_bubble_prompt_right@3x.png"
OS_ICON_WEDGE_BACK = OS_ICON_HEAD .. "os_wedge_back@3x.png"
OS_ICON_WEDGE_CLOSE = OS_ICON_HEAD .. "os_wedge_close@3x.png"
OS_ICON_WIN_LINK_BACK = OS_ICON_HEAD .. "os_link_back@3x.png"