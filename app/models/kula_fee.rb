# == Schema Information
#
# Table name: kula_fees
#
#  id                     :integer          not null, primary key
#  partner_identifier     :integer
#  effective_date         :date
#  expiration_date        :date
#  created_at             :datetime
#  updated_at             :datetime
#  us_school_rate         :decimal(6, 4)
#  us_charity_rate        :decimal(6, 4)
#  intl_charity_rate      :decimal(6, 4)
#  us_school_kf_rate      :decimal(6, 4)
#  us_charity_kf_rate     :decimal(6, 4)
#  intl_charity_kf_rate   :decimal(6, 4)
#  distributor_rate       :decimal(6, 4)
#  distributor_identifier :integer
#

# CHARTER
#   Store partner fees, and the relationships between partners, distributors, and causes
#
# USAGE
#
# NOTES AND WARNINGS
#   Partners have defined fees for different categories of causes. The total fee is the sum of the "rate" and "kf_rate" (Kula Foundation)
# If a partner has a distributor, use it to select the distributor fees. All of them might change based on distributor (both the new
# distributor_(kf_)rate), and the original fees as well
#
class KulaFee < ActiveRecord::Base
  belongs_to :partner, :foreign_key => 'partner_identifier'
  belongs_to :distributor, :foreign_key => 'distributor_identifier'
  
  validates :us_school_rate, :numericality => { :greater_than_or_equal_to => 0.0 }, :allow_nil => true  
  validates :us_charity_rate, :numericality => { :greater_than_or_equal_to => 0.0 }, :allow_nil => true  
  validates :intl_charity_rate, :numericality => { :greater_than_or_equal_to => 0.0 }, :allow_nil => true  
  
  validates :us_school_kf_rate, :numericality => { :greater_than_or_equal_to => 0.0 }, :allow_nil => true  
  validates :us_charity_kf_rate, :numericality => { :greater_than_or_equal_to => 0.0 }, :allow_nil => true  
  validates :intl_charity_kf_rate, :numericality => { :greater_than_or_equal_to => 0.0 }, :allow_nil => true  

  validates :distributor_rate, :numericality => { :greater_than_or_equal_to => 0.0 }, :allow_nil => true  
                   
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
  
  def date_display
    if universal?
      "All time"
    elsif unbounded_left?
      "Until #{self.expiration_date.try(:strftime, ApplicationHelper::DATE_FORMAT)}"
    elsif unbounded_right?
      "After #{self.effective_date.try(:strftime, ApplicationHelper::DATE_FORMAT)}"
    else
      "Between #{self.effective_date.try(:strftime, ApplicationHelper::DATE_FORMAT)} and #{self.expiration_date.try(:strftime, ApplicationHelper::DATE_FORMAT)}"
    end
  end
end
