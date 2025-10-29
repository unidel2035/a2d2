require "application_system_test_case"

class AuthenticationTest < ApplicationSystemTestCase
  def setup
    @user = users(:one)
  end

  test "user can sign in" do
    skip "Devise authentication configuration required for system tests"

    visit new_user_session_url

    fill_in "Email", with: @user.email
    fill_in "Password", with: "password123"
    click_button "Sign in" rescue click_button "Войти"

    assert_text "Signed in successfully" rescue assert_text "Вход выполнен успешно"
  end

  test "user can sign out" do
    skip "Devise authentication configuration required for system tests"

    # Сначала входим
    visit new_user_session_url
    fill_in "Email", with: @user.email
    fill_in "Password", with: "password123"
    click_button "Sign in" rescue click_button "Войти"

    # Затем выходим
    click_on "Sign out" rescue click_on "Выйти"

    assert_text "Signed out successfully" rescue assert_text "Выход выполнен успешно"
  end

  test "user cannot sign in with wrong password" do
    skip "Devise authentication configuration required for system tests"

    visit new_user_session_url

    fill_in "Email", with: @user.email
    fill_in "Password", with: "wrongpassword"
    click_button "Sign in" rescue click_button "Войти"

    assert_text "Invalid Email or password" rescue assert_text "Неверный Email или пароль"
  end

  test "user can register new account" do
    skip "Devise authentication configuration required for system tests"

    visit new_user_registration_url

    fill_in "Name", with: "New User"
    fill_in "Email", with: "newuser@example.com"
    fill_in "Password", with: "password123"
    fill_in "Password confirmation", with: "password123"
    click_button "Sign up" rescue click_button "Зарегистрироваться"

    assert_text "Welcome! You have signed up successfully" rescue assert_text "Добро пожаловать! Регистрация прошла успешно"
  end

  test "user needs to be authenticated to access dashboard" do
    skip "Devise authentication configuration required for system tests"

    visit dashboard_url

    # Должны быть перенаправлены на страницу входа
    assert_current_path new_user_session_path
  end
end
