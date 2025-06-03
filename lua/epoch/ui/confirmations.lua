-- epoch/ui/confirmations.lua
-- User confirmation dialog utilities
-- coverage: no tests

local confirmations = {}

-- Ask user for yes/no confirmation and execute callback
function confirmations.confirm_action(prompt, on_confirm)
  vim.ui.input({
    prompt = prompt
  }, function(input)
    -- Clear the command line
    vim.cmd("redraw!")

    -- Only proceed if the user explicitly confirms with 'y' or 'Y'
    if input and (input == "y" or input == "Y") then
      on_confirm()
    else
      vim.notify("epoch: operation cancelled", vim.log.levels.INFO)
    end
  end)
end

return confirmations