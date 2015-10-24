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
end
