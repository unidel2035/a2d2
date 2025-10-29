class RenameTasksToRobotTasks < ActiveRecord::Migration[8.0]
  def change
    rename_table :tasks, :robot_tasks
  end
end
