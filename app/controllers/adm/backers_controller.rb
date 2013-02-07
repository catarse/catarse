class Adm::BackersController < Adm::BaseController
  inherit_resources
  menu I18n.t("adm.backers.index.menu") => Rails.application.routes.url_helpers.adm_backers_path
  before_filter :set_title

  def confirm
    resource.confirm!
    flash[:notice] = I18n.t('adm.backers.messages.successful.confirm')
    redirect_to adm_backers_path
  end

  def update
    @backer = Backer.find params[:id]

    respond_to do |format|
      if @backer.update_attributes(params[:backer])
        format.html { redirect_to(adm_backers_path) }
        format.json { respond_with_bip(@backer) }
      else
        format.html { render :action => "edit" }
        format.json { respond_with_bip(@user) }
      end
    end
  end

  def unconfirm
    resource.unconfirm!
    flash[:notice] = I18n.t('adm.backers.messages.successful.unconfirm')
    redirect_to adm_backers_path
  end

  protected
  def set_title
    @title = t("adm.backers.index.title")
  end

  def collection
    @search = Backer.search(params[:search])
    @backers = @search.order("created_at DESC").page(params[:page])
  end
end
