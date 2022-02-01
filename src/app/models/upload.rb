class Upload < ApplicationRecord
    belongs_to :project
    has_many_attached :mzxmls
end