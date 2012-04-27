class Tag
  include Mongoid::Document
  field :name, :type => String
  key :name
  validates_uniqueness_of(:name)

  has_and_belongs_to_many :songs
end
