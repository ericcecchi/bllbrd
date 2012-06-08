class Ranking
  include Mongoid::Document
  field :position, :type => Integer, default: 0
  field :peak, :type => Integer, default: 0
  field :weeks, :type => Integer, default: 0
  
  belongs_to :song
  belongs_to :playlist
end
