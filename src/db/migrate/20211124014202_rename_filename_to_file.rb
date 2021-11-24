class RenameFilenameToFile < ActiveRecord::Migration[6.1]
  def change
    rename_column :uploads, :file_name, :file
  end
end
