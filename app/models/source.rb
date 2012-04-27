class Source
  include Mongoid::Document
  field :name, :type => String
  field :type, :type => String
  field :url, :type => String
  field :quality, :type => String
  field :clicks, :type => Integer
  field :reports, :type => Integer
  belongs_to :song
end
