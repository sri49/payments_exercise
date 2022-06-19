class CreatePayment < ActiveRecord::Migration[5.2]
  def change
    create_table :payments do |t|
      t.belongs_to :loan
      t.decimal :amount, precision: 8, scale: 2
      t.date :payment_date
      t.timestamps null: false
    end
  end
end
