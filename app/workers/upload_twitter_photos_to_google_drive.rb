require "open-uri"

class UploadTwitterPhotosToGoogleDrive
  include Sidekiq::Worker

  def perform
    Recipe.includes(:m_recipe, :user).each do |recipe|
      next if recipe.m_recipe.name != "upload_twitter_photos_to_google_drive"
      begin
        twitter = recipe.user.twitter_client
        google  = recipe.user.google_client

        photos = []
        tweets = twitter.user_timeline
        tweets.each do |tweet|
          next unless tweet.media.present? && tweet.created_at > recipe.last_executed_at
          tweet.media.each do |photo|
            photos << {
              url: photo.media_url,
              caption: tweet.full_text,
              created_time: tweet.created_at.strftime("%Y%m%d%H%M%S")
            }
          end
        end
        recipe.update_attributes last_executed_at: Time.current
        photos.reverse.each do |photo|
          begin
            GoogleDrive.upload_photo google, open(photo[:url]), photo[:created_time], photo[:caption],
              Settings.googledrive.folder.twitter
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
  name: 'UploadTwitterPhotosToGoogleDrive - every 5 minute',
  cron: (0..59).select{|i| i % 5 == 2}.join(",") + ' * * * *',
  klass: 'UploadTwitterPhotosToGoogleDrive'
)