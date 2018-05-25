require 'pry'
require 'json'
require 'net/http'
require 'csv'

class AccountsController < ApplicationController
    before_action :get_account
    skip_before_action :get_account, only: [:new, :create, :index, :upload]
    BASE_URI = "https://api.constantcontact.com/v2"

    def index
        @manager = Manager.find(2)
        @accounts = @manager.accounts.all.sort_by do |account|
            [ to_day_of_week(account.delivery_day), to_start_time(account.delivery_window) ]
        end
    end

    def new
        @account = Account.new
    end

    def create
        if Account.create(account_params)
            redirect_to accounts_path
        end
    end

    def edit
    end

    def update
        @account.update(account_params)
        ctct_list_id = find_list(@account.email_list)
        contacts = retrieve_contacts(ctct_list_id)
        contacts.each do |contact|
            contact_from_ctct = retrieve_contact(contact["id"])
            updated_contact = update_contact(@account, contact_from_ctct)
            post_updated_contact(updated_contact)
        end
        redirect_to accounts_path
    end

    def upload
        CSV.foreach(params[:accounts].path, headers: true) do |account|
            new_account = Account.create(market: account[0], delivery_day: account[2], delivery_window: account[3], 
                company_name: account[4], email_list: account[5], location: account[6])
            new_account.manager = Manager.find_by(:name => account[1])
            binding.pry
            new_account.save
          end
          redirect_to accounts_path
      
    end

    private

    def get_account
        @account = Account.find(params[:id])
    end

    def account_params
        params.require(:account).permit(
            :market,
            :company_name, 
            :email_list,
            :delivery_day,
            :delivery_window,
            :location,
            :manager_id,
            )
    end


    def to_day_of_week(day)
        Date.parse(day,"%w")
    end

    def to_start_time(window)
        start_hour = window.match(/\d{1,2}/)[0]
        if start_hour.to_i < 6
            return start_hour.to_i + 12
        else
            return start_hour.to_i
        end
    end

    def find_list(email_list)
        ctct_lists = JSON.parse(RestClient.get("#{BASE_URI}/lists?api_key=#{ENV['CONSTANTCONTACT_KEY']}", headers={"Authorization": "Bearer #{ENV['CONSTANTCONTACT_TOKEN']}"}))
        ctct_lists.each do |ctct_list|
            if ctct_list["name"] == email_list
                return ctct_list["id"]
            end
        end

    end

    def retrieve_contacts(ctct_list_id)
        # JSON.parse(RestClient.get("#{BASE_URI}/lists/#{ctct_list_id}/contacts?limit=50&api_key=#{ENV['CONSTANTCONTACT_KEY']}", headers={"Authorization": "Bearer #{ENV['CONSTANTCONTACT_TOKEN']}"}))
        resp = Faraday.get "#{BASE_URI}/lists/#{ctct_list_id}/contacts" do |req|
            req.params['api_key'] = ENV['CONSTANTCONTACT_KEY']
            req.headers['Authorization'] = "Bearer #{ENV['CONSTANTCONTACT_TOKEN']}"
        end
        body_hash = JSON.parse(resp.body)
        body_hash["results"]
    end

    def retrieve_contact(contact_id)
        # JSON.parse(RestClient.get("#{BASE_URI}/contacts/#{contact_id}?api_key=#{ENV['CONSTANTCONTACT_KEY']}", headers={"Authorization": "Bearer #{ENV['CONSTANTCONTACT_TOKEN']}"}))
        resp = Faraday.get "#{BASE_URI}/contacts/#{contact_id}" do |req|
            req.params['api_key'] = ENV['CONSTANTCONTACT_KEY']
            req.headers['Authorization'] = "Bearer #{ENV['CONSTANTCONTACT_TOKEN']}"
        end
        body_hash = JSON.parse(resp.body)
    end

    def update_contact(account, contact)
        if contact["custom_fields"].length > 0
            contact["custom_fields"][0]["value"] = "#{account.manager.name}, #{account.manager.contact_info}" 
            contact["custom_fields"][1]["value"] = "#{account.delivery_day}, #{account.delivery_window}, #{account.location}"
        else
            contact["custom_fields"] << {"name": "CustomField1", "label": "CustomField1", "value": "#{account.manager.name}, #{account.manager.contact_info}"}
            contact["custom_fields"] << {"name": "CustomField2", "label": "CustomField2", "value": "#{account.delivery_day}, #{account.delivery_window}, #{account.location}"}
        end
        contact
    end

    def post_updated_contact(contact) 
        contact_id = contact["id"]
        resp = Faraday.put "#{BASE_URI}/contacts/#{contact_id}" do |req|
            req.params['action_by'] = "ACTION_BY_OWNER"
            req.params['api_key'] = ENV['CONSTANTCONTACT_KEY']
            req.headers['Content-Type'] = 'application/json'
            req.headers['Authorization'] = "Bearer #{ENV['CONSTANTCONTACT_TOKEN']}"
            req.body = contact.to_json
        end
        binding.pry


    end

end
