require "open-uri"

class UploadInstagramPhotosToDropbox
  include Sidekiq::Worker

  def perform
    Recipe.includes(:m_recipe, :user).each do |recipe|
      next if recipe.m_recipe.name != "upload_instagram_photos_to_dropbox"
      begin
        instagram = recipe.user.instagram_client
        dropbox   = recipe.user.dropbox_client

        photos = []
        instagram.user_recent_media.each do |media|
          next unless media.type == "image" && Time.at(media.created_time.to_i) > recipe.last_executed_at
          url = media.images.standard_resolution.url
          ext = "." + url.to_s.split(".").last
          location = Settings.dropbox.folder.instagram + '/' +
            Time.at(media.created_time.to_i).strftime("%Y%m%d%H%M%S") + ext
          photos << { url: url, location: location }
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
  name: 'UploadInstagramPhotosToDropbox - every 5 minute',
  cron: (0..59).select{|i| i % 5 == 3}.join(",") + ' * * * *',
  klass: 'UploadInstagramPhotosToDropbox'
)
