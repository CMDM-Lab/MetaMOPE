class Upload < ApplicationRecord
    belongs_to :project
    has_many_attached :mzxmls

    #validates :files, presence: true, blob: {content_type: ['text/csv','text/mzXML']}
end