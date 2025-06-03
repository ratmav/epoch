-- Sequential test runner to replace plenary.test_harness
-- Uses plenary.busted directly to avoid hanging child process issues

-- Load minimal_init to set up environment
package.path = './lua/?.lua;' .. package.path

-- Load our minimal test setup
dofile('./tests/minimal_init.lua')

local function find_test_files(directory)
  local test_files = {}
  local handle = io.popen('find ' .. directory .. ' -name "*_spec.lua" -type f | sort')
  
  if handle then
    for filepath in handle:lines() do
      table.insert(test_files, filepath)
    end
    handle:close()
  end
  
  return test_files
end

local function run_test_file(filepath)
  print("Running: " .. filepath)
  
  -- Use os.execute to run each test file in a separate nvim process
  -- This mimics what the individual SPEC tests do
  local cmd = string.format(
    'NVIM_INSTALL_MODE=1 nvim --headless -c "lua package.path=\'%s/lua/?.lua;\'..package.path" -c "lua require(\'plenary.test_harness\').test_directory(\'%s\', {minimal_init = \'%s/tests/minimal_init.lua\'})" -c "quit" 2>&1',
    vim.fn.getcwd(),
    filepath,
    vim.fn.getcwd()
  )
  
  local handle = io.popen(cmd)
  local result = handle:read("*all")
  local success = handle:close()
  
  print(result)
  
  -- Check if test passed based on exit code and output
  if success and not result:match("Failed") and result:match("Success") then
    return true
  else
    return false
  end
end

local function main()
  local test_dir = './tests'
  local test_files = find_test_files(test_dir)
  
  -- Filter out helper files
  local actual_tests = {}
  for _, filepath in ipairs(test_files) do
    if not filepath:match('/fixtures/') and 
       not filepath:match('/helpers/') and 
       not filepath:match('/scripts/') and
       not filepath:match('minimal_init') and
       not filepath:match('run_all_tests') then
      table.insert(actual_tests, filepath)
    end
  end
  
  print(string.format("🧪 Running %d test files", #actual_tests))
  print("========================================")
  
  local passed = 0
  local failed = 0
  local total_tests = 0
  local start_time = os.time()
  
  for _, filepath in ipairs(actual_tests) do
    local result = run_test_file(filepath)
    if result then
      passed = passed + 1
    else
      failed = failed + 1
    end
    total_tests = total_tests + 1
  end
  
  local end_time = os.time()
  local duration = end_time - start_time
  
  print("========================================")
  print(string.format("📊 Results: %d/%d files passed", passed, total_tests))
  if failed > 0 then
    print(string.format("❌ %d files failed", failed))
  else
    print("✅ All tests passed!")
  end
  print(string.format("⏱️  Duration: %d seconds", duration))
  
  if failed > 0 then
    os.exit(1)
  else
    os.exit(0)
  end
end

-- Run the main function
main()