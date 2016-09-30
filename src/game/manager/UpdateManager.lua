--
-- 更新下载管理
--
local UpdateManager = class("UpdateManager")
--------------------------------------------------------
local DEFAULT_ZIP_NAME = "temp.zip"

function UpdateManager:setServer( _server, _storage )
	self.server = _server
	self.storage = _storage
end

function UpdateManager:createHTTPRequest(callback, url, method)
    if not method then method = "GET" end
    if string.upper(tostring(method)) == "GET" then
        method = cc.kCCHTTPRequestMethodGET
    else
        method = cc.kCCHTTPRequestMethodPOST
    end
    return cc.HTTPRequest:createWithUrl(callback, url, method)
end

function UpdateManager:downloadFile( _urlFile, _storageFile, _funCallBack, _waitTime )
	local url = self.server.._urlFile
	local path = self.storage.._storageFile

	-- print("------------url:"..url.."   path:"..path)

	local index = 0
	request = self:createHTTPRequest(function(event)
            self:onResponse(event, index, path, _funCallBack)
        end, url, "GET")
    if request then
        request:setTimeout(_waitTime or 20)
        request:start()
    end
end

-- 200 - 服务器成功返回网页
-- 404 - 请求的网页不存在
-- 503 - 服务器暂时不可用
function UpdateManager:onResponse( _event, _index, _storage, _funCallBack )
	local request = _event.request
	-- print("REQUEST %d – _event.name = %s", _index, _event.name)
    if _event.name == "completed" then
        -- print("REQUEST %d – getResponseStatusCode() = %d", _index, request:getResponseStatusCode())
        if request:getResponseStatusCode() ~= 200 then
	        if(_funCallBack~=nil)then _funCallBack({event = "failure"}) end
        else
        	io.mkdir(_storage)
	        io.writefile(_storage,request:getResponseData()) --保存到本地的文件
	        -- print("--------writefile:", _storage)
	        if(_funCallBack~=nil)then _funCallBack({event = "succeed"}) end
        end
    elseif _event.name == "failed" then
        if(_funCallBack~=nil)then _funCallBack({event = "failure"}) end
    else 
        print("REQUEST:", _index," – getErrorCode()=", request:getErrorCode(), "  getErrorMessage()=",request:getErrorMessage(),"  name:",_event.name)
        -- self:endProcess()
    end
end

--------------------------------------------------------
return UpdateManager
