class Upload < ApplicationRecord
    belongs_to :project
    #has_many_attached :mzxmls
    mount_uploaders :mzxmls, MzxmlsUploader
    serialize :mzxmls, JSON

    validates :mzxmls, blob: {content_type: ['application/mzXML', 'application/mzML']}
end