class User < ActiveRecord::Base
  has_many :authentications

  class << self
    def find_or_create_with_omniauth omniauth, current_user = nil
      return nil unless Authentication::PROVIDERS.include? omniauth.provider
      transaction do
        if current_user
          if authentication = current_user.authentications.find_by(params_to_find(omniauth))
            authentication.update_attributes! authentication_params(omniauth)
          else
            current_user.authentications.create! authentication_params(omniauth)
          end
          user = current_user.update_attributes! user_params(omniauth)
        else
          if authentication = Authentication.find_by(params_to_find(omniauth))
            user = authentication.user
          else
            user = User.create! user_params(omniauth)
            user.authentications.create! authentication_params(omniauth)
          end
        end
        user
      end
    # rescue
    end

    private

    def params_to_find omniauth
      case omniauth.provider
      when "google_oauth2"
        {
          provider: omniauth.provider,
          username: omniauth.uid
        }
      when "twitter"
        {
          provider: omniauth.provider,
          username: omniauth.info.nickname
        }
      when "instagram"
        {
          provider: omniauth.provider,
          username: omniauth.info.nickname
        }
      end
    end

    def user_params omniauth
      case omniauth.provider
      when "google_oauth2"
        {
          name: omniauth.info.name,
          photo: omniauth.info.image,
          mail: omniauth.info.email
        }
      when "twitter"
        {
          name: omniauth.info.name,
          photo: omniauth.info.image
        }
      when "instagram"
        {
          name: omniauth.info.name,
          photo: omniauth.info.image
        }
      end
    end

    def authentication_params omniauth
      case omniauth.provider
      when "google_oauth2"
        {
          provider: omniauth.provider,
          platform_id: omniauth.uid,
          username: omniauth.uid,
          access_token: omniauth.credentials.token,
          expires_at: Time.at(omniauth.credentials.expires_at.to_i)
        }
      when "twitter"
        {
          provider: omniauth.provider,
          platform_id: omniauth.uid,
          username: omniauth.info.nickname,
          access_token: omniauth.credentials.token,
          secret_token: omniauth.credentials.secret
        }
      when "instagram"
        {
          provider: omniauth.provider,
          platform_id: omniauth.uid,
          username: omniauth.info.nickname,
          access_token: omniauth.credentials.token
        }
      end
    end
  end

  def google_client
    access_token = authentications.find_by(provider: "google_oauth2").try(:access_token)
    return nil unless access_token

    @google_client ||= Google::APIClient.new
    @google_client.authorization.access_token = access_token
    @google_client
  end

  def twitter_client
    access_token = authentications.find_by(provider: "twitter").try(:access_token)
    secret_token = authentications.find_by(provider: "google_oauth2").try(:secret_token)
    return nil unless access_token && secret_token

    @twitter_client ||= Twitter::REST::Client.new do |config|
      config.consumer_key = Settings.twitter.consumer_key
      config.consumer_secret = Settings.twitter.consumer_secret
    end
    @twitter_client.access_token = access_token
    @twitter_client.access_token_secret = secret_token
    @twitter_client
  end

  def instagram_client
    access_token = authentications.find_by(provider: "instagram").try(:access_token)
    return nil unless access_token

    @instagram_client ||= Instagram.client
    @instagram_client.access_token = access_token
    @instagram_client
  end
end