class PartnersController < ApplicationController
  before_filter :authenticate_user!

  def index
    @partners = Partner.all
        render :layout => 'admin'
  end
end
