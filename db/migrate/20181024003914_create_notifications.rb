class CreateNotifications < ActiveRecord::Migration[5.2]
  def change
    create_table :notifications do |t|
      t.references :user, index: true
      t.text :message
      t.string :notification_type, comment: "followed/followed_back/replied/reposted/..."
      t.datetime :read_at
      t.references :primary_item, polymorphic: true, index: { name: 'index_notifications_on_primary_item' }
      t.references :secondary_item, polymorphic: true, index: { name: 'index_notifications_on_secondary_item' }
      
      t.timestamps
    end
    
    add_column :users, :unread_notifications_count, :integer, default: 0
    add_column :users, :email_notifications_enabled, :boolean, default: true
  end
end
