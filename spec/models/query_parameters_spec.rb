require 'spec_helper'
require 'data-com-api/query_parameters'

describe DataComApi::QueryParameters do

  subject(:query_parameters) { FactoryGirl.build(:query_parameters) }

  it "has a valid factory" do
    expect{query_parameters}.not_to raise_error
  end

  describe "#updated_since" do

    it "returns time object" do
      current_time = Time.now.utc.in_time_zone(DataComApi::Client::TIME_ZONE)
      query_parameters.updated_since = current_time.to_s

      expect(query_parameters.updatedSince).to be_an_instance_of ActiveSupport::TimeWithZone
    end

    it "returns same time as the one assigned" do
      current_time = Time.now.utc.in_time_zone(DataComApi::Client::TIME_ZONE)
      query_parameters.updated_since = current_time.to_s

      # XXX: Be careful, comparison between the two ActiveSupport::TimeWithZone
      #      fails for unknown reasons to me, even if to_i and to_s are equal.
      #      Comparison through strings seems ok by the way because the class
      #      will just output data directly to the API, so string based
      expect(query_parameters.updatedSince.to_s).to eq(current_time.to_s)
    end

  end

end
