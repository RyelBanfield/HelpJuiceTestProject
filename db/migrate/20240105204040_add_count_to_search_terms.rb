class AddCountToSearchTerms < ActiveRecord::Migration[7.1]
  def change
    add_column :search_terms, :count, :integer
  end
end
