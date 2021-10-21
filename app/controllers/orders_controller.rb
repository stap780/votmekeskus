class OrdersController < ApplicationController
  before_action :authenticate_user! , except: [:checkout, :paysuccess, :status, :payment]
  before_action :authenticate_user_role!, except: [:checkout, :paysuccess, :status, :payment]
  before_action :set_order, only: %i[ show edit update destroy ]

  # GET /orders or /orders.json
  def index
    @search = Order.ransack(params[:q])
    @search.sorts = 'id asc' if @search.sorts.empty?
    @orders = @search.result.paginate(page: params[:page], per_page: 30)
  end

  # GET /orders/1 or /orders/1.json
  def show
  end

  # GET /orders/new
  def new
    @order = Order.new
  end

  # GET /orders/1/edit
  def edit
  end

  # POST /orders or /orders.json
  def create
    @order = Order.new(order_params)

    respond_to do |format|
      if @order.save
        format.html { redirect_to @order, notice: "Order was successfully created." }
        format.json { render :show, status: :created, location: @order }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @order.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /orders/1 or /orders/1.json
  def update
    respond_to do |format|
      if @order.update(order_params)
        format.html { redirect_to @order, notice: "Order was successfully updated." }
        format.json { render :show, status: :ok, location: @order }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @order.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /orders/1 or /orders/1.json
  def destroy
    @order.destroy
    respond_to do |format|
      format.html { redirect_to orders_url, notice: "Order was successfully destroyed." }
      format.json { head :no_content }
    end
  end


  def checkout
    test = Bank.first.app_type
    bank_shop_id = test ? Bank.first.bank_shop_id_test : Bank.first.bank_shop_id
    payment_url = test ? "https://payment.test.maksekeskus.ee/pay/1/link.html" : "https://payment.maksekeskus.ee/pay/1/link.html"

    return_url_data = Bank.first.app_address+"/orders/payment&rerturn_method=GET"
    cancel_url_data = Bank.first.app_address+"/orders/payment&cancel_method=GET"
    notification_url_data= Bank.first.app_address+"/orders/payment&notification_method=GET"

    if params[:key].present?
      order_data = {
        order_id: params[:order_id],
        shop_id: params[:shop_id],
        amount: params[:amount],
        transaction_id: params[:transaction_id],
        key: params[:key],
        description: params[:description],
        phone: params[:phone],
        email: params[:email],
        signature: params[:signature],
        ip: params[:order_json].to_s
      }
      puts "order_data - "+order_data.to_s
      order_json =  JSON.parse(params[:order_json])
      search_language = order_json['fields_values'].select{|field| field if field['handle'] == 'language' }
      language = search_language.present? ? search_language[0]['value'] : 'et'
      check_order = Order.find_by_order_id(order_data[:order_id])
      if check_order.present?
        check_order.update(order_data)
        order = check_order
      else
        order = Order.create(order_data)
      end

      puts order.status.to_s
      if order.status != 'PAID'
          url = payment_url+"?shop="+bank_shop_id+"&amount="+order.amount.to_s+"&reference="+order.order_id.to_s+"&country=ee&locale="+language+"&return_url="+return_url_data+"&cancel_url="+cancel_url_data+"&notification_url="+notification_url_data
          redirect_to url
      end
    end

  end

  def payment
    puts "Параметры payfail"
    payment_data = JSON.parse( params["json"])

    if payment_data["status"] == "CANCELLED"
      test = Bank.first.app_type
      search_order = test ? payment_data["paymentId"] : payment_data["reference"]

      order = Order.find_by_order_id(search_order)
      order.update!(status: 'CANCELLED')
      puts "payment_data CANCELLED - "+order.id.to_s
      password = Bank.first.ins_password
      order_json = order.ip.to_s
      paid = "0"
      signature = Digest::MD5.hexdigest(order.shop_id.to_s+";"+order.amount.to_f.to_s+";"+order.transaction_id.to_s+";"+order.key.to_s+";"+paid+";"+password)
      # signature2 = Digest::MD5.hexdigest(order.shop_id.to_s+";"+order.amount.to_f.to_s+";"+order.transaction_id.to_s+";"+order.key.to_s+";"+order.description.to_s+";"+order.order_id.to_s+";"+order.phone.to_s+";"+order.email.to_s+";"+order.ip.to_s+";"+password)
      data = {
        'paid': "0",
        'amount': order.amount.to_f,
        'key': order.key,
        'transaction_id': order.transaction_id,
        'signature': signature,
        'shop_id': order.shop_id
        }
      url = Bank.first.ins_fail_url

      RestClient.post( url, data.to_json, {:content_type => 'application/json', accept: :json}) { |response, request, result, &block|
            case response.code
            when 200
              redirect_to url
            when 302
             # puts response
             redirect_to url.split('/payments').first+'/orders/'+order.key
            else
              response.return!(&block)
            end
            }
    end

    if payment_data["status"] == "PAID"
      test = Bank.first.app_type
      search_order = test ? payment_data["paymentId"] : payment_data["reference"]

      order = Order.find_by_order_id(search_order)
      order.update!(status: 'PAID')
      puts "payment_data PAID - "+order.id.to_s
      password = Bank.first.ins_password
      order_json = order.ip.to_s
      paid = "1"
      signature = Digest::MD5.hexdigest(order.shop_id.to_s+";"+order.amount.to_f.to_s+";"+order.transaction_id.to_s+";"+order.key.to_s+";"+paid+";"+password)
      # signature2 = Digest::MD5.hexdigest(order.shop_id.to_s+";"+order.amount.to_f.to_s+";"+order.transaction_id.to_s+";"+order.key.to_s+";"+order.description.to_s+";"+order.order_id.to_s+";"+order.phone.to_s+";"+order.email.to_s+";"+order.ip.to_s+";"+password)
      data = {
        'paid': paid,
        'amount': order.amount.to_f,
        'key': order.key,
        'transaction_id': order.transaction_id,
        'signature': signature,
        'shop_id': order.shop_id
        }

      url = Bank.first.ins_success_url
      puts data.to_json.to_s
      RestClient.post( url, data.to_json, {:content_type => 'application/json', accept: :json}) { |response, request, result, &block|
            case response.code
            when 200
              redirect_to url
            when 302
              redirect_to url.split('/payments').first+'/orders/'+order.key
            else
              response.return!(&block)
            end
            }
    end

    if payment_data["status"] == "COMPLETED"
      test = Bank.first.app_type
      search_order = test ? payment_data["paymentId"] : payment_data["reference"]

      order = Order.find_by_order_id(search_order)
      order.update!(status: 'PAID')
      puts "payment_data PAID - "+order.id.to_s
      password = Bank.first.ins_password
      order_json = order.ip.to_s
      paid = "1"
      signature = Digest::MD5.hexdigest(order.shop_id.to_s+";"+order.amount.to_f.to_s+";"+order.transaction_id.to_s+";"+order.key.to_s+";"+paid+";"+password)
      # signature2 = Digest::MD5.hexdigest(order.shop_id.to_s+";"+order.amount.to_f.to_s+";"+order.transaction_id.to_s+";"+order.key.to_s+";"+order.description.to_s+";"+order.order_id.to_s+";"+order.phone.to_s+";"+order.email.to_s+";"+order.ip.to_s+";"+password)
      data = {
        'paid': paid,
        'amount': order.amount.to_f,
        'key': order.key,
        'transaction_id': order.transaction_id,
        'signature': signature,
        'shop_id': order.shop_id
        }

      url = Bank.first.ins_success_url
      RestClient.post( url, data.to_json, {:content_type => 'application/json', accept: :json}) { |response, request, result, &block|
            case response.code
            when 200
              redirect_to url
            when 302
              redirect_to url.split('/payments').first+'/orders/'+order.key
            else
              response.return!(&block)
            end
            }
    end

    if payment_data["status"] == "PENDING"
      test = Bank.first.app_type
      search_order = test ? payment_data["paymentId"] : payment_data["reference"]

      order = Order.find_by_order_id(search_order)
      order.update!(status: 'PENDING')
      puts "payment_data PENDING - "+order.id.to_s
      @pending_order_id = order.id
    end
  end

  def status
    order = Order.find(params[:id])
    if order.status == "PENDING"
      message =  {status: order.status}
    end
    if order.status == "PAID"

      password = Bank.first.ins_password
      paid = "1"
      signature = Digest::MD5.hexdigest(order.shop_id.to_s+";"+order.amount.to_f.to_s+";"+order.transaction_id.to_s+";"+order.key.to_s+";"+paid+";"+password)
      data = {
        'paid': "1",
        'amount': order.amount.to_f,
        'key': order.key,
        'transaction_id': order.transaction_id,
        'signature': signature,
        'shop_id': order.shop_id
        }

      url = Bank.first.ins_success_url
      RestClient.post( url, data.to_json, {:content_type => 'application/json', accept: :json}) { |response, request, result, &block|
            case response.code
            when 200
              puts "отправили данные"
              message = {status: order.status, redirect_url: url}
              #redirect_to url
            when 302
              message = {status: order.status, redirect_url: url.split('/payments').first+'orders/'+order.key}
            else
              response.return!(&block)
            end
            }

    end

    render json: message

  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_order
      @order = Order.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def order_params
      params.require(:order).permit(:shop_id, :amount, :transaction_id, :key, :description, :order_id, :phone, :email, :signature, :status, :ip)
    end
end
