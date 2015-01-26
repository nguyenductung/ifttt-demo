require "open-uri"

class UploadTwitterPhotosToDropbox
  include Sidekiq::Worker

  def perform
    Recipe.includes(:m_recipe, :user).each do |recipe|
      next if recipe.m_recipe.name != "upload_twitter_photos_to_dropbox"
      begin
        twitter = recipe.user.twitter_client
        dropbox = recipe.user.dropbox_client

        photos = []
        tweets = twitter.user_timeline
        tweets.each do |tweet|
          next unless tweet.media.present? && tweet.created_at > recipe.last_executed_at
          tweet.media.each do |photo|
            url = photo.media_url
            ext = "." + url.to_s.split(".").last
            location = Settings.dropbox.folder.twitter + '/' +
              tweet.created_at.strftime("%Y%m%d%H%M%S") + ext
            photos << { url: url, location: location }
          end
        end
        recipe.update_attributes last_executed_at: Time.current
        photos.reverse.each do |photo|
          begin
            dropbox.put_file(photo[:location], open(photo[:url]))
          rescue => e
            Rails.logger.error e.inspect
          end
        end
      rescue => e
        Rails.logger.error e.inspect
      end
    end
  end
end

Sidekiq::Cron::Job.create(
  name: 'UploadTwitterPhotosToDropbox - every 5 minute',
  cron: (0..59).select{|i| i % 5 == 4}.join(",") + ' * * * *',
  klass: 'UploadTwitterPhotosToDropbox'
)
