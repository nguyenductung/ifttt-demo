Rails.application.config.middleware.use OmniAuth::Builder do
  provider :google_oauth2, Settings.google.client_id, Settings.google.client_secret,
  {
    scope: ["userinfo.email", "userinfo.profile", "drive"],
    access_type: "offline"
  }
  provider :facebook, Settings.facebook.app_id, Settings.facebook.app_secret,
  {
    scope: "user_about_me,user_status,user_friends,user_photos,email,publish_actions"
  }
  provider :twitter, Settings.twitter.consumer_key, Settings.twitter.consumer_secret
end
