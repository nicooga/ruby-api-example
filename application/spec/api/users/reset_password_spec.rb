require 'spec_helper'

describe 'PATCH /api/users/:id/reset_password' do
  before :all do
    @user = create :user
  end

  context 'with valid data' do
    it 'should update the target user\'s password' do
      new_attributes = {
        new_password:     'password2',
        confirm_password: 'password2'
      }

      patch "api/v1.0/users/#{@user.id}/reset_password", attributes: new_attributes

      data = response_body
      @user.reload
      expect(last_response.status).to eq(200)
      expect(@user.password).to eq(new_attributes.fetch(:new_password))
    end
  end if false

  context 'with invalid data' do
    it 'should refuse to update the user' do
        old_password = @user.password
        p
        new_attributes = {
          new_password:     'password2',
          confirm_password: 'oopsie'
        }

        patch "api/v1.0/users/#{@user.id}/reset_password", attributes: new_attributes

        data = response_body
        @user.reload
        #expect(last_response.status).to eq(422)
        expect(@user.password).to eq(old_password)
    end
  end
end
