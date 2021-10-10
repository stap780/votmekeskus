class CreateOrders < ActiveRecord::Migration[5.2]
  def change
    create_table :orders do |t|
      t.string :shop_id
      t.decimal :amount
      t.string :transaction_id
      t.string :key
      t.string :description
      t.string :order_id
      t.string :phone
      t.string :email
      t.string :signature
      t.string :status
      t.string :ip

      t.timestamps
    end
  end
end
