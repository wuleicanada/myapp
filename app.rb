require 'rubygems'
require "sinatra"
require "sinatra/activerecord"
require 'sinatra/form_helpers'
require 'active_record'
require 'active_record/connection_adapters/jdbc_adapter'
require 'sqljdbc4.jar'


config_dev = {
	:adapter => "jdbc", 
	:driver => "com.microsoft.sqlserver.jdbc.SQLServerDriver",  
	:url => "jdbc:sqlserver://172.26.6.70:1433;databaseName=ccn_list", 
	:username => "ccndbo", 
	:password => "monday"
}

config_jboss = {
	:adapter => "jdbc", 
	:driver => "com.microsoft.sqlserver.jdbc.SQLServerDriver",  
	:jndi => "ccn_list_production"
}

ActiveRecord::Base.establish_connection(defined?($servlet_context) ? config_jboss : config_dev)

class User < ActiveRecord::Base
	validates :consent, acceptance: true, presence: true
	validates :firstname, presence: true
	validates :lastname, presence: true
	validates :email, presence: true, format: { with: /\A[^@]+@([^@\.]+\.)+[^@\.]+\z/ }
end


helpers do
	def h(text)
		Rack::Utils.escape_html(text)
	end
end


get "/users" do
	@users = User.take(10)
	erb :"users/index"
end
 
 
get "/users/:id" do
	@user = User.find(params[:id])
	erb :"users/show"
end

put "/users/:id" do
	@user = User.find(params[:id])
	if @user.update_attributes(params[:user])
		redirect '/users'
	else
		erb :"users/show"
	end
end
 

