Sidekiq::Web.use(Rack::Auth::Basic) do |user, password|
  [user, password] == ["admin", "abc123"]
end