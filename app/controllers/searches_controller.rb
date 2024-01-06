# frozen_string_literal: true

# Controller responsible for handling search-related actions and analytics.
class SearchesController < ApplicationController
  # Display search analytics on the index page.
  def index
    # Get the user's IP address from the request.
    ip_address = request.ip

    # Retrieve the most frequent search terms of all users.
    @most_frequent_terms = SearchTerm.most_frequent_terms

    # Retrieve the most frequent search terms for the current user.
    @your_most_frequent_terms = SearchTerm.your_most_frequent_terms(ip_address)

    # Retrieve the most recent search terms for the current user.
    @your_most_recent_terms = SearchTerm.your_most_recent_terms(ip_address)
  end

  # Log a user's search query and return a success JSON response.
  def create
    # Extract, downcase, and strip the search term from the parameters.
    term = params[:term].downcase.strip

    # Get the user's IP address from the request.
    ip_address = request.ip

    # Log the search query along with the user's IP address.
    SearchTerm.log_search(term, ip_address)

    # Respond with a JSON indicating success.
    render json: { status: 'success' }
  end

  # Provide search suggestions for a given term in JSON format.
  def suggestions
    # Extract, downcase, and strip the search term from the parameters.
    term = params[:term].downcase.strip

    # Retrieve similar search terms as suggestions.
    similar_terms = SearchTerm.suggestions(term)

    # Respond with a JSON containing search suggestions.
    render json: { suggestions: similar_terms }
  end
end
