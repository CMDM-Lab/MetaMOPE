class ChangeProjectsStatusType < ActiveRecord::Migration[6.1]
  def change
    change_column :projects, :status, :string
  end
end
