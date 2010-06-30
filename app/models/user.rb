class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :token_authenticatable, :lockable and :timeoutable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable

  # Setup accessible (or protected) attributes for your model
  attr_accessible :email, :username, :display_name, :password, :password_confirmation
  
  validates :username, :presence => true, :uniqueness => true
  
  def to_param
    username
  end
  
end
