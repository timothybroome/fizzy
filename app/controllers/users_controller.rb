class UsersController < ApplicationController
  require_unauthenticated_access only: %i[ new create ]

  before_action :set_user, only: :show
  before_action :set_account_from_join_code, only: %i[ new create ]

  def new
    @user = @account.users.build
  end

  def create
    user = @account.users.create!(user_params)
    start_new_session_for user
    redirect_to root_path
  end

  def show
  end

  private
    def set_account_from_join_code
      @account = Account.find_by_join_code!(params[:join_code])
    end

    def set_user
      @user = Current.account.users.active.find(params[:id])
    end

    def user_params
      params.expect(user: [ :name, :email_address, :password ])
    end
end
