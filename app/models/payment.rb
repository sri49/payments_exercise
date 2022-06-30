class Payment < ActiveRecord::Base
 belongs_to :loan 
 validates :amount, presence: true
 validates :payment_date, presence: true
 validate :amount_not_greater_than_outstading_balance_amount

 scope :persisted, -> { where "id IS NOT NULL" }

 private

 def amount_not_greater_than_outstading_balance_amount
 	binding.pry
 	return errors.add(:loan, "must be associated") if !loan
 	return errors.add(:amount, "amount should be grater than 0") if amount <= 0
 	return true if amount <= loan.outstanding_balance
 	errors.add(:amount,"amount can't be greater than outstanding loan balance")
 	logger.warn "Payment creation failed due to #{errors.messages} for loan #{loan.id}"
 end

 def logger
 	Logger.new("#{Rails.root}/log/payment_logger_#{Date.today}")
 end
end
