class AddOperatorFieldsToUsers < ActiveRecord::Migration[8.0]
  def change
    add_column :users, :first_name, :string
    add_column :users, :last_name, :string
    add_column :users, :role, :integer, default: 0, null: false
    add_column :users, :license_number, :string
    add_column :users, :license_expiry, :date
    add_column :users, :total_flight_hours, :decimal, precision: 10, scale: 2, default: 0
    # Removed encrypted_password - using password_digest from create_users instead (bcrypt/has_secure_password)

    add_index :users, :role
    add_index :users, :license_number
  end
end
