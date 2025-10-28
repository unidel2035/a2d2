# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).

# AUTH-002: Create default roles and permissions
puts "Creating default roles and permissions..."

# Create Permissions
permissions_data = [
  # Document permissions
  { name: "Создание документов", resource: "Document", action: "create" },
  { name: "Просмотр документов", resource: "Document", action: "read" },
  { name: "Редактирование документов", resource: "Document", action: "update" },
  { name: "Удаление документов", resource: "Document", action: "delete" },
  { name: "Управление документами", resource: "Document", action: "manage" },

  # Process permissions
  { name: "Создание процессов", resource: "Process", action: "create" },
  { name: "Просмотр процессов", resource: "Process", action: "read" },
  { name: "Редактирование процессов", resource: "Process", action: "update" },
  { name: "Удаление процессов", resource: "Process", action: "delete" },
  { name: "Управление процессами", resource: "Process", action: "manage" },

  # Robot permissions
  { name: "Создание роботов", resource: "Robot", action: "create" },
  { name: "Просмотр роботов", resource: "Robot", action: "read" },
  { name: "Редактирование роботов", resource: "Robot", action: "update" },
  { name: "Удаление роботов", resource: "Robot", action: "delete" },
  { name: "Управление роботами", resource: "Robot", action: "manage" },

  # User permissions
  { name: "Создание пользователей", resource: "User", action: "create" },
  { name: "Просмотр пользователей", resource: "User", action: "read" },
  { name: "Редактирование пользователей", resource: "User", action: "update" },
  { name: "Удаление пользователей", resource: "User", action: "delete" },
  { name: "Управление пользователями", resource: "User", action: "manage" },

  # Audit Log permissions
  { name: "Просмотр журнала аудита", resource: "AuditLog", action: "read" },
  { name: "Управление журналом аудита", resource: "AuditLog", action: "manage" }
]

permissions = permissions_data.map do |perm_data|
  Permission.find_or_create_by!(
    resource: perm_data[:resource],
    action: perm_data[:action]
  ) do |permission|
    permission.name = perm_data[:name]
    permission.description = "#{perm_data[:action]} access to #{perm_data[:resource]}"
  end
end

puts "Created #{permissions.count} permissions"

# Create Roles
viewer_role = Role.find_or_create_by!(name: "viewer") do |role|
  role.description = "Может просматривать данные"
end

operator_role = Role.find_or_create_by!(name: "operator") do |role|
  role.description = "Может просматривать и создавать данные"
end

technician_role = Role.find_or_create_by!(name: "technician") do |role|
  role.description = "Может просматривать, создавать и редактировать данные"
end

admin_role = Role.find_or_create_by!(name: "admin") do |role|
  role.description = "Полный доступ ко всем функциям"
end

puts "Created 4 roles"

# Assign permissions to roles
# Viewer: read-only access
viewer_permissions = permissions.select { |p| p.action == "read" }
viewer_permissions.each { |perm| viewer_role.add_permission(perm) }

# Operator: read and create
operator_permissions = permissions.select { |p| %w[read create].include?(p.action) }
operator_permissions.each { |perm| operator_role.add_permission(perm) }

# Technician: read, create, update
technician_permissions = permissions.select { |p| %w[read create update].include?(p.action) }
technician_permissions.each { |perm| technician_role.add_permission(perm) }

# Admin: all permissions
permissions.each { |perm| admin_role.add_permission(perm) }

puts "Assigned permissions to roles"
puts "Seed data created successfully!"
