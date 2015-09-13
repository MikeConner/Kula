# == Schema Information
#
# Table name: partners
#
#  partner_identifier :integer          not null, primary key
#  name               :string(64)       not null
#  display_name       :string(64)       not null
#  domain             :string(64)       not null
#  currency           :string(3)        default("USD"), not null
#  created_at         :datetime
#  updated_at         :datetime
#

class Partner < ActiveRecord::Base
  MAX_NAME_LEN = 64
  MAX_CURRENCY_LEN = 3
  
  self.primary_key = 'partner_identifier'
  
  has_one :distributor, :dependent => :nullify
  has_many :kula_fees, :dependent => :destroy
  has_many :cause_balances, :dependent => :restrict_with_exception
  has_many :batches, :dependent => :restrict_with_exception
  has_many :payments, :through => :batches
  
  accepts_nested_attributes_for :kula_fees, :allow_destroy => true, :reject_if => :all_blank
  
  validates_presence_of :name, :display_name, :domain, :partner_identifier
  validates_uniqueness_of :partner_identifier
  validates_length_of :name, :display_name, :domain, :maximum => MAX_NAME_LEN
  validates_length_of :currency, :maximum => MAX_CURRENCY_LEN 
  
  validate :non_conflicting_rates
                   
  def current_kula_rate(date = nil)
    test_date = date || Date.today
    
    self.kula_fees.each do |fee|
      return fee.kula_rate if fee.valid_on?(test_date)
    end
    
    return nil
  end

  def current_discount_rate(date = nil)
    test_date = date || Date.today
    
    self.kula_fees.each do |fee|
      return fee.discount_rate if fee.valid_on?(test_date)
    end
    
    return nil
  end
  
private
  def non_conflicting_rates
    fees = self.kula_fees
 
    unless fees.count < 2
      for x in 0..(fees.count - 2) do
        for y in (x + 1)..(fees.count - 1) do
          if dates_overlap?(fees[x], fees[y])
            self.errors.add :base, "Dates cannot overlap"
          end
        end
      end
    end
  end
  
  def dates_overlap?(a, b)
    # If there is any universal rate (no dates at all), there can't be more than one
    return true if a.universal? or b.universal?
    
    # At this point, we know none are universal, so at most one of the ends is unbounded
    if a.unbounded_left? 
      b.unbounded_left? ? true : b.effective_date <= a.expiration_date
    elsif a.unbounded_right?
      b.unbounded_right? ? true : a.effective_date <= b.expiration_date
    else
      if b.unbounded_left?
        a.effective_date <= b.expiration_date
      elsif b.unbounded_right?
        a.expiration_date >= b.effective_date
      else
        ((a.effective_date >= b.effective_date) and (a.effective_date <= b.expiration_date)) or
        ((b.effective_date >= a.effective_date) and (b.effective_date <= a.expiration_date))
      end
    end
  end  
end
