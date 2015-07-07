# == Schema Information
#
# Table name: batches
#
#  id          :integer          not null, primary key
#  partner_id  :integer
#  user_id     :integer
#  name        :string(32)
#  date        :datetime
#  description :string(255)
#  created_at  :datetime
#  updated_at  :datetime
#

describe Batch do
  let(:partner) { FactoryGirl.create(:partner) }
  let(:user) { FactoryGirl.create(:user) }
  let(:batch) { FactoryGirl.create(:batch, :partner => partner, :user => user) }
  
  subject { batch }
  
  it "should respond to everything" do
    expect(batch).to respond_to(:partner_id)
    expect(batch).to respond_to(:user_id)
    expect(batch).to respond_to(:name)
    expect(batch).to respond_to(:date)
    expect(batch).to respond_to(:description)
  end
  
  its(:partner) { should be == partner }
  its(:user) { should be == user }
  
  it { should be_valid }
  
  describe "Payments" do
    let(:batch) { FactoryGirl.create(:batch_with_payments, :partner => partner, :user => user) }
    
    it "should have payments" do
      expect(batch.payments.count).to eq(10)
    end
    
    it "Should not allow deletion" do
      expect { batch.destroy }.to raise_exception(ActiveRecord::DeleteRestrictionError)
    end
    
    describe "Delete payments" do
      before do
        batch
        Payment.destroy_all
      end
      
      it "should not have any payments" do
        expect(Payment.count).to eq(0)
        expect(Batch.count).to eq(1)
        expect(batch.payments.count).to eq(0)
      end
      
      describe "Delete now" do
        before { batch.destroy }
        
        it "should work" do
          expect(Batch.count).to eq(0)
        end
      end
    end
  end

  describe "Adjustments" do
    let(:batch) { FactoryGirl.create(:batch_with_adjustments, :partner => partner, :user => user) }
    
    it "should have adjustments" do
      expect(batch.adjustments.count).to eq(2)
    end
    
    it "Should not allow deletion" do
      expect { batch.destroy }.to raise_exception(ActiveRecord::DeleteRestrictionError)
    end
    
    describe "Delete adjustments" do
      before do
        batch
        Adjustment.destroy_all
      end
      
      it "should not have any payments" do
        expect(Adjustment.count).to eq(0)
        expect(Batch.count).to eq(1)
        expect(batch.payments.count).to eq(0)
      end
      
      describe "Delete now" do
        before { batch.destroy }
        
        it "should work" do
          expect(Batch.count).to eq(0)
        end
      end
    end
  end

  describe "Payments and Adjustments" do
    let(:batch) { FactoryGirl.create(:batch_with_adjusted_payments, :partner => partner, :user => user) }
    
    it "should have payments and adjustments" do
      expect(batch.payments.count).to eq(10)
      expect(batch.adjustments.count).to eq(2)
    end
    
    it "Should not allow deletion" do
      expect { batch.destroy }.to raise_exception(ActiveRecord::DeleteRestrictionError)
    end
    
    describe "Delete payments" do
      before do
        batch
        Payment.destroy_all
      end
      
      it "should not have any payments" do
        expect(Payment.count).to eq(0)
        expect(Adjustment.count).to eq(2)
        expect(Batch.count).to eq(1)
        expect(batch.payments.count).to eq(0)
      end
      
      it "Should still not allow deletion" do
        expect { batch.destroy }.to raise_exception(ActiveRecord::DeleteRestrictionError)
      end
      
      describe "Delete now" do
        before do
          Adjustment.destroy_all 
          batch.destroy
        end
        
        it "should work" do
          expect(Batch.count).to eq(0)
        end
      end
    end
  end
end
