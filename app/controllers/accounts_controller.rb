require 'pry'
class AccountsController < ApplicationController
    before_action :get_account
    skip_before_action :get_account, only: [:new, :create, :index]

    def index
        @manager = Manager.find(1)
        @accounts = @manager.accounts.all.sort_by do |account|
            to_start_time(account.delivery_window)
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
        retrieve_contacts(ctct_list_id)

        redirect_to accounts_path
    end

    private

    def get_account
        @account = Account.find(params[:id])
    end

    def account_params
        params.require(:account).permit(
            :company_name, 
            :email_list,
            :delivery_day,
            :delivery_window,
            :location,
            :manager_id,
            )
    end

    def to_start_time(window)
        Time.parse(window.match(/\d+:\d{2}/)[0])
    end

    def find_list(email_list)
        ctct_lists = JSON.parse(RestClient.get("https://api.constantcontact.com/v2/lists?api_key=#{ENV['CONSTANTCONTACT_KEY']}", headers={"Authorization": "Bearer #{ENV['CONSTANTCONTACT_TOKEN']}"}))
        binding.pry
        ctct_lists.each do |ctct_list|
            if ctct_list["name"] == email_list
                return ctct_list["id"]
            end
        end

    end

    def retrieve_contacts(ctct_list_id)
        contacts = JSON.parse(RestClient.get("https://api.constantcontact.com/v2/lists/#{ctct_list_id}/contacts?limit=50&api_key=#{ENV['CONSTANTCONTACT_KEY']}", headers={"Authorization": "Bearer #{ENV['CONSTANTCONTACT_TOKEN']}"}))
        contacts["results"].each do |contact|
            binding.pry
            # if contact["custom_fields"].length > 0
                contact["custom_fields"].first["value"] = "Matt"
                contact["custom_fields"].last["value"] = "Monday, 9:30 to 9:50, Sick bay"
            # else
                #create the custom fields entries
            #end
        end
        binding.pry
    end

    def update_customers
    end
end
