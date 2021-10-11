class User < ApplicationRecord

    belongs_to :role
    before_create :set_default_role
    # or
    # before_validation :set_default_role

  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable


  private

  def set_default_role
    puts 'here'
    self.role ||= Role.find_by_name('registered')
  end
end
