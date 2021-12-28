class Upload < ApplicationRecord
    belongs_to :project
    has_one_attached :grouping
    has_one_attached :injection
    has_one_attached :standard
    has_one_attached :mzxml

    #validates :files, presence: true, blob: {content_type: ['text/csv','text/mzXML']}
end