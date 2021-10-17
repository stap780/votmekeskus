class Role < ApplicationRecord
has_many :users

#Роли создаём или через rake db:seed или через консоль Role.create(name: 'registered'), Role.create(name: 'manager'), Role.create(name: 'admin')


end
