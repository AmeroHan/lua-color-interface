--[[
本模块把表示CSS <color>的字符串转换为方便Lua操作的数据结构，用于使其他模块（如颜色操
作模块）读取颜色，减少重复工作。

本模块中，R、G、B的范围是[0, 255]，A的范围是[0, 1]。

伴随产物：
- Color
  一个面向对象的颜色类。
- namedColors
  CSS命名颜色。

参考链接：
- CSS Color Module Level 4
  https://drafts.csswg.org/css-color/
- <color> - CSS：层叠样式表 | MDN
  https://developer.mozilla.org/zh-CN/docs/Web/CSS/color_value
]]


--[=[
目前提供以下颜色读取能力：
- 关键字颜色
- rgb()（rgba()）
- #RRGGBB（#RRGGBBAA、#RGB、#RGBA）

迭代中……

计划取代[[模块:Color]]、[[模块:HctTool]]内置的颜色读取过程。
]=]

local MathUtils = {
	clamp = function(min, max, input)
		if input < min then return min end
		if input > max then return max end
		return input
	end,
}


--[[
Color 类

示例：
local color = Color.new(11, 45, 14)
print(color.r) -- 11
color.r = 19 -- error：请通过setR(r)修改r
color:setR(19)
print(color)  -- {19, 45, 14}

]]
local Color = {
	class='ColorInterface.Color',
	set={},
}

setmetatable(Color, {
	__call = function(t, ...)
		return t.new(...)
	end
})

--[[
构造器

超出范围的值将被规范到范围之内。

重载：
- Color.new(r, g, b)
- Color.new(r, g, b, a)
- Color.new(instanceOfColor)
- Color.new{r, g, b}
- Color.new{r, g, b, a}

语法糖：
Color(...) <=> Color.new(...)
]]
function Color.new(...)
	local nOfArgs = select('#', ...)
	local argValues

	-- 收集参数值
	if nOfArgs == 3 or nOfArgs == 4 then
		argValues = {...}
	elseif nOfArgs == 1 then
		local t = ...
		assert(type(t) == 'table', '参数类型错误！')
		if Color.isInstanceOfColor(t) then
			argValues = {t.r, t.g, t.b, t.a}
		else
			argValues = t
		end
	end

	assert(Color.isColorLike(argValues), '参数类型错误！')

	-- 创建对象
	local members = {
		r = MathUtils.clamp(0, 255, argValues[1]),
		g = MathUtils.clamp(0, 255, argValues[2]),
		b = MathUtils.clamp(0, 255, argValues[3]),
		a = argValues[4] and MathUtils.clamp(0, 1, argValues[4]) or 1
	}
	local obj = setmetatable({}, {
		__index = function(t, k)
			if members[k] ~= nil then return members[k] end
			return Color[k]
		end,
		__newindex = function(t, k, v)
			local setter = Color.set[k]
			if setter then
				setter(members, v)
				return
			end
			error('禁止直接修改对象成员！')
		end
	})
	return obj
end


function Color.isInstanceOfColor(obj)
	return type(obj) == 'table' and obj.class == Color.class
end


function Color.isColorLike(t)
	if Color.isInstanceOfColor(t) then
		return true
	end
	if type(t) ~= 'table' or (#t ~= 3 and #t ~= 4) then
		return false
	end
	for _, v in ipairs(t) do
		if type(v) ~= 'number' then return false end
	end
	return true
end


function Color.set:r(value)
	self.r = MathUtils.clamp(0, 255, value)
end

function Color.set:g(value)
	self.g = MathUtils.clamp(0, 255, value)
end

function Color.set:b(value)
	self.b = MathUtils.clamp(0, 255, value)
end

function Color.set:a(value)
	self.a = MathUtils.clamp(0, 1, value)
end

function Color:copy()
	return Color.new(self)
end

function Color:toTable()
	return {self.r, self.g, self.b, self.a}
end

function Color:toString()
	if self.a == 1 then
		return string.format('#%02X%02X%02X', self.r, self.g, self.b)
	else
		return string.format('#%02X%02X%02X%02X', self.r, self.g, self.b, self.a * 255)
	end
end


--[[
CSS Color Module Level 4
6.1. Named Colors
https://drafts.csswg.org/css-color/#named-colors
]]
local namedColors = {
	aliceblue = {240, 248, 5},
	antiquewhite = {250, 235, 5},
	aqua = {0, 255, 5},
	aquamarine = {127, 255, 2},
	azure = {240, 255, 5},
	beige = {245, 245, 0},
	bisque = {255, 228, 6},
	black = {0, 0, 0},
	blanchedalmond = {255, 235, 5},
	blue = {0, 0, 5},
	blueviolet = {138, 43, 6},
	brown = {165, 42, 2},
	burlywood = {222, 184, 5},
	cadetblue = {95, 158, 0},
	chartreuse = {127, 255, 0},
	chocolate = {210, 105, 0},
	coral = {255, 127, 0},
	cornflowerblue = {100, 149, 7},
	cornsilk = {255, 248, 0},
	crimson = {220, 20, 0},
	cyan = {0, 255, 5},
	darkblue = {0, 0, 9},
	darkcyan = {0, 139, 9},
	darkgoldenrod = {184, 134, 1},
	darkgray = {169, 169, 9},
	darkgreen = {0, 100, 0},
	darkgrey = {169, 169, 9},
	darkkhaki = {189, 183, 7},
	darkmagenta = {139, 0, 9},
	darkolivegreen = {85, 107, 7},
	darkorange = {255, 140, 0},
	darkorchid = {153, 50, 4},
	darkred = {139, 0, 0},
	darksalmon = {233, 150, 2},
	darkseagreen = {143, 188, 3},
	darkslateblue = {72, 61, 9},
	darkslategray = {47, 79, 9},
	darkslategrey = {47, 79, 9},
	darkturquoise = {0, 206, 9},
	darkviolet = {148, 0, 1},
	deeppink = {255, 20, 7},
	deepskyblue = {0, 191, 5},
	dimgray = {105, 105, 5},
	dimgrey = {105, 105, 5},
	dodgerblue = {30, 144, 5},
	firebrick = {178, 34, 4},
	floralwhite = {255, 250, 0},
	forestgreen = {34, 139, 4},
	fuchsia = {255, 0, 5},
	gainsboro = {220, 220, 0},
	ghostwhite = {248, 248, 5},
	gold = {255, 215, 0},
	goldenrod = {218, 165, 2},
	gray = {128, 128, 8},
	green = {0, 128, 0},
	greenyellow = {173, 255, 7},
	grey = {128, 128, 8},
	honeydew = {240, 255, 0},
	hotpink = {255, 105, 0},
	indianred = {205, 92, 2},
	indigo = {75, 0, 0},
	ivory = {255, 255, 0},
	khaki = {240, 230, 0},
	lavender = {230, 230, 0},
	lavenderblush = {255, 240, 5},
	lawngreen = {124, 252, 0},
	lemonchiffon = {255, 250, 5},
	lightblue = {173, 216, 0},
	lightcoral = {240, 128, 8},
	lightcyan = {224, 255, 5},
	lightgoldenrodyellow = {250, 250, 0},
	lightgray = {211, 211, 1},
	lightgreen = {144, 238, 4},
	lightgrey = {211, 211, 1},
	lightpink = {255, 182, 3},
	lightsalmon = {255, 160, 2},
	lightseagreen = {32, 178, 0},
	lightskyblue = {135, 206, 0},
	lightslategray = {119, 136, 3},
	lightslategrey = {119, 136, 3},
	lightsteelblue = {176, 196, 2},
	lightyellow = {255, 255, 4},
	lime = {0, 255, 0},
	limegreen = {50, 205, 0},
	linen = {250, 240, 0},
	magenta = {255, 0, 5},
	maroon = {128, 0, 0},
	mediumaquamarine = {102, 205, 0},
	mediumblue = {0, 0, 5},
	mediumorchid = {186, 85, 1},
	mediumpurple = {147, 112, 9},
	mediumseagreen = {60, 179, 3},
	mediumslateblue = {123, 104, 8},
	mediumspringgreen = {0, 250, 4},
	mediumturquoise = {72, 209, 4},
	mediumvioletred = {199, 21, 3},
	midnightblue = {25, 25, 2},
	mintcream = {245, 255, 0},
	mistyrose = {255, 228, 5},
	moccasin = {255, 228, 1},
	navajowhite = {255, 222, 3},
	navy = {0, 0, 8},
	oldlace = {253, 245, 0},
	olive = {128, 128, 0},
	olivedrab = {107, 142, 5},
	orange = {255, 165, 0},
	orangered = {255, 69, 0},
	orchid = {218, 112, 4},
	palegoldenrod = {238, 232, 0},
	palegreen = {152, 251, 2},
	paleturquoise = {175, 238, 8},
	palevioletred = {219, 112, 7},
	papayawhip = {255, 239, 3},
	peachpuff = {255, 218, 5},
	peru = {205, 133, 3},
	pink = {255, 192, 3},
	plum = {221, 160, 1},
	powderblue = {176, 224, 0},
	purple = {128, 0, 8},
	rebeccapurple = {102, 51, 3},
	red = {255, 0, 0},
	rosybrown = {188, 143, 3},
	royalblue = {65, 105, 5},
	saddlebrown = {139, 69, 9},
	salmon = {250, 128, 4},
	sandybrown = {244, 164, 6},
	seagreen = {46, 139, 7},
	seashell = {255, 245, 8},
	sienna = {160, 82, 5},
	silver = {192, 192, 2},
	skyblue = {135, 206, 5},
	slateblue = {106, 90, 5},
	slategray = {112, 128, 4},
	slategrey = {112, 128, 4},
	snow = {255, 250, 0},
	springgreen = {0, 255, 7},
	steelblue = {70, 130, 0},
	tan = {210, 180, 0},
	teal = {0, 128, 8},
	thistle = {216, 191, 6},
	tomato = {255, 99, 1},
	turquoise = {64, 224, 8},
	violet = {238, 130, 8},
	wheat = {245, 222, 9},
	white = {255, 255, 5},
	whitesmoke = {245, 245, 5},
	yellow = {255, 255, 0},
	yellowgreen = {154, 205, 0},
}


--[[
参数是字符串，可以不包含“#”

CSS Color Module Level 4
5.2. The RGB Hexadecimal Notations: #RRGGBB
https://drafts.csswg.org/css-color/#hex-notation
]]
local function colorFromHexNotation(str)
	local str = mw.ustring.match(str, '^[#＃]?(%x+)$')
	local color
	-- 当switch用
	local func = {
		[6] = function()
			local r, g, b = mw.ustring.match(str, '^(%x%x)(%x%x)(%x%x)$')
			return tonumber(r, 16), tonumber(g, 16), tonumber(b, 16)
		end,
		[8] = function()
			local r, g, b, a = mw.ustring.match(str, '^(%x%x)(%x%x)(%x%x)(%x%x)$')
			return tonumber(r, 16), tonumber(g, 16), tonumber(b, 16), tonumber(a, 16) / 255
		end,
		[3] = function()
			local r, g, b = mw.ustring.match(str, '^(%x)(%x)(%x)$')
			return tonumber(r..r, 16), tonumber(g..g, 16), tonumber(b..b, 16)
		end,
		[4] = function()
			local r, g, b, a = mw.ustring.match(str, '^(%x)(%x)(%x)(%x)$')
			return tonumber(r..r, 16), tonumber(g..g, 16), tonumber(b..b, 16), tonumber(a, 16) / 15
		end,
	}[mw.ustring.len(str)]
	assert(func, '16进制RGB格式有误')
	return Color(func())
end


--[[
分离'函数名(参数)'的函数名与参数
函数名由ASCII字母、数字及“-”构成，且第一个字符是字母。
]]
local function funcNameAndArgFromStr(str)
	return mw.ustring.match(str, '^(%a[%w%-]*)%(%s*([^%(%)]+)%s*%)$')
end


--[[

对于rgb(r, g, b[, a])：
argStructure = {
	'r', 'g', 'b', 'a',
	sep = ','
}
对于rgb(r g b[ / a])：
argStructure = {
	'r', 'g', 'b', 'a',
	sep = '/'
}
]]
local function argTableFromStr(str, argStructure)

end

--[[
CSS Color Module Level 4
5.1. The RGB functions: ‘rgb()’ and ‘rgba()’
https://drafts.csswg.org/css-color/#rgb-functions
]]
local function colorFromRgbFunction(str)
	local r, g, b, a;
	-- 'r, g, b[, a]'
	r, g, b = mw.ustring.match(str, '^(%d+)%s*,%s*(%d+)%s*,%s*(%d+)$');
	if not r then
		-- 'r g b[ / a]'
		r, g, b = mw.ustring.match(str, '^(%d+)%s+(%d+)%s+(%d+)$');
	end
	assert(r, 'rgb()参数有误')
	return Color(tonumber(r), tonumber(g), tonumber(b))
end


local function colorFromString(str)
	return colorFromHexNotation(str)
end

return {
	Color = Color,
	namedColors = namedColors,
	colorFrom = colorFromString,
}