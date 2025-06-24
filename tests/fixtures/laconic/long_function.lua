-- File with function over 15 lines (violation)

local test = {}

function test.short_function()
  return "ok"
end

function test.sixteen_line_function()
  local line1 = 1
  local line2 = line1 + 1
  local line3 = line2 + 1
  local line4 = line3 + 1
  local line5 = line4 + 1
  local line6 = line5 + 1
  local line7 = line6 + 1
  local line8 = line7 + 1
  local line9 = line8 + 1
  local line10 = line9 + 1
  local line11 = line10 + 1
  local line12 = line11 + 1
  local line13 = line12 + 1
  return line13
end

return test
