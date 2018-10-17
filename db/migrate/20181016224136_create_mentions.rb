class CreateMentions < ActiveRecord::Migration[5.2]
  def change
    create_table :mentions do |t|
      t.references :user, index: true
      t.references :post, index: true
      t.boolean :show_in_timeline, default: true
      t.integer :slot, default: 0, comment: "0,1,2,3"
      
      t.timestamps
    end
  end
end
