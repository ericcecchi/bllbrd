class Source
  include Mongoid::Document
  field :name, type: String
  field :type, type: Symbol
  field :url, type: String
  field :site, type: String 
  field :quality, type: String
  field :clicks, type: Integer, default: 0
  field :upvotes, type: Integer, default: 0
  field :downvotes, type: Integer, default: 0
  field :verified, type: Boolean, default: false
  belongs_to :song, index: true
  belongs_to :user, index: true
  
  validates_presence_of :name, message: "Source name must be present."
  validates_uniqueness_of :url, message: "Source URL already exists."
end
