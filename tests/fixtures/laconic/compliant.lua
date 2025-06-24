-- Compliant file: under 100 lines, all functions under 15 lines

local test = {}

function test.short_function()
  return "hello"
end

function test.another_short(param)
  if param then
    return param * 2
  end
  return 0
end

function test.exactly_fifteen_lines()
  local a = 1
  local b = 2
  local c = 3
  local d = 4
  local e = 5
  local f = 6
  local g = 7
  local h = 8
  local i = 9
  local j = 10
  local k = 11
  local l = 12
  return a + b + c + d + e + f + g + h + i + j + k + l
end

return test