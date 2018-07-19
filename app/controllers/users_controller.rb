class UsersController < ApplicationController
  before_action :logged_in_user, except: %i(show new create)
  before_action :correct_user, only: %i(edit update)
  before_action :admin_user, only: :destroy
  before_action :get_user, only: %i(following followers)

  def index
    @users = User.paginate(page: params[:page],
      per_page: Settings.users_per_page)
  end

  def show
    @user = User.find params[:id]
    @microposts = @user.microposts.paginate(page: params[:page],
      per_page: Settings.posts_per_page)
  rescue ActiveRecord::RecordNotFound
    flash[:warning] = t ".warning"
    redirect_to root_path
  end

  def new
    @user = User.new
  end

  def create
    @user = User.new user_params
    if @user.save
      @user.send_activation_email
      flash[:info] = t ".check_your_mail"
      redirect_to root_path
    else
      render :new
    end
  end

  def edit; end

  def update
    if @user.update_attributes(user_params)
      flash[:sucess] = t ".profile_update"
      redirect_to @user
    else
      render :edit
    end
  end

  def destroy
    @user = User.find params[:id]
    if @user.destroy
      flash[:success] = t ".deleted_user"
    else
      flash[:danger] = t ".delete_user_err"
    end
    redirect_to users_path
  rescue ActiveRecord::RecordNotFound
    flash[:warning] = t ".warning"
    redirect_to users_path
  end

  def following
    @title = t ".follow"
    @users = @user.following.paginate(page: params[:page])
    render :show_follow
  end

  def followers
    @title = t ".follower"
    @users = @user.followers.paginate(page: params[:page])
    render :show_follow
  end

  private

  def get_user
    @user  = User.find(params[:id])
    rescue ActiveRecord::RecordNotFound
    flash[:warning] = t "users.warning"
    redirect_to root_path
  end

  def user_params
    params.require(:user).permit(:name, :email, :password,
      :password_confirmation)
  end

  def correct_user
    @user = User.find_by id: params[:id]
    return if @user && current_user?(@user)
    flash[:warning] = t "users.warning"
    redirect_to users_path
  end

  def admin_user
    redirect_to(root_path) unless current_user.admin?
  end
end
