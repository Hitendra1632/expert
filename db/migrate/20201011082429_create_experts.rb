class CreateExperts < ActiveRecord::Migration[6.0]
  def change
    create_table :experts do |t|
      t.string :name
      t.text  :description
      t.string :reference_link
      t.integer :expert_type
      t.integer :expert_version
      t.jsonb :data
      t.timestamps
    end
  end
end
