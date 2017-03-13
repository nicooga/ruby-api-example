require 'spec_helper'

describe 'PUT /api/users/:id' do
  before :each do
    @user = create :user
  end

  def generate_access_token(user)
    token = JWT.encode({user_id: user.id}, SECRET)
    "Bearer #{token}"
  end

  context 'when authenticated' do
    before :each do
      header 'Access-Token', generate_access_token(@user)
    end

    context 'with valid data' do
      it 'should update the target user' do
        new_attributes = {
          first_name: "Robert",
          last_name:  "Roberts",
          born_on:    "2017-03-11T18:52:08.425-03:00"
        }

        put "api/v1.0/users/#{@user.id}", attributes: new_attributes

        data = response_body
        expect(last_response.status).to eq(200)

        @user.reload

        new_attributes.except(:born_on).each do |attr, value|
          expect(@user.values[attr]).to eq(value)
          expect(data[attr]).to eq(value)
        end

        target_born_on   = DateTime.parse(new_attributes[:born_on])
        response_born_on = DateTime.parse(data[:born_on])

        expect(response_born_on).to eq(target_born_on)
        expect(@user.born_on).to eq(target_born_on)
      end

      it 'should refuse to update a different user than the current' do
        user2 = create :user
        old_user_name = @user.first_name
        header 'Access-Token', generate_access_token(user2)
        new_attributes = {
          first_name: "Robert",
          last_name:  "Roberts",
          born_on:    "2017-03-11T18:52:08.425-03:00"
        }

        put "api/v1.0/users/#{@user.id}", attributes: new_attributes
        expect(last_response.status).to be(403)
        expect(@user.reload.first_name).to eq(old_user_name)
      end
    end

    context 'with invalid data' do
      it 'should refuse to update the user' do
        new_attributes = { first_name: nil }

        put "api/v1.0/users/#{@user.id}", attributes: new_attributes

        expect(last_response.status).to eq(422)
        expect(@user.first_name).to be_present
      end
    end
  end

  context 'when not authenticated' do
    it 'should return an authencation error' do
      put "api/v1.0/users/#{@user.id}", attributes: {}
      expect(last_response.status).to eq(401)
    end
  end
end
