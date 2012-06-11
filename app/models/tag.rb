class Tag
  include Mongoid::Document
  include Mongoid::FullTextSearch
  field :name, :type => String
  key :name
  validates_uniqueness_of(:name)

  has_and_belongs_to_many :songs, index: true
  fulltext_search_in :name
end
