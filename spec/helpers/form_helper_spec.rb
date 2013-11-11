# spec/helper/form_helper_spec.rb
require 'spec_helper'

describe FormHelper do

  describe FormHelper::Rw2FormBuilder do

    describe 'div_field_with_label' do

      # how do i create or mock template?
      # template = ?
      let(:resource)  { FactoryGirl.create :user }
      let(:helper)    { FormHelper::Rw2FormBuilder.new(:user, resource, self, {})}
      let(:output)    {
        helper.div_field_with_label :email do
          helper.email_field(:email, :class => 'input')
        end
      }

      it 'wraps input and label' do
        expect(output).to have_selector 'div.field.email'
      end

      it 'creates a label' do
        expect(output).to have_selector  "label", text: "Email"
      end

      it 'creates an input' do
        expect(output).to have_selector "input[type=email]"
      end

      it 'input has correct value' do
        expect(output).to match 'value="example@example.com"'
      end

      it 'creates an error message' do
        resource.errors.add :email, 'thats a lame email address'
        content = helper.div_field_with_label :email do
          helper.email_field(:email, :class => 'input')
        end

        expect(output).to have_selector ".error-message", text: 'thats a lame email address'
      end

      it 'takes a custom label' do
        label = 'Email, (We need your current password)'
        expect(helper.div_field_with_label :password, label).to include(label)
      end

    end
  end
end
