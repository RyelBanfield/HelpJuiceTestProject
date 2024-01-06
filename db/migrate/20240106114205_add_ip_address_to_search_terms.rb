class AddIpAddressToSearchTerms < ActiveRecord::Migration[7.1]
  def change
    add_column :search_terms, :ip_address, :string
  end
end
