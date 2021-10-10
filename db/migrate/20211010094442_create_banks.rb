class CreateBanks < ActiveRecord::Migration[5.2]
  def change
    create_table :banks do |t|
      t.boolean :app_type
      t.string :app_address
      t.string :bank_shop_id
      t.string :bank_shop_id_test
      t.string :ins_password
      t.string :ins_success_url
      t.string :ins_fail_url

      t.timestamps
    end
  end
end
