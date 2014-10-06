require "spec_helper"

describe UserMailer, :type => :mailer do
  describe "test" do
    let(:user) { build_stubbed(:user) }
    let(:mail) { UserMailer.test(user) }

    include_context "multipart email"

    it "renders the headers" do
      expect(mail.subject).to eq("Test")
      expect(mail.to).to eq([user.email])
      expect(mail.from).to eq([ENV['REMOTE_WIND_DEFAULT_FROM_EMAIL']])
    end

    it "generates a multipart message (plain text and html)" do
      expect(mail.body.parts.length).to eq 2
      expect(mail.body.parts.collect(&:content_type)).to eq ["text/plain; charset=utf-8", "text/html; charset=utf-8"]
    end

    it "renders the body" do
      expect(text).to match 'Hello'
      expect(html).to have_selector('h1', text: 'Hello')
    end
  end

end
