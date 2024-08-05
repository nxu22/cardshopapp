class AboutPage < ApplicationRecord
  
    def self.ransackable_attributes(auth_object = nil)
      %w[content created_at id updated_at]
    end
  end