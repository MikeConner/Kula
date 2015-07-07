# == Schema Information
#
# Table name: users
#
#  id                     :integer          not null, primary key
#  email                  :string(255)      default(""), not null
#  encrypted_password     :string(255)      default(""), not null
#  reset_password_token   :string(255)
#  reset_password_sent_at :datetime
#  remember_created_at    :datetime
#  sign_in_count          :integer          default(0), not null
#  current_sign_in_at     :datetime
#  last_sign_in_at        :datetime
#  current_sign_in_ip     :string(255)
#  last_sign_in_ip        :string(255)
#  created_at             :datetime
#  updated_at             :datetime
#  role                   :string(16)
#  partner_id             :integer
#  cause_id               :integer
#

class User < ActiveRecord::Base
  MAX_ROLE_LEN = 16
  ADMIN = 'Admin'          # Us
  KULA_ADMIN = 'KulaAdmin' # Kula administrators
  PARTNER = 'Partner'      # User associated with a particular Partner (e.g., Coke, Red Robin)
  CAUSE = 'Cause'          # User associated with a particular Cause (e.g., Sewickley Academy)
  # Users with nil role fields are end users (contributors/users)
  VALID_ROLES = [ADMIN, KULA_ADMIN, PARTNER, CAUSE]
  
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable
         
  # Partner and Cause users are associated with that particular partner/cause
  # Need lots of validation here       
  belongs_to :partner
  belongs_to :cause
  
  validates_presence_of :partner_id, :if => :partner?
  validates_presence_of :cause_id, :if => :cause?
  validates_inclusion_of :role, :in => VALID_ROLES, :allow_nil => true
  
  validate :consistent_roles
  
  scope :partners, -> { where("role = ?", PARTNER) }
  scope :causes, -> { where("role = ?", CAUSE) }
  
  def partner?
    PARTNER == self.role
  end
  
  def cause?
    CAUSE == self.role
  end

private
  def consistent_roles
    if (!partner_id.nil? and !partner?) or (!cause_id.nil? and !cause?)
      self.errors.add :base, 'Inconsistent roles'
    end
  end
end
