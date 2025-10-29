# frozen_string_literal: true

# Password complexity validator
# AUTH-001: Password policies - minimum 8 characters with complexity requirements
# Ensures passwords contain:
# - At least 8 characters (enforced by Devise)
# - At least one uppercase letter
# - At least one lowercase letter
# - At least one digit
# - At least one special character
class PasswordComplexityValidator < ActiveModel::EachValidator
  COMPLEXITY_REGEX = /\A(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[@$!%*?&])[A-Za-z\d@$!%*?&]/

  def validate_each(record, attribute, value)
    return if value.blank?

    unless value.match?(COMPLEXITY_REGEX)
      record.errors.add(
        attribute,
        options[:message] || :password_complexity,
        message: "должен содержать как минимум одну заглавную букву, одну строчную букву, одну цифру и один специальный символ (@$!%*?&)"
      )
    end
  end
end
