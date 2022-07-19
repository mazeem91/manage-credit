class CreateTransactions < ActiveRecord::Migration[6.0]
  def change
    create_table :transactions, id: :uuid do |t|
      t.references :account, null: false, foreign_key: true
      t.references :source_transaction, type: :uuid, foreign_key: {to_table: :transactions}
      t.integer :event, null: false
      t.integer :amount_type, null: false
      t.decimal :amount, precision: 10, scale: 2

      t.timestamps
      t.index :event
      t.index :amount_type
    end
  end
end
