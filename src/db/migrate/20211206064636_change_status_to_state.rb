class ChangeStatusToState < ActiveRecord::Migration[6.1]
  def change
    rename_column :projects, :status, :state
  end
end
