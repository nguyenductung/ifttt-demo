Rails.application.config.middleware.use OmniAuth::Builder do
  provider :google_oauth2, ENV["GOOGLE_CLIENT_ID"], ENV["GOOGLE_CLIENT_SECRET"],
  {
    scope: ["userinfo.email", "userinfo.profile", "drive"],
    access_type: "offline"
  }
  provider :twitter, ENV["TWITTER_CONSUMER_KEY"], ENV["TWITTER_CONSUMER_SECRET"]
  provider :instagram, ENV["INSTAGRAM_CLIENT_ID"], ENV["INSTAGRAM_CLIENT_SECRET"]
  provider :dropbox_oauth2, ENV["DROPBOX_KEY"], ENV["DROPBOX_SECRET"]
end
