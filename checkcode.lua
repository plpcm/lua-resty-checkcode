
local checkcode = require("cmcheckcode")
local method = ngx.req.get_method()
local uri = ngx.var.uri
local cache_code = ngx.shared.checkcode


function get_from_cache(key)
	local value = cache_code:get(key)
	return value
end

function set_to_cache(key, value, exptime)
	if not exptime then
		exptime = 0 
	end 
	local succ, err, forcible = cache_code:set(key, value, exptime)
	--ngx.say("err:" .. err .. '<br/>')
	return succ
end

if uri == '/restapi/v1/captchas' or uri == '/' then
	if method == 'GET' then
		ngx.say('{"errno": -1,"errmsg": "Method Not Allowed","data":""}')
		ngx.exit(ngx.HTTP_OK)
	else
		local hash = checkcode.getmd5key()
		set_to_cache(hash, '', 300) -- remain 5min
		--ngx.say('{"code":"' .. hash .. '"}')
		ngx.say('{"errno":0,"errmsg": "success","data":"' .. hash .. '"}')
		ngx.exit(ngx.HTTP_OK)
	end
else
	if method == 'GET' then
		local hash = string.sub(ngx.var.hashkey, 2)
		local value =get_from_cache(hash)
		if value then
			local code = checkcode.doIt()
			set_to_cache(hash, code, 300)
			--	local value =get_from_cache(hash)
			--	ngx.say(value)
			--	ngx.say(code)
			--	ngx.exit(200)
			local res = ngx.location.capture('/codeimg/' .. code)
			ngx.header.content_type = "image/png";
			ngx.say(res.body)
			ngx.exit(ngx.HTTP_OK)
		end
		ngx.say('{"errno": -2,"errmsg": "验证码hash已经失效","data": ""}')
		ngx.exit(ngx.HTTP_OK)
	else
		local check = string.sub(ngx.var.hashkey, 2)
		if check == "check" then
			ngx.req.read_body()
			local arg = ngx.req.get_post_args()
			if arg.key and arg.code then
				local value =get_from_cache(arg.key)
				set_to_cache(arg.key, nil, 1) -- remain 1s
				--ngx.say(arg.key)
				--ngx.say(arg.code)
				--ngx.say(value)
				if value and string.lower(value) == string.lower(arg.code) then
					ngx.say('{"errno": 0,"errmsg": "success" }')
					ngx.exit(ngx.HTTP_OK)
				end
				ngx.say('{"errno": -3,"errmsg": "fail" }')
				ngx.exit(ngx.HTTP_OK)
			end
			ngx.say('{"errno": -1,"errmsg": "Method Not Allowed","data": ""}')
			ngx.exit(ngx.HTTP_OK)
		end
		ngx.say('{"errno": -1,"errmsg":"Method Not Allowed","data": ""}')
		ngx.exit(ngx.HTTP_OK)
	end
end
ngx.say('{"errno": -1,"errmsg": "Method Not Allowed","data": ""}')
ngx.exit(ngx.HTTP_OK)
