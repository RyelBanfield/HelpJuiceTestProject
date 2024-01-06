# frozen_string_literal: true

class SearchesController < ApplicationController
  def index
    ip_address = request.ip

    @most_frequent_terms = SearchTerm.most_frequent_terms
    @your_most_frequent_terms = SearchTerm.your_most_frequent_terms(ip_address)
    @your_most_recent_terms = SearchTerm.your_most_recent_terms(ip_address)
  end

  def create
    term = params[:term].downcase.strip
    ip_address = request.ip

    SearchTerm.log_search(term, ip_address)
    render json: { status: 'success' }
  end

  def suggestions
    term = params[:term].downcase.strip
    similar_terms = SearchTerm.suggestions(term)
    render json: { suggestions: similar_terms }
  end
end
