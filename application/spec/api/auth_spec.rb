require 'spec_helper'

describe 'POST /api/v1.0/auth' do
  context 'with valid data' do
    it 'should return a correct access token' do
      user = create :user
      post '/api/v1.0/auth', attributes: { user_id: user.id, password: user.password }
      expect(last_response.status).to eq(201)
      token = response_body.fetch(:token)
      payload, _ = JWT.decode(token, SECRET, false)
      expect(payload.fetch('user_id')).to eq(user.id)
    end
  end
end
