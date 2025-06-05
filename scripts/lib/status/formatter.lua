local formatter = {}

function formatter.determine_status(success, has_warnings)
    if success and not has_warnings then
        return "✅ PASS"
    elseif success and has_warnings then
        return "⚠️ PASS"
    else
        return "❌ FAIL"
    end
end

function formatter.exit_with_status(success)
    os.exit(success and 0 or 1)
end

return formatter