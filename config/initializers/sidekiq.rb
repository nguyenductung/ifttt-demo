require 'sidekiq'

Sidekiq::Web.use(Rack::Auth::Basic) do |user, password|
  [user, password] == [ENV["SIDEKIQ_USERNAME"], ENV["SIDEKIQ_PASSWORD"]]
end

Sidekiq.configure_client do |config|
  config.redis = { :size => 1 }
end

Sidekiq.configure_server do |config|
  config.redis = { :size => 2 }
end
