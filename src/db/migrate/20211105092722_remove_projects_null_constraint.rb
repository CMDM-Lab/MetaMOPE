class RemoveProjectsNullConstraint < ActiveRecord::Migration[6.1]
  def change
    change_column_null :projects, :mobile_phase_evaluation, nil 
    change_column_null :projects, :peak_evaluation, nil 
  end
end
