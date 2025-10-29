class AddRobotIdToDocuments < ActiveRecord::Migration[8.0]
  def change
    add_reference :documents, :robot, null: true, foreign_key: true
    add_index :documents, :robot_id
  end
end
