class PartnersController < ApplicationController
  before_filter :authenticate_user!

  def index
    @partners = Partner.all
    
    render :layout => 'admin'
  end
  
  def edit
    @partner = Partner.find_by_partner_identifier(params[:id])
    
    render :layout => 'admin'
  end
  
  def update
    @partner = Partner.find_by_partner_identifier(params[:id])
    if @partner.update_attributes(partner_params)      
      redirect_to partners_path, notice: 'Partner was successfully updated.'
    else
      render 'edit'
    end
  end

private
  def partner_params
    params.require(:partner).permit(:partner_identifier, :display_name, :domain, :currency, 
                                    :kula_fees_attributes => [:id, :kula_rate, :discount_rate, :effective_date, :expiration_date,
                                                              :_destroy])    
  end
end
