class CreatePosts < ActiveRecord::Migration[5.2]
  def change
    create_table :posts do |t|
      t.references :original_user, index: true
      t.references :user, index: true
      t.references :original_post, index: true
      t.string :username
      t.string :display_name
      t.integer :likes_count, default: 0
      t.integer :reposts_count, default: 0
      t.boolean :private, default: false
      t.boolean :repost, default: false
      t.text :content
      
      t.timestamps
    end
  end
end
