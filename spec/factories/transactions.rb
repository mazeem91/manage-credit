# == Schema Information
#
# Table name: transactions
#
#  id                    :uuid             not null, primary key
#  amount                :decimal(10, 2)
#  amount_type           :integer          not null
#  event                 :integer          not null
#  created_at            :datetime         not null
#  updated_at            :datetime         not null
#  account_id            :bigint           not null
#  source_transaction_id :uuid
#
# Indexes
#
#  index_transactions_on_account_id             (account_id)
#  index_transactions_on_amount_type            (amount_type)
#  index_transactions_on_event                  (event)
#  index_transactions_on_source_transaction_id  (source_transaction_id)
#
# Foreign Keys
#
#  fk_rails_...  (account_id => accounts.id)
#  fk_rails_...  (source_transaction_id => transactions.id)
#
FactoryBot.define do
  factory :transaction do
    association :account
    event { :balance_topup }
    amount_type { :credit }
    amount { "9.99" }
  end
end
