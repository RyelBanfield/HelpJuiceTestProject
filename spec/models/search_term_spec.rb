# frozen_string_literal: true

require 'rails_helper'

RSpec.describe SearchTerm, type: :model do
  describe 'methods' do
    # Create a recent search term for testing
    let(:recent_search_term) { create(:search_term, term: 'recent term') }

    # Test for the 'consolidate_partial_terms' method
    describe 'consolidate_partial_terms' do
      it 'consolidates partial terms by removing older search terms' do
        # Create older search terms with partial matches
        older_search_term1 = create(:search_term, term: 'hello')
        older_search_term2 = create(:search_term, term: 'hello world')

        # Create a recent search term
        recent_search_term = create(:search_term, term: 'hello world how are you')

        # Call the method to consolidate partial terms
        SearchTerm.new.consolidate_partial_terms

        # Expect older search terms with partial matches to be removed
        expect(SearchTerm.exists?(older_search_term1.id)).to be_falsey
        expect(SearchTerm.exists?(older_search_term2.id)).to be_falsey

        # Expect recent search term to remain unchanged
        expect(recent_search_term.term).to eq('hello world how are you')
      end
    end

    # Test for the '.suggestions' method
    describe '.suggestions' do
      it 'returns search suggestions with case-insensitive partial matches' do
        # Create a search term and check if suggestions are returned with the correct case-insensitive match
        create(:search_term, term: 'search term')
        suggestions = SearchTerm.suggestions('TERM'.dup) # Use 'dup' to create a non-frozen copy

        expect(suggestions.count).to eq(1)
        expect(suggestions.first.term).to eq('search term')
      end

      it 'returns nil when the term is blank' do
        # Check if nil is returned when the search term is blank
        expect(SearchTerm.suggestions(''.dup)).to be_nil # Use 'dup' to create a non-frozen copy
      end
    end

    # Test for the '.your_most_recent_terms' method
    describe '.your_most_recent_terms' do
      it 'returns the user\'s most recent search terms' do
        # Create search terms with a specific IP address and check if the order is based on creation time
        ip_address = '127.0.0.1'
        create_list(:search_term, 5, ip_address: ip_address)
        recent_terms = SearchTerm.your_most_recent_terms(ip_address)

        expect(recent_terms.count).to be <= (5)
        expect(recent_terms.first.created_at).to be > recent_terms.last.created_at
      end
    end

    # Test for the '.your_most_frequent_terms' method
    describe '.your_most_frequent_terms' do
      it 'returns the user\'s most frequent search terms' do
        # Create frequent search terms with a specific IP address and check if the order is based on search term count
        ip_address = '127.0.0.1'
        create_list(:search_term, 5, ip_address: ip_address, count: 2)
        frequent_terms = SearchTerm.your_most_frequent_terms(ip_address)

        expect(frequent_terms.count).to be <= (5)
        expect(frequent_terms.first.count).to be >= frequent_terms.last.count
      end
    end

    # Test for the '.most_frequent_terms' method
    describe '.most_frequent_terms' do
      it 'returns the overall most frequent search terms' do
        # Create overall frequent search terms and check if the order is based on search term count
        create_list(:search_term, 5, count: 2)
        frequent_terms = SearchTerm.most_frequent_terms

        expect(frequent_terms.count).to be <= (5)
        expect(frequent_terms.first.count).to be >= frequent_terms.last.count
      end
    end

    # Test for the '.term_similarity' method
    describe '.term_similarity' do
      it 'calculates Levenshtein distance between two search terms' do
        # Check if the result of term similarity calculation is of type Integer
        similarity = SearchTerm.term_similarity('term1', 'term2')
        expect(similarity).to be_a(Integer)
      end
    end

    # Test for the '.log_search' method
    describe '.log_search' do
      it 'logs a user\'s search query' do
        # Log a new search term, find it in the database, and check if it has a count of 1
        ip_address = '127.0.0.1'
        SearchTerm.log_search('new term', ip_address)
        search_term = SearchTerm.find_by(term: 'new term', ip_address: ip_address)

        expect(search_term).to be_present
        expect(search_term.count).to eq(1)
      end
    end
  end
end
