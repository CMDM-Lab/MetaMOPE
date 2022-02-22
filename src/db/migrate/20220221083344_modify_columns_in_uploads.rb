class ModifyColumnsInUploads < ActiveRecord::Migration[6.1]
  def change
    rename_column :uploads, :file, :mzxmls
  end
end
