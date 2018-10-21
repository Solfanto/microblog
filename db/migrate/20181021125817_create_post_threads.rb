class CreatePostThreads < ActiveRecord::Migration[5.2]
  def change
    create_table :post_threads do |t|
      t.jsonb :tree, default: {}, comment: '{"id": 1, content: "", replies: []}'
      t.timestamps
    end
    
    add_reference :posts, :post_thread, index: true
  end
end
