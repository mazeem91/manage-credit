class Api::V1::AccountsController < ApplicationController
  def create
    @account = Account.new(account_params)
    if @account.save
      render json: @account
    else
      render error: { error: "Creation failed"}, status: 400
    end
  end

  def index
    @accounts = Account.all
    render json: @accounts
  end

  def show
    @account = Account.includes(:transactions).find(params[:id])
    render json: @account, include: %i[transactions]
  end

  def account_params
    params.require(:account).permit(:first_name, :last_name, :email, :phone_number)
  end

  def transfer_by_phone_number
    @amount = params[:amount]
    @from_account = Account.find(params[:id])
    @to_account = Account.find_by(phone_number:params[:phone_number])
    handle_transfer
  end

  def transfer_by_email
    @amount = params[:amount]
    @from_account = Account.find(params[:id])
    @to_account = Account.find_by(email:params[:email])
    handle_transfer
  end

  def handle_transfer
    return render json: { error: "required amount"}, status: 403 if @amount.nil?
    return render json: { error: "invalid account"}, status: 403 if @to_account.nil?
    return render json: { error: "same account"}, status: 403 if @to_account == @from_account
    return render json: { error: "invalid account status"}, status: 403 unless valid_accounts_statuses
    return render json: { error: "insufficient balance"}, status: 403 unless transfer_amount
    return render status: :ok
  end

  def transfer_amount
    is_valid = true
    ActiveRecord::Base.transaction do
      @to_account.update!(balance: @to_account.balance + @amount)
      @from_account.update!(balance: @from_account.balance - @amount)
      from_tr_id = SecureRandom.uuid
      Transaction.create(
        id:from_tr_id,
        event: :outcoming_transfer,
        amount:@amount,
        amount_type: :debit,
        account_id: @from_account.id
      )
      Transaction.create(
        id:SecureRandom.uuid,
        event: :incoming_transfer,
        amount:@amount,
        amount_type: :credit,
        account_id: @to_account.id,
        source_transaction_id:from_tr_id
      )
      is_valid = @from_account.balance >= 0
      raise ActiveRecord::Rollback if !is_valid
    end
    return is_valid
  end

  def valid_accounts_statuses
    return @from_account.verified_status? && @to_account.verified_status?
  end
end
