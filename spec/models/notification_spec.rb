require "spec_helper"

describe Notification do

  it { should belong_to :user }
  it { should respond_to :key }
  it { should respond_to :message }
  it { should respond_to :subject }

end