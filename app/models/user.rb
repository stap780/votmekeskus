class User < ApplicationRecord
  belongs_to :role
  # before_create :set_default_role
  # or
  before_validation :set_default_role

  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable, :recoverable, :rememberable, :validatable

  def admin?
    role.name.include?('admin')
  end

  private

  def set_default_role
    self.role_id = Role.find_by_name('registered').id if role_id.nil?
  end
end
