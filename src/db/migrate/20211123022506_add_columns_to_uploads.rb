class AddColumnsToUploads < ActiveRecord::Migration[6.1]
  def change
    add_column :uploads, :file_name, :string
    add_column :uploads, :file_size, :integer
    add_column :uploads, :project_id, :integer
  end
end
