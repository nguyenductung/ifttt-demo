require "open-uri"

class PostInstagramPhotosToTwitter
  include Sidekiq::Worker

  def perform
    Recipe.includes(:m_recipe, :user).each do |recipe|
      next if recipe.m_recipe.name != "post_instagram_photos_to_twitter"
      begin
        instagram = recipe.user.instagram_client
        twitter   = recipe.user.twitter_client
        photos = []
        instagram.user_recent_media.each do |media|
          next unless media.type == "image" && Time.at(media.created_time.to_i) > recipe.last_executed_at
          photos << {
            url: media.images.standard_resolution.url,
            caption: media.caption.try(:text)
          }
        end
        recipe.update_attributes last_executed_at: Time.current
        photos.reverse.each do |photo|
          if photo[:caption]
            status = photo[:caption].length <= 110 ? photo[:caption] : photo[:caption][0...110] + "…"
          else
            status = "I've just posted a photo on Instagram."
          end
          begin
            twitter.update_with_media status, open(photo[:url])
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
  name: 'PostInstagramPhotosToTwitter - every 5 minute',
  cron: (0..59).select{|i| i % 5 == 0}.join(",") + ' * * * *',
  klass: 'PostInstagramPhotosToTwitter'
)