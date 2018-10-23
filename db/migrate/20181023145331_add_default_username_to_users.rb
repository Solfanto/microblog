class AddDefaultUsernameToUsers < ActiveRecord::Migration[5.2]
  def change
    add_column :users, :is_default_username, :boolean, default: true
  end
end
