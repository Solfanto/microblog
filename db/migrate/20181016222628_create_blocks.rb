class CreateBlocks < ActiveRecord::Migration[5.2]
  def change
    create_table :blocks do |t|
      t.references :user, index: true
      t.references :blocked_user, index: true
      t.timestamps
    end
  end
end
