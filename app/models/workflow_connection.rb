# frozen_string_literal: true

# WorkflowConnection represents a connection between two workflow nodes
# Similar to n8n's connection system
class WorkflowConnection < ApplicationRecord
  # Associations
  belongs_to :workflow
  belongs_to :source_node, class_name: 'WorkflowNode'
  belongs_to :target_node, class_name: 'WorkflowNode'

  # Validations
  validates :connection_type, presence: true
  validates :source_output_index, numericality: { only_integer: true, greater_than_or_equal_to: 0 }
  validates :target_input_index, numericality: { only_integer: true, greater_than_or_equal_to: 0 }

  # Ensure source and target are different
  validate :different_nodes

  # Instance methods

  # Export connection in n8n format
  def to_n8n_format
    {
      source: source_node_id.to_s,
      target: target_node_id.to_s,
      sourceOutputIndex: source_output_index,
      targetInputIndex: target_input_index,
      type: connection_type
    }
  end

  private

  def different_nodes
    if source_node_id == target_node_id
      errors.add(:target_node_id, "can't be the same as source node")
    end
  end
end
