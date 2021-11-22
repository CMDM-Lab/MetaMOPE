class AddUploadToProjects < ActiveRecord::Migration[6.1]
  def change
    add_column :projects, :upload, :string
  end
end
