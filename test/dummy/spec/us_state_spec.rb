require 'spec_helper'
class UsState
  describe ".fcreate" do
    it "returns Alaska and Texas for MQL specifying an area > 500000" do
      mql = [{"/location/location/area>" => 500000}]
      states = UsState.fcreate(mql)
      freebase_ids = states.collect{|s| s.freebase_id }
      freebase_ids.should =~ ["/en/alaska", "/en/texas"]
    end
  end
end