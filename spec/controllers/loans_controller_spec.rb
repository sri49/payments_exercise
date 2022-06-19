require 'rails_helper'

RSpec.describe LoansController, type: :controller do
  describe '#index' do
    it 'responds with a 200' do
      get :index
      expect(response).to have_http_status(:ok)
    end
  end

  describe '#show' do
    let(:loan) { Loan.create!(funded_amount: 100.0) }

    it 'responds with a 200' do
      get :show, params: { id: loan.id }
      expect(response).to have_http_status(:ok)
    end

    context 'if the loan is not found' do
      it 'responds with a 404' do
        get :show, params: { id: 10000 }
        expect(response).to have_http_status(:not_found)
      end
    end
  end

  describe '#add_payment' do
    let(:loan) { Loan.create!(funded_amount: 100.0, outstanding_balance: 100.0) }

    context 'with valid params' do
      it 'adds a payment if outstanding balance greater than payment amount' do
        expect(loan.payments.count).to eq 0
        post :add_payment, params: { id: loan.id, amount: 50.0, payment_date: Date.today-5.days}
        expect(loan.payments.count).to eq 1
        result= JSON.parse(response.body).deep_symbolize_keys
        payment = result[:new_payment]
        expect(payment[:amount]).to eq "50.0"
        expect(payment[:payment_date]).to eq (Date.today-5.days).to_s
      end

      it 'if payment date is not passed it defaults to todays date' do
        expect(loan.payments.count).to eq 0
        post :add_payment, params: { id: loan.id, amount: 50.0}
        expect(loan.payments.count).to eq 1
        result= JSON.parse(response.body).deep_symbolize_keys
        payment = result[:new_payment]
        expect(payment[:payment_date]).to eq Date.today.to_s
      end

      it 'returns error if outstanding balance is less than payment amount' do
        expect(loan.payments.count).to eq 0
        post :add_payment, params: { id: loan.id, amount: 150.0, payment_date: Date.today-5.days}
        expect(loan.payments.count).to eq 0
        result= JSON.parse(response.body).deep_symbolize_keys
        expect(result[:error]).to eq "amount is greater than balance"
      end
    end

    context 'if the loan is not found' do
      it 'responds with a 404' do
        post :add_payment, params: { id: 10000 }
        expect(response).to have_http_status(:not_found)
      end
    end
  end

  describe '#show_payment' do
    let(:loan) { Loan.create!(funded_amount: 100.0, outstanding_balance: 100.0) }
    let(:payment) {Payment.create!(amount: 50.0, loan_id: loan.id)}

    context 'if the payment is found' do
      it 'responds with a 200' do
        get :show_payment, params: { id: loan.id, payment_id: payment.id }
        expect(response).to have_http_status(:ok)
      end
    end

    context 'if the payment is not found' do
      it 'responds with a 404' do
        get :show_payment, params: { id: loan.id, payment_id: 10000 }
        expect(response).to have_http_status(:not_found)
      end
    end
  end

  describe '#show_payments' do
    let(:payment) {Payment.new(amount: 50.0)}
    let(:loan) { Loan.create!(funded_amount: 100.0, outstanding_balance: 100.0, payments: [payment]) }

    it 'if loan is found' do
      get :show_payments, params: { id: loan.id }
      expect(response).to have_http_status(:ok)
    end

    it 'if loan is not found' do
      get :show_payments, params: { id: 10000 }
      expect(response).to have_http_status(:not_found)
    end
  end
end
