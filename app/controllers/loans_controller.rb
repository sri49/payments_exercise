class LoansController < ActionController::API

  rescue_from ActiveRecord::RecordNotFound do |exception|
    render json: 'not_found', status: :not_found
  end

  def index
    render json: Loan.all
  end

  def show
    render json: Loan.find(params[:id])
  end

  def add_payment
  	@loan=Loan.find(params[:id])
  	payment_amount = params[:amount].to_d

  	if @loan.outstanding_balance >= payment_amount
  		@loan.payments.build(amount: payment_amount, payment_date: params[:payment_date] || Date.today)
  		@loan.outstanding_balance = (@loan.outstanding_balance || @loan.funded_amount) - payment_amount
  		if @loan.save
  			@payment = @loan.payments.max_by(&:created_at)
  			render json: { loan: @loan, new_payment: @payment }
  		else
  			render json: { error: @loan.errors }
  		end
  	else
  		render json: { error: 'amount is greater than balance' }
  	end
  end

  def show_payment
  	@payment = Payment.find(params[:payment_id])
  	render json: @payment
  end

  def show_payments
  	@loan=Loan.find(params[:id])
  	render json: @loan.payments
  end
end
