# frozen_string_literal: true

# Model representing a search term with associated analytics.
class SearchTerm < ApplicationRecord
  # Validation: Ensure the presence of the search term.
  validates :term, presence: true

  # Callback: Consolidate partial search terms after each save.
  after_save :consolidate_partial_terms

  # Consolidate partial search terms based on the most recent search.
  def consolidate_partial_terms
    # Fetch the most recent search term.
    recent_search_term = SearchTerm.order(created_at: :desc).first

    # Exit early if the recent search term is nil or has no term.
    return unless recent_search_term&.term.present?

    # Split the recent search term into words and reject blanks.
    recent_words = recent_search_term.term.split(/\s+/).reject(&:blank?)

    # Retrieve older search terms excluding the most recent one.
    older_search_terms = SearchTerm.where.not(id: recent_search_term.id)

    # Iterate through older search terms to find and remove partial matches.
    older_search_terms.each do |older_search_term|
      next unless older_search_term.term.present?

      # Split older search term into words and reject blanks.
      older_words = older_search_term.term.split(/\s+/).reject(&:blank?)

      next if older_words.empty?

      # Remove older search term if all its words are prefixes of recent search term words.
      if older_words.all? { |older_word| recent_words.any? { |recent_word| recent_word.start_with?(older_word) } }
        older_search_term.destroy
      end
    end
  end

  # Class method: Retrieve search suggestions based on a given term.
  def self.suggestions(term)
    term.downcase!
    return if term.blank?

    # Search for terms with case-insensitive partial matches.
    where('LOWER(term) LIKE ?', "%#{term}%")
  end

  # Class method: Retrieve the user's most recent search terms.
  def self.your_most_recent_terms(ip_address)
    where(ip_address: ip_address).order(created_at: :desc).limit(5)
  end

  # Class method: Retrieve the user's most frequent search terms.
  def self.your_most_frequent_terms(ip_address)
    where(ip_address: ip_address).order(count: :desc).limit(5)
  end

  # Class method: Retrieve the overall most frequent search terms.
  def self.most_frequent_terms
    # Cache the most frequent terms for 15 seconds.
    Rails.cache.fetch('most_frequent_terms', expires_in: 15.seconds) do
      order(count: :desc).limit(5)
    end
  end

  # Class method: Calculate the Levenshtein distance between two search terms.
  def self.term_similarity(term1, term2)
    Levenshtein.distance(term1.downcase, term2.downcase)
  end

  # Class method: Log a user's search query, updating or creating a new record.
  def self.log_search(term, ip_address)
    # Fetch the most recent search term for the user.
    recent_search = where(ip_address: ip_address).order(created_at: :desc).first

    # Update the recent search term if within the time threshold and similar enough.
    if recent_search && (Time.current - recent_search.created_at) <= 1.minute && term_similarity(recent_search.term,
                                                                                                 term) <= 5
      recent_search.update(term: term, count: recent_search.count + 1)
    else
      # Create or find the search term and handle duplicates.
      search_term = where(term: term, ip_address: ip_address).first_or_initialize

      if search_term.new_record?
        existing_term = SearchTerm.where('term LIKE ? AND ip_address = ?', "#{term}%", ip_address).first
        search_term.destroy if existing_term
      else
        search_term.increment!(:count)
      end

      search_term.save
    end
  end
end
