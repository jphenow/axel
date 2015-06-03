class Address < Axel::ServiceResource::Base
  site "http://user-service.dev"

  belongs_to :address
end
