require "open-uri"

class UploadInstagramPhotosToGoogleDrive
  include Sidekiq::Worker

  def perform
    Recipe.includes(:m_recipe, :user).each do |recipe|
      next if recipe.m_recipe.name != "upload_instagram_photos_to_google_drive"
      begin
        instagram = recipe.user.instagram_client
        google    = recipe.user.google_client

        photos = []
        instagram.user_recent_media.each do |media|
          next unless media.type == "image" && Time.at(media.created_time.to_i) > recipe.last_executed_at
          photos << {
            url: media.images.standard_resolution.url,
            caption: media.caption.try(:text).to_s,
            created_time: Time.at(media.created_time.to_i).strftime("%Y%m%d%H%M%S")
          }
        end
        recipe.update_attributes last_executed_at: Time.current
        photos.reverse.each do |photo|
          begin
            GoogleDrive.upload_photo google, open(photo[:url]), photo[:created_time], photo[:caption],
              Settings.googledrive.folder.instagram
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
  name: 'UploadInstagramPhotosToGoogleDrive - every 5 minute',
  cron: (0..59).select{|i| i % 5 == 1}.join(",") + ' * * * *',
  klass: 'UploadInstagramPhotosToGoogleDrive'
)