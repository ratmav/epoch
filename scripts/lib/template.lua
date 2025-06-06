local template = {}

local Lust = require('Lust')

function template.render(template_file, data)
    local file_handle = io.open('scripts/templates/' .. template_file, 'r')
    local template_content = file_handle:read('*all')
    file_handle:close()

    local lust_template = Lust(template_content)
    return lust_template:gen(data)
end

return template
