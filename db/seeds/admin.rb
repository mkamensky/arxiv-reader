User.create!(
  email: Rails.application.credentials.dig(:admin, :username),
  password: Rails.application.credentials.dig(:admin, :password),
)
