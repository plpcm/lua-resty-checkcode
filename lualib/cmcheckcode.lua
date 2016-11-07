-- 图片验证码

local _M = { _VERSION = '1.0' }
local gd = require("gd")
local math = math

--------------------------------------------------------------
--运行配置项
--------------------------------------------------------------
--字体：-1-使用gd.FONT_GIANT字体;1-使用随机字体;其他-使用“fonts”中第一个字体
--字体预先在变量“fonts”中定义；如果fonts没有值，将搜索系统中的所有字体，字体路径在“FONT_PATH”中预定义
local FONT = 1

--每个字符字体随机：1-是，其他-否
--仅当“FONT”值为“1”时，本变量起作用
local FONT_RANDOM_CHAR = 0

--每个字符字体大小是否随机：1-是，其他-否
--仅当FONT^=-1时起作用
local FONT_SIZE_RANDOM = 1

--是否增加线条干扰：1-是；其他-否
local XLINE_FALG = 1

--干扰线条的最多条数
--仅当“XLINE_FALG”的值为“是”是，本变量起作用
local XLINE_LIMIT = 6

--验证码类型：TEXT-字符串；EXPRESSION-表达式
local MARK_TYPE = "TEXT"
--MARK_TYPE="EXPRESSION"

--字符个数：仅当“MARK_TYPE”=“TEXT”时，本变量起作用
local TEXT_NUM = 4

--字符随机字符串长度
local TEXT_LENS_NUM = 21

--表达式项数限制（最多不超过EXPRESSION_ITEMS项）：仅当“MARK_TYPE”=“EXPRESSION”时，本变量起作用
local EXPRESSION_ITEMS = 3

--生成验证码个数
local MARK_NUM = 1


--------------------------------------------------------------
--预定义变量
--------------------------------------------------------------
--词典
local all = {'a','b','c','d','e','f','g','h','i','j','k','l','m','n','o','p','q','r','s','t','u','v','w','x','y','z','A','B','C','D','E','F','G','H','I','J','K','L','M','N','O','P','Q','R','S','T','U','V','W','X','Y','Z','1','2','3','4','5','6','7','8','9','0',"1","2","3","4","5","6","7","8","9"}

local dict = {'a','b','c','d','e','f','g','h','i','j','k','l','m','n','o','p','q','r','s','t','u','v','w','x','y','z','A','B','C','D','E','F','G','H','I','J','K','L','M','N','O','P','Q','R','S','T','U','V','W','X','Y','Z','1','2','3','4','5','6','7','8','9','0'}
local numbers = {"1","2","3","4","5","6","7","8","9"}--表达式可使用数字，排除0
local operators = {"+","-","*"}--表达式可使用运算符，不支持“/”

--随机种子，防止通过获取系统时间得到随机数种子，直接计算出验证码
math.randomseed(os.time())

--大小
local IMG_WIDTH = 100
local IMG_HEIGHT = 40

--颜色
local im2 = gd.createTrueColor(IMG_WIDTH,IMG_HEIGHT)
local fg = im2:colorAllocate(129,32,28)--前景色
local bg = im2:colorAllocate(216,235,238)--背景色
local red = im2:colorAllocate(255,0,0)--干扰线
local green = im2:colorAllocate(0,255,0)--干扰线

--字体
local FONT_PATH="C:/WINDOWS/Fonts/"--系统字体路径
--fonts={}
--local fonts = {"courbd.ttf","courbi.ttf","DejaVuMonoSans.ttf","DejaVuMonoSansBold.ttf","DejaVuMonoSansBoldOblique.ttf","DejaVuMonoSansOblique.ttf","lucon.ttf","monosbi.ttf","nina.ttf","simhei.ttf","simkai.ttf","swissci.ttf","tahomabd.ttf","timesbd.ttf","timesbi.ttf","timesi.ttf","trebuc.ttf","trebucit.ttf"}
local fonts = {"Arial", "Arial:bold", "Arial:italic", "Arial:bold:italic", "Times New Roman", "Comic Sans MS"}
local font_size = {14,15,16,17,18,19,20}--随机字体大小

--生成的随机key
--local stringkey = ""
--生成的随机码
local stringmark = ""

--------------------------------------------------------------
--功能函数
--------------------------------------------------------------
--初始化：创建图片、设置背景
local function init()
    im2 = gd.createTrueColor(IMG_WIDTH, IMG_HEIGHT)
	gd.useFontConfig(true)
    im2:filledRectangle(0,0,IMG_WIDTH,IMG_HEIGHT,bg)
    stringmark = ""
end

--查找字体
--[[
function searchFont()
    if table.getn(fonts) == 0 then --没有指定字体，就搜索系统字体
        local i = 1
        for file in lfs.dir(FONT_PATH) do
            if string.find(file,".ttf")and not string.find(file,"esri")  then --排除特定字体
                fonts[i] = file
                i = i + 1
            end
        end
    end
end
]]

--生成text字符串
local function makeText(dict, lens)
    local num = table.getn(dict)
	local _stringmark = ''
    for i = 1, lens do
        _stringmark = _stringmark .. dict[math.random(num)]
    end
	return _stringmark
end

--生成表达式字符串
local function makeExpression()
    local n = math.random(2,3) --表达式项数
    local strings = {}
    for i = 1, n*2-1 do --表达式项数+运算符项数
        local str = ""
        if i%2 == 1 then --数字
            local n2 = math.random(1, 2)
            for j = 1, n2 do --每个数字最多2位
                str = str .. numbers[math.random(9)]
            end
        else --运算符
            str = operators[math.random(3)]
        end
        strings[i] = str
    end 
    return strings
end

--计算md5的key
function _M:getmd5key()
	local resty_md5 = require "resty.md5"
	local str = require "resty.string"
	local time = ngx.time()
	local md5 = resty_md5:new()
	md5:update("" .. time)
	local md5key = str.to_hex(md5:final())
	return md5key
end


--主函数
function _M:doIt()
    -- searchFont()
    local numfonts = table.getn(fonts)
    -- if numfonts < 1 then
    --     print("没有找到字体!")
    --     return
    -- end

    -- for i = 1, MARK_NUM do
	init()
	local font = fonts[0];
	local fontsize = 20;

	if MARK_TYPE == "TEXT" then --普通字符串验证码
		stringmark = makeText(all, TEXT_NUM)
		-- stringkey = makeText(all, TEXT_LENS_NUM)
		if FONT == -1 then
			im2:string(gd.FONT_GIANT, 18, 10, stringmark, fg)
		else
			for nIndex = 1, string.len(stringmark) do
				local font, fontsize
				if FONT == 1 then font=fonts[math.random(numfonts)] end
				if FONT_SIZE_RANDOM == 1 then fontsize=font_size[math.random(7)] end
				im2:stringFT(fg, font, fontsize, math.random()/math.pi, 5+(nIndex-1)*15, 25, string.sub(stringmark,nIndex,nIndex))
				--im2:stringFT(fg,font,18,math.random()/math.pi,5+(nIndex-1)*15, 25, "A")
			end        
		end
	elseif MARK_TYPE == "EXPRESSION" then --表达式验证码
		local strings = makeExpression()
		local raise = 0
		local ncharacter = 0 
		for j = 1 , table.getn(strings) do
			if j%2 == 0 then raise = 3 end
			stringmark = stringmark..strings[j]
			if FONT == 1 then font = fonts[math.random(numfonts)] end
			if FONT_SIZE_RANDOM == 1 then fontsize = font_size[math.random(5)] end          
			im2:stringFT(fg, FONT_PATH .. font, fontsize, math.random()/math.pi, 5+ncharacter*12+raise, 25, strings[j])
			ncharacter = ncharacter + string.len(strings[j])
		end
		--            print(stringmark) 
		--            value=tonumber(stringmark)
		--            print(value)
	end

	--  随机线条干扰
	if XLINE_FALG == 1 then
		local xlineNum = math.random(XLINE_LIMIT)
		for i = 1, xlineNum do
			im2:line(math.random(IMG_WIDTH), math.random(IMG_HEIGHT), math.random(IMG_WIDTH), math.random(IMG_HEIGHT), green)
		end
	end

	im2:png("/dev/shm/checkcode/" .. stringmark, 10)
	return stringmark
	--end
end
--start=os.clock()
--doIt()
--print(os.clock()-start)
return _M
