# == Schema Information
#
# Table name: kula_fees
#
#  id              :integer          not null, primary key
#  partner_id      :integer
#  rate            :decimal(6, 3)    not null
#  effective_date  :date
#  expiration_date :date
#  created_at      :datetime
#  updated_at      :datetime
#

class KulaFee < ActiveRecord::Base
  belongs_to :partner
  
  validates :rate, :presence => true,
                   :numericality => { :greater_than => 0.0 }
                   
  def universal?
    self.effective_date.nil? and self.expiration_date.nil?
  end
  
  def unbounded_left?
    self.effective_date.nil?
  end
  
  def unbounded_right?
    self.expiration_date.nil?
  end
  
  def valid_on?(date)
    if universal?
      true
    elsif unbounded_left?
      date <= self.expiration_date
    elsif unbounded_right?
      date >= self.effective_date
    else
      (date >= self.effective_date) and (date <= self.expiration_date)
    end
  end
end
