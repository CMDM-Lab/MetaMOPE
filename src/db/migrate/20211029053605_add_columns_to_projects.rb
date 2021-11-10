class AddColumnsToProjects < ActiveRecord::Migration[6.1]
  def change
    add_column :projects, :name, :string, null: false
    add_column :projects, :status, :integer
    add_column :projects, :file_size, :integer
    add_column :projects, :user_id, :integer

  end
end
