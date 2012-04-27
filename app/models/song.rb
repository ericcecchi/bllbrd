class Song
  include Mongoid::Document
  include Mongoid::Slug

  field :name, :type => String
  field :year, :type => String
  field :plays, :type => Integer
  belongs_to :album
  has_and_belongs_to_many :tags
  has_and_belongs_to_many :playlists
  has_many :sources
  
	slug :name
	
	def self.new(params)
		
end
