class ApiTokensController < ApplicationController
  def index
    render ApiTokens::IndexView.new(
      current_user: current_user
    )
  end

  def create
    # Logic to create API token would go here
    redirect_to api_tokens_path, notice: "API токен успешно создан"
  end

  def destroy
    # Logic to delete API token would go here
    redirect_to api_tokens_path, notice: "API токен удален"
  end
end
