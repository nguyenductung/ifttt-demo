class M::Recipe < ActiveRecord::Base
  has_many :recipes, foreign_key: :m_recipe_id

  validates :m_id, uniqueness: true

  PROVIDERS = {
    "twitter" => "twitter",
    "instagram" => "instagram",
    "google" => "google_oauth2"
  }

  def required_providers
    [PROVIDERS[source], PROVIDERS[target]].compact.uniq
  end
end