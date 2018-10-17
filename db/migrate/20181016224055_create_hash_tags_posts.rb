class CreateHashTagsPosts < ActiveRecord::Migration[5.2]
  def change
    create_table :hash_tags_posts do |t|
      t.references :hash_tag, index: true
      t.references :post, index: true
      
      t.timestamps
    end
  end
end
