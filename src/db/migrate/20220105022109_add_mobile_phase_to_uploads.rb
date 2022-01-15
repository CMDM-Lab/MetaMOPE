class AddMobilePhaseToUploads < ActiveRecord::Migration[6.1]
  def change
    add_column :uploads, :mobile_phase, :string
  end
end
