class Account < ApplicationRecord
    belongs_to :manager
    has_many :customers

    accepts_nested_attributes_for :manager

end
