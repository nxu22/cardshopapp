class Page < ApplicationRecord
    # Allowlist searchable attributes for Ransack
    def self.ransackable_attributes(auth_object = nil)
      %w[title content page_type]
    end
  
    # Allowlist searchable associations for Ransack
    # Update the array with the names of associations you want to make searchable,
    # or leave it empty if no associations should be searchable
    def self.ransackable_associations(auth_object = nil)
      []  # Modify this array based on your model associations
    end
  
    # Additional model code here (validations, callbacks, etc.)
  end
  