class Playlist
  include Mongoid::Document
  include Mongoid::Slug
  include Mongoid::FullTextSearch

  field :name, type: String
  field :description, type: String, default: ''
  has_many :rankings, dependent: :destroy
  belongs_to :user, index: true
  
  validates_presence_of :name, message: "Name is required."
  
  slug :name
  fulltext_search_in :name
end
