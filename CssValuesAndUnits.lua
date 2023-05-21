--[[
处理 值和单位

参考链接：
- CSS Values and Units Module Level 4
  https://drafts.csswg.org/css-values-4/
]]

local function Pattern(...)
	return {type = 'pattern', ...}
end


--[[
2.2. Component Value Combinators

参数combinator是这些值之一：
- ''
- '&&'
- '||'
- '|'
]]
local function Combinator(combinator, ...)
	return {type = 'combinator', combinator = combinator, ...}
end


--[[
2.3. Component Value Multipliers

参数multiplier是这些值之一：
- '*'
- '+'
- '?'
- number (A代表CSS规范的{A})
- table{number[, number]} ({A, B}代表CSS规范{A,B}，{A}代表CSS规范的{A,})
- '#'
- '!'
]]
local function Multiplier(multiplier, component)
	return {type = 'multiplier', multiplier = multiplier, component}
end


--[[
上面两个函数的语法糖

例：
- '//':C(...)
- {1,3}:C(...)
]]
local function C(pseudoConstructor, ...)
	local cTypes = {
		number = Multiplier,
		table = Multiplier,
	}
	local cNames = {
		[''] = Combinator,
		['&&'] = Combinator,
		['||'] = Combinator,
		['|'] = Combinator,
		['*'] = Multiplier,
		['+'] = Multiplier,
		['?'] = Multiplier,
		['#'] = Multiplier,
		['!'] = Multiplier,
	}
	return (cTypes[pseudoConstructor] or cNames[pseudoConstructor])(...)
end


--[[
2.6. Functional Notation Definitions
]]
local function Function(name, argumentsComponent)
	return {type = 'function', name = name, argumentsComponent}
end


--[[
3. 跳过
]]


--[[
4. 跳过
]]


--[[
5.2. Integers: the <integer> type
]]
local function Integer(value)
	return {type = 'integer', value}
end

--[[
5.3. Real Numbers: the <number> type
]]
local function Number(value)
	return {type = 'number', value}
end


--[[
5.4. Numbers with Units: dimension values
]]
local function Dimension(value)
	return {type = 'dimension', value}
end


--[[
5.5. Percentages: the <percentage> type

设计：value是用0.5还是50呢？？？
]]
local function Percentage(value)
	return {type = 'percentage', value}
end





local function Value(component)
	return {type = 'value', component}
end





integer =

percentage = '%%'