# app/controllers/charges_controller.rb
class ChargesController < ApplicationController
    def create
      @order = Order.find(params[:order_id])
      
      customer = Stripe::Customer.create(
        email: params[:stripeEmail],
        source: params[:stripeToken]
      )
  
      charge = Stripe::Charge.create(
        customer: customer.id,
        amount: (@order.total_price * 100).to_i, # Amount in cents
        description: 'Rails Stripe customer',
        currency: 'usd'
      )
  
      @order.update(payment_status: 'paid', stripe_charge_id: charge.id)
      redirect_to order_path(@order), notice: 'Payment successful'
    rescue Stripe::CardError => e
      flash[:error] = e.message
      redirect_to new_charge_path
    end
  end
  