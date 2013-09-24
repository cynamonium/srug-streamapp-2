class OrdersController < ApplicationController
  before_action :set_order, only: [:show, :edit, :update, :destroy]

  include ActionController::Live

  # GET /orders
  def index
    @orders = Order.all
  end

  # GET /orders/1
  def show
  end

  # GET /orders/new
  def new
    @order = Order.new
  end

  # GET /orders/1/edit
  def edit
  end

  # POST /orders
  def create
    @order = Order.new(order_params)

    if @order.save
      redirect_to @order, notice: 'Order was successfully created.'
    else
      render action: 'new'
    end
  end

  # PATCH/PUT /orders/1
  def update
    if @order.update(order_params)
       $redis.publish('order.update', @order.name + " updated")
      redirect_to @order, notice: 'Order was successfully updated.'
    else
      render action: 'edit'
    end
  end

  # DELETE /orders/1
  def destroy
    @order.destroy
    redirect_to orders_url, notice: 'Order was successfully destroyed.'
  end

  def stream_new
    response.headers['Content-Type'] = 'text/event-stream'
    redis = Redis.new
    redis.subscribe('order.update') do |on|
      on.message do |event, data|
        response.stream.write("event: update\n")
        response.stream.write("data: #{data }\n\n")
      end
    end
    render nothing: true
    
    rescue IOError
      logger.info "Stream closed"
    ensure
      redis.quit
      response.stream.close 
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_order
      @order = Order.find(params[:id])
    end

    # Only allow a trusted parameter "white list" through.
    def order_params
      params.require(:order).permit(:name, :description)
    end
end
