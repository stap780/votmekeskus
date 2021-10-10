class Order < ApplicationRecord

validates :order_id , uniqueness: true



end
