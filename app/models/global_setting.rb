# == Schema Information
#
# Table name: global_settings
#
#  id             :integer          not null, primary key
#  current_period :date             not null
#  other          :text
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#

# CHARTER
#   Repository for global system state, such as the current period month/year
#
# USAGE
#  
# NOTES AND WARNINGS
#   The other field holds a serialized hash of options, and is there for expandability
#
class GlobalSetting < ActiveRecord::Base
  validates_presence_of :current_period
  
  def self.set_params(params)
    raise 'No global settings' if 0 == GlobalSetting.count
    
    GlobalSetting.first.update_attribute(:other, params.nil? ? nil : YAML::dump(params))
  end
  
  def self.get_params
    raise 'No global settings' if 0 == GlobalSetting.count
    
    settings = GlobalSetting.first
    
    settings.other.nil? ? nil : YAML::load(settings.other)
  end
end
