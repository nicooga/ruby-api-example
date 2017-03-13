require 'spec_helper'

describe 'POST /api/users', type: :controller do
  VALID_ATTRIBUTES = {
    first_name: "Julio",
    last_name:  "Iglesias",
    email:      "julio.iglesias@gmail.com",
    password:   "password",
    born_on:    "2017-03-11T18:52:08.425-03:00"
  }

  def create_valid_user
    post "api/v1.0/users", attributes: VALID_ATTRIBUTES
  end

  context 'with valid data' do
    it 'should create an user' do
      expect { create_valid_user }.to change { Api::Models::User.count }.by(1)

      expect(last_response.status).to eq(201)

      data = response_body
      user = Api::Models::User.find id: data.fetch(:id)

      VALID_ATTRIBUTES.except(:born_on, :password).each do |attr, value|
        expect(data[attr]).to eq(value)
        expect(user.values[attr]).to eq(value)
      end

      response_born_on = DateTime.parse(data[:born_on])
      target_born_on   = DateTime.parse(VALID_ATTRIBUTES[:born_on])

      expect(response_born_on).to eq(target_born_on)
      expect(user.born_on).to eq(target_born_on)
    end

    it 'should send a notification email to the user' do
      create_valid_user
      email = response_body[:email]
      expect(Mail::TestMailer.deliveries.last.to.first).to eq(email)
    end
  end

  context 'with_invalid_data' do
    it 'should fail' do
      attributes = {
        born_on: "2017-03-11T18:52:08.425-03:00"
      }

      expect { post "api/v1.0/users", attributes: attributes }
      .not_to change { Api::Models::User.count }

      expect(last_response.status).to eq(422)

      data = response_body

      expect(data).to have_key(:errors)
      expect(data).to have_key(:error_type)
    end
  end
end
