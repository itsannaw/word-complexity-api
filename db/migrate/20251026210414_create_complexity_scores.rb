# frozen_string_literal: true

# Migration for creating the complexity_scores table
class CreateComplexityScores < ActiveRecord::Migration[8.0]
  def change
    create_table :complexity_scores do |t|
      t.string :job_id, null: false
      t.string :status, default: 'pending', null: false
      t.text :words, null: false
      t.text :result

      t.timestamps
    end
    
    add_index :complexity_scores, :job_id, unique: true
    add_index :complexity_scores, :status
  end
end
