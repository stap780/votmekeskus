source 'https://rubygems.org'
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

ruby '3.2.0'
gem "rails", "~> 7.0.5.1"

gem 'sass-rails', '~> 5.0'
gem 'uglifier', '>= 1.3.0'

gem 'jquery-rails'
gem 'jbuilder', '~> 2.5'
gem 'bootstrap', '~> 5.2.0'

gem 'devise'
gem 'high_voltage'
gem 'simple_form'
gem 'rest-client'
gem 'cocoon'
gem 'will_paginate', '~> 3.3'
gem 'ransack'
gem 'whenever', require: false
gem 'figaro'
gem "pg", "~> 1.1"
gem 'unicorn'
# gem 'puma'

gem 'bcrypt_pbkdf', '< 2.0', :require => false
gem 'ed25519', '~> 1.2', '>= 1.2.4'

group :development do
  gem 'capistrano-rails'
  gem 'capistrano-rvm'
  gem 'capistrano3-unicorn'
  gem 'capistrano-rails-console'

  gem 'web-console', '>= 3.3.0'
  gem 'listen', '~> 3.0.5'
  gem 'spring'
end

group :development, :test do
  gem 'byebug', platform: :mri
end
