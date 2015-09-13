# == Schema Information
#
# Table name: kula_fees
#
#  id                   :integer          not null, primary key
#  partner_id           :integer
#  effective_date       :date
#  expiration_date      :date
#  created_at           :datetime
#  updated_at           :datetime
#  us_school_rate       :decimal(6, 4)
#  us_charity_rate      :decimal(6, 4)
#  intl_charity_rate    :decimal(6, 4)
#  us_school_kf_rate    :decimal(6, 4)
#  us_charity_kf_rate   :decimal(6, 4)
#  intl_charity_kf_rate :decimal(6, 4)
#

class KulaFee < ActiveRecord::Base
  belongs_to :partner
  
  validates :us_school_rate, :numericality => { :greater_than_or_equal_to => 0.0 }
  validates :us_charity_rate, :numericality => { :greater_than_or_equal_to => 0.0 }
  validates :intl_charity_rate, :numericality => { :greater_than_or_equal_to => 0.0 }
  
  validates :us_school_kf_rate, :numericality => { :greater_than_or_equal_to => 0.0 }
  validates :us_charity_kf_rate, :numericality => { :greater_than_or_equal_to => 0.0 }
  validates :intl_charity_kf_rate, :numericality => { :greater_than_or_equal_to => 0.0 }
                   
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
