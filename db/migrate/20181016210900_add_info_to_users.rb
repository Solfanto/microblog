class AddInfoToUsers < ActiveRecord::Migration[5.2]
  def change
    add_column :users, :username, :string
    add_column :users, :display_name, :string
    add_column :users, :bio, :string
    add_column :users, :website, :string
    add_column :users, :city, :string
    add_column :users, :followers_count, :integer, default: 0
    add_column :users, :following_count, :integer, default: 0
    add_column :users, :posts_count, :integer, default: 0
    add_column :users, :reposts_count, :integer, default: 0
    add_column :users, :likes_count, :integer, default: 0
    add_column :users, :private_account, :boolean, default: false
    add_column :users, :banned_at, :datetime
    add_column :users, :medias_count, :integer, default: 0
    
    add_index :users, :username, unique: true
  end
end
