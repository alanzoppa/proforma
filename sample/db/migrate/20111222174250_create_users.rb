class CreateUsers < ActiveRecord::Migration
  def change
    create_table :users do |t|
      t.string :first_name
      t.string :middle_initial
      t.string :last_name
      t.string :gender_choice
      t.text :bio
      t.boolean :cat

      t.timestamps
    end
  end
end
