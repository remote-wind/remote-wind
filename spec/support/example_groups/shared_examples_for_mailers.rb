shared_examples "a mailer" do

  describe "a mailer method" do
    let(:user) { build_stubbed(:user) }
    subject(:mail) { described_class.send(method_name, *args.presence || user) }

    its(:subject) { should eq subject_line }
    its(:to) { should eq([user.email]) }

    it "renders the body" do
      expect(mail.body.encoded).to match("Hi")
    end

    it "sends email to recipient" do
      expect(ActionMailer::Base.deliveries).to include(mail)
    end

    it "logs error if message is not delivered" do
      full_method_name = described_class.name + '#' + method_name.to_s
      Mail::Message.any_instance.stub(:deliver).and_return(false)
      Rails.logger.should_receive(:error)
      .with("#{full_method_name}: Email could not be delivered")
      mail
    end
  end

end