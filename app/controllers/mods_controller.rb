class ModsController < ApplicationController
  before_filter :require_permission, only: [:edit, :update, :destroy]
	before_action :authenticate_account!, except: [:index, :show]

	def index
    if params.has_key?(:tag)
      mods = Mod.tagged_with(params[:tag])

      @tag = params[:tag]
      @mods = mods.paginate(:page => params[:page], :per_page => 15)
    elsif params.has_key?(:search)
      @mods = Mod.search params[:search], fields: [:name], page: params[:page], per_page: 15
    else
      @mods = Mod.paginate(:page => params[:page], :per_page => 15)
    end
	end

	def show
		@mod = Mod.find(params[:id])
	end

	def new
		@mod = Mod.new
	end

	def create
		@mod = Mod.new(mod_params)
    @mod.account = current_account

		if @mod.save
			redirect_to @mod, flash: { success: 'Mod was successfully created.' }
		else
			render 'new'
		end
	end

	def edit
    @mod = Mod.find(params[:id])
	end

	def update
    @mod = Mod.find(params[:id])

    if @mod.update_attributes(mod_params)
      redirect_to @mod, flash: { success: 'Mod successfully updated.' }
    else
      flash[:danger] = 'Error updating mod!'
      render 'edit'
    end
  end

  def destroy
    @mod = Mod.find(params[:id])

    @mod.destroy

    redirect_to mods_path, flash: { success: 'Mod was successfully deleted. '}
  end

	def subscribe
    @mod = Mod.find(params[:id])

    if !current_account.subscribed_mods.include? @mod
      @mod.subscribed_accounts << current_account
      flash_message = "You have subscribed to #{@mod.name}."
    else
      @mod.subscribed_accounts.delete current_account
      current_account.subscribed_mods.delete @mod

      current_account.save

      flash_message = "You have unsubscribed from #{@mod.name}."
    end

    @mod.save

    redirect_to @mod, flash: { success: flash_message }
	end

	def download
    @mod = Mod.find(params[:id])

    redirect_to @mod.mod.url

    @mod.increment(:download_count).save
  end

  def like
    mod = Mod.find(params[:id])

    if current_account.voted_up_on? mod
      mod.unliked_by current_account
    else
      mod.liked_by current_account
    end

    redirect_to mod
  end

  def dislike
    mod = Mod.find(params[:id])

    if current_account.voted_down_on? mod
      mod.undisliked_by current_account
    else
      mod.disliked_by current_account
    end

    redirect_to mod
  end

	private
	def mod_params
		params.require(:mod).permit(:name, :description, :description_short, :version, :tag_list, :download_count, :thumbnail, :banner, :youtube_url, :mod)
  end

  def require_permission
    if current_account != Mod.find(params[:id]).account
      redirect_to current_account, flash: { danger: 'You do not own that mod!' }
    end
  end
end
