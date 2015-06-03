class Persona < Axel::ServiceResource::Base
  site "http://user-service.dev"

  belongs_to :user

  field :user_id
end

class PersonaWithIncludedUser < Axel::ServiceResource::Base
  site "http://user-service.dev"

  belongs_to :user, included: true

  field :user_id
end
