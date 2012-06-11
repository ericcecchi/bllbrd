class Source
  include Mongoid::Document
  field :name, :type => String
  field :type, :type => Symbol
  field :url, :type => String
  field :quality, :type => String
  field :clicks, :type => Integer
  field :upvotes, :type => Integer
  field :downvotes, :type => Integer
  field :verified, :type => Boolean
  belongs_to :song, index: true
  belongs_to :user, index: true
end
