class User < ActiveRecord::Base
  # Creates attribute accessors corresponding to a password.
  # Creates 'getter' and 'setter' methods that allow us to 
  # retrieve (get) and assign (set) @password instance variables.
  attr_accessor :password
  # Tells which attributes of the model are accessible, 
  # i.e., which attributes can be modified by outside users.
  attr_accessible :name, :email, :password, :password_confirmation

  email_regex = /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i

  validates :name, :presence => true,
    :length => { :maximum => 50 }
  validates :email, :presence => true,
    :format   => { :with => email_regex },
    :uniqueness   => { :case_sensitive => false }
  # Automatically create the virtual attribute 'password_confirmation'.
  validates :password, :presence  => true,
    :confirmation   => true,
    :length         => { :within => 6..40 }

  before_save :encrypt_password

  # Return true if the user's password matches the submitted password.
  def has_password? (submitted_password)
    encrypted_password == encrypt(submitted_password)
  end

  def self.authenticate(email, submitted_password)
    user = find_by_email(email)
    return nil  if user.nil?
    return user if user.has_password?(submitted_password)
  end

  def self.authenticate_with_salt(id, cookie_salt)
    user = find_by_id(id)
    (user && user.salt == cookie_salt) ? user : nil
  end


  def self.authenticate_with_salt(id, cookie_salt)
    user = find_by_id(id)
    (user && user.salt == cookie_salt) ? user : nil
  end  

  private
    
    def encrypt_password
      # self is not optional when assigning to an attribute
      self.salt = make_salt unless has_password?(password)
      self.encrypted_password = encrypt(password)
    end

    def encrypt(string)
      secure_hash("#{salt}--#{string}")
    end

    def make_salt
      secure_hash("#{Time.now.utc}--#{password}")
    end

    def secure_hash(string)
      Digest::SHA2.hexdigest(string)
    end
end
