# frozen_string_literal: true

module HashSchemaAssertions
  def assert_hash_schema!(spec, hash)
    keys_diff = spec.keys - hash.keys

    assert_equal([], keys_diff, "expected to not have these: #{keys_diff}")

    spec.each do |key, expected|
      value = hash[key]
      error_message = "The key #{key.inspect} has an invalid value"

      case expected
      when Proc then assert(expected.call(value), error_message)
      when Module then assert_kind_of(expected, value, error_message)
      when Regexp then assert_match(expected, value, error_message)
      when NilClass then assert_nil(value, error_message)
      else assert_equal(expected, value, error_message)
      end
    end
  end

  def assert_hash_schema(spec, hash)
    keys_diff = hash.keys - spec.keys

    assert_equal([], keys_diff, "expected to have these keys: #{keys_diff}")

    assert_hash_schema!(spec, hash)
  end
end
