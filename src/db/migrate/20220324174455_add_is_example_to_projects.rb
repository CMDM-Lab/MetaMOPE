class AddIsExampleToProjects < ActiveRecord::Migration[6.1]
  def change
    add_column :projects, :is_example, :boolean
  end
end
