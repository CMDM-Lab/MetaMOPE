class Upload < ApplicationRecord
    belongs_to :project
    has_many_attached :mzxmls

    validates :mzxmls, blob: {content_type: ['application/xml']}
end