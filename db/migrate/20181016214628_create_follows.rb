class CreateFollows < ActiveRecord::Migration[5.2]
  def change
    create_table :follows do |t|
      t.references :user, index: true
      t.references :following, index: true
      t.boolean :friend, default: false
      t.boolean :mute, default: false
      
      t.timestamps
    end
  end
end
