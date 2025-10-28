class RegistrationsController < ApplicationController
  skip_before_action :require_login, only: [ :new, :create ]

  def new
    @user = User.new
    render Registrations::NewView.new(user: @user)
  end

  def create
    @user = User.new(user_params)

    if @user.save
      session[:user_id] = @user.id
      redirect_to components_path, notice: "Регистрация прошла успешно! Добро пожаловать, #{@user.name}!"
    else
      render Registrations::NewView.new(user: @user), status: :unprocessable_entity
    end
  end

  private

  def user_params
    params.require(:user).permit(:name, :email, :password, :password_confirmation)
  end
end
