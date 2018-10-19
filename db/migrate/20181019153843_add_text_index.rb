class AddTextIndex < ActiveRecord::Migration[5.2]
  def change
    add_index :posts, "to_tsvector('english', content)", using: :gin, name: 'posts_content_index'
    add_index :users, "to_tsvector('english', bio)", using: :gin, name: 'users_bio_index'
  end
end
