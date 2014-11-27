class CreateAuthentications < ActiveRecord::Migration
  def change
    create_table :authentications do |t|
      t.integer  :user_id
      t.string   :provider
      t.string   :platform_id
      t.string   :username
      t.string   :access_token
      t.string   :secret_token
      t.string   :reset_token
      t.datetime :expires_at

      t.timestamps
    end
  end
end
