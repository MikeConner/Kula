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

describe GlobalSetting do
  let(:settings) { FactoryGirl.create(:global_setting) }
  
  subject { settings }
  
  it "should respond to everything" do
    expect(settings).to respond_to(:current_period)
    expect(settings).to respond_to(:other)
  end
  
  it { should be_valid }
  
  it "should have no params" do
    expect(settings.other).to be_nil
    expect(GlobalSetting.get_params).to be_nil 
  end
  
  describe "Params" do
    let(:params) {{:a => 1, :b => 'abc'}}
    
    before do
      settings
      
      GlobalSetting.set_params(params)
    end
    
    it "should recover them" do
      expect(GlobalSetting.get_params).to be == params
    end
  end
end
