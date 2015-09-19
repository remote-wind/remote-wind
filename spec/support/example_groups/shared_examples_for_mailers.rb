shared_examples "a mailer" do

  describe "a mailer method" do

    include_context 'multipart email'

    it "has the correct headers" do
      expect(mail.subject).to eq subject_line
      expect(mail.to).to eq([user.email])
    end
  end
end