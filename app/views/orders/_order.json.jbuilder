json.extract! order, :id, :shop_id, :amount, :transaction_id, :key, :description, :order_id, :phone, :email, :signature, :status, :ip, :created_at, :updated_at
json.url order_url(order, format: :json)
