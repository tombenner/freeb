class UsState < ActiveRecord::Base
  freeb do
    type "/location/us_state"
    properties :area => "/location/location/area"
  end
end