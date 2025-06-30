-- tests/commands/validation_spec.lua

local validation = require('epoch.commands.validation')

describe('commands validation', function()
  describe('parse_date_components', function()
    it('should parse valid date strings', function()
      local year, month, day = validation.parse_date_components('2025-01-15')
      assert.equals(2025, year)
      assert.equals(1, month)
      assert.equals(15, day)
    end)

    it('should return nil for invalid format', function()
      assert.is_nil(validation.parse_date_components('2025-1-15'))
      assert.is_nil(validation.parse_date_components('invalid'))
      assert.is_nil(validation.parse_date_components(''))
    end)
  end)

  describe('is_valid_date', function()
    it('should accept valid calendar dates', function()
      assert.is_true(validation.is_valid_date(2025, 2, 28))
      assert.is_true(validation.is_valid_date(2024, 2, 29))
      assert.is_true(validation.is_valid_date(2025, 1, 1))
      assert.is_true(validation.is_valid_date(2025, 12, 31))
    end)

    it('should reject invalid calendar dates', function()
      assert.is_false(validation.is_valid_date(2025, 2, 30))
      assert.is_false(validation.is_valid_date(2023, 2, 29))
      assert.is_false(validation.is_valid_date(2025, 4, 31))
      assert.is_false(validation.is_valid_date(2025, 13, 1))
      assert.is_false(validation.is_valid_date(2025, 0, 1))
    end)
  end)

  describe('validate_date_format', function()
    it('should reject malformed date formats like 2025-6-16', function()
      assert.is_false(validation.validate_date_format('2025-6-16'))
    end)

    it('should reject other malformed date formats', function()
      local malformed_dates = {'2025-1-1', '25-01-01', '2025/01/01', '2025-13-01', 'invalid', ''}
      for _, bad_date in ipairs(malformed_dates) do
        assert.is_false(validation.validate_date_format(bad_date), "Should reject: " .. bad_date)
      end
    end)

    it('should reject non-string inputs', function()
      assert.is_false(validation.validate_date_format(nil))
      assert.is_false(validation.validate_date_format(123))
      assert.is_false(validation.validate_date_format({}))
      assert.is_false(validation.validate_date_format(true))
    end)

    it('should accept properly formatted dates', function()
      local valid_dates = {'2025-01-01', '2024-12-31', '2025-06-16', '1999-01-01', '2050-12-25'}
      for _, valid_date in ipairs(valid_dates) do
        assert.is_true(validation.validate_date_format(valid_date), "Should accept: " .. valid_date)
      end
    end)

    it('should enforce exact format requirements', function()
      assert.is_false(validation.validate_date_format('2025-1-01'))
      assert.is_false(validation.validate_date_format('2025-01-1'))
      assert.is_false(validation.validate_date_format('25-01-01'))
      assert.is_false(validation.validate_date_format('12025-01-01'))
      assert.is_false(validation.validate_date_format('2025-001-01'))
      assert.is_false(validation.validate_date_format('2025-01-001'))
    end)

    it('should reject invalid calendar dates', function()
      assert.is_false(validation.validate_date_format('2025-13-01'))
      assert.is_false(validation.validate_date_format('2025-00-01'))
      assert.is_false(validation.validate_date_format('2025-01-32'))
      assert.is_false(validation.validate_date_format('2025-02-30'))
    end)
  end)
end)