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

  end
end