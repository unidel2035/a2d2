class CreateCollaborators < ActiveRecord::Migration[8.1]
  def change
    create_table :collaborators do |t|
      t.references :spreadsheet, null: false, foreign_key: true
      t.integer :user_id
      t.string :email
      t.string :permission, default: 'view' # view, edit, admin

      t.timestamps

      t.index [:spreadsheet_id, :user_id], unique: true
      t.index [:spreadsheet_id, :email], unique: true
    end
  end
end
