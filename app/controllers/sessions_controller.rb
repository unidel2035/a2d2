class SessionsController < ApplicationController
  skip_before_action :require_login, only: [ :new, :create ]

  def new
    render Sessions::NewView.new(flash: flash)
  end

  def create
    user = User.find_by(email: params[:email])

    if user&.authenticate(params[:password])
      session[:user_id] = user.id
      redirect_to components_path, notice: "Добро пожаловать, #{user.name}!"
    else
      flash.now[:alert] = "Неверный email или пароль"
      render Sessions::NewView.new(flash: flash), status: :unprocessable_entity
    end
  end

  def destroy
    session[:user_id] = nil
    redirect_to root_path, notice: "Вы вышли из системы"
  end
end
