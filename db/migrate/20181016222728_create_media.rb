class CreateMedia < ActiveRecord::Migration[5.2]
  def change
    create_table :media do |t|
      t.references :user, index: true
      t.references :post, index: true
      t.string :image
      t.string :media_type, comment: "image/video"
      t.timestamps
    end
  end
end
