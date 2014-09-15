shared_examples "a mailer" do

  describe "a mailer method" do

    include_context 'multipart email'

    it "has the correct headers" do
      expect(mail.subject).to eq subject_line
      expect(mail.to).to eq([user.email])
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