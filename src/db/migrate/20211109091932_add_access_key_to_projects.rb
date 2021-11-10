class AddAccessKeyToProjects < ActiveRecord::Migration[6.1]
  def change
    add_column :projects, :access_key, :string
  end
end
