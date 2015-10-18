# == Schema Information
#
# Table name: delayed_rakes
#
#  id             :integer          not null, primary key
#  job_identifier :integer
#  name           :string(16)
#  params         :text
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#

require 'rails_helper'

RSpec.describe DelayedRake, type: :model do
  pending "add some examples to (or delete) #{__FILE__}"
end
