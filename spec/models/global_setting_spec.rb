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

require 'rails_helper'

RSpec.describe GlobalSetting, type: :model do
  pending "add some examples to (or delete) #{__FILE__}"
end
