class User < Axel::ServiceResource::Base
  site "http://user-service.dev"

  has_many :personas
  has_one :address
end
