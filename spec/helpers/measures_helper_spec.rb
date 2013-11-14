require 'spec_helper'

describe MeasuresHelper do

  describe "#degrees_and_cardinal" do

    subject do
      degrees_and_cardinal(5)
    end

    it { should eq "5 (N)" }

  end
end
