require 'rails_helper'

RSpec.describe "Api::V1::Accounts", type: :request do
  describe "GET /index" do
    it "returns http success" do
      get "/api/v1/accounts"
      expect(response.status).to eq(200)
    end
  end

  scenario "valid account attributes" do
    post "/api/v1/accounts", params: {
      account: {
        first_name: 'test',
        last_name: 'test',
        phone_number: '01111111',
        email: 'test@test.com'
      }
    }
    expect(response.status).to eq(201)
    json = JSON.parse(response.body).deep_symbolize_keys
    expect(json[:first_name]).to eq('test')
    expect(json[:balance]).to eq("0.0")
    expect(json[:transactions]).to eq(nil)
    expect(json[:status]).to eq("pending")
  end

  scenario "invalid account attributes" do
    post "/api/v1/accounts", params: {
      account: {
        first_name: 'test',
        last_name: 'test',
        phone_number: '01111111'
      }
    }
    expect(response.status).to eq(400)
  end

  scenario "account status invalid transfer" do
    @account = Account.new({
      first_name: 'test',
      last_name: 'test',
      phone_number: '01111111',
      email: 'test@test.com'
    })
    @account.save

    @account2 = Account.new({
      first_name: 'test',
      last_name: 'test',
      phone_number: '01111112',
      email: 'test2@test.com'
    })
    @account2.save

    post "/api/v1/accounts/#{@account.id}/transfer_by_phone_number", params: {
      amount: 50.0,
      phone_number: '01111112'
    }
    expect(response.status).to eq(403)
  end

  scenario "same account invalid transfer" do
    @account = Account.new({
      first_name: 'test',
      last_name: 'test',
      phone_number: '01111111',
      email: 'test@test.com',
      status: :verified
    })
    @account.save

    @account2 = Account.new({
      first_name: 'test',
      last_name: 'test',
      phone_number: '01111112',
      email: 'test2@test.com',
      status: :verified
    })
    @account2.save

    post "/api/v1/accounts/#{@account.id}/transfer_by_phone_number", params: {
      amount: 50.0,
      phone_number: '01111111'
    }
    expect(response.status).to eq(400)
  end

  scenario "account balance invalid transfer" do
    @account = Account.new({
      first_name: 'test',
      last_name: 'test',
      phone_number: '01111111',
      email: 'test@test.com',
      status: :verified
    })
    @account.save

    @account2 = Account.new({
      first_name: 'test',
      last_name: 'test',
      phone_number: '01111112',
      email: 'test2@test.com',
      status: :verified

    })
    @account2.save

    post "/api/v1/accounts/#{@account.id}/transfer_by_phone_number", params: {
      amount: '50.0',
      phone_number: '01111112'
    }
    expect(response.status).to eq(403)
  end

  scenario "account balance valid transfer" do
    @account = Account.new({
      first_name: 'test',
      last_name: 'test',
      phone_number: '01111111',
      email: 'test@test.com',
      status: :verified
    })
    @account.save
    account_controler = Api::V1::AccountsController.new
    account_controler.topup(@account, 4000)

    @account2 = Account.new({
      first_name: 'test',
      last_name: 'test',
      phone_number: '01111112',
      email: 'test2@test.com',
      status: :verified

    })
    @account2.save

    post "/api/v1/accounts/#{@account.id}/transfer_by_phone_number", params: {
      amount: '50.0',
      phone_number: '01111112'
    }
    expect(response.status).to eq(200)

    get "/api/v1/accounts/#{@account.id}"
    json = JSON.parse(response.body).deep_symbolize_keys
    expect(json[:balance]).to eq("3950.0")
  end
end
