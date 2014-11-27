class Authentication < ActiveRecord::Base
  belongs_to :user

  PROVIDERS = ["google_oauth2", "twitter", "instagram", "facebook"]

  validates_presence_of :user_id, :provider, :platform_id, :username, :access_token
  validates :user_id, uniqueness: { scope: [:username, :provider] }
  validates :provider, inclusion: PROVIDERS
end
