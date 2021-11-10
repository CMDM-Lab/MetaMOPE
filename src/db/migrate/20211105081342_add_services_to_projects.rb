class AddServicesToProjects < ActiveRecord::Migration[6.1]
  def change
    add_column :projects, :mobile_phase_evaluation, :boolean, null: false
    add_column :projects, :peak_evaluation, :boolean, null: false
  end
end
