# frozen_string_literal: true

class SearchTerm < ApplicationRecord
  validates :term, presence: true

  after_save :consolidate_partial_terms

  def consolidate_partial_terms
    recent_search_term = SearchTerm.order(created_at: :desc).first

    return unless recent_search_term&.term.present?

    recent_words = recent_search_term.term.split(/\s+/).reject(&:blank?)

    older_search_terms = SearchTerm.where.not(id: recent_search_term.id)

    older_search_terms.each do |older_search_term|
      next unless older_search_term.term.present?

      older_words = older_search_term.term.split(/\s+/).reject(&:blank?)

      next if older_words.empty?

      if older_words.all? { |older_word| recent_words.any? { |recent_word| recent_word.start_with?(older_word) } }
        older_search_term.destroy
      end
    end
  end

  def self.suggestions(term)
    term.downcase!
    return if term.blank?

    where('LOWER(term) LIKE ?', "%#{term}%")
  end

  def self.your_most_recent_terms(ip_address)
    where(ip_address: ip_address).order(created_at: :desc).limit(5)
  end

  def self.your_most_frequent_terms(ip_address)
    where(ip_address: ip_address).order(count: :desc).limit(5)
  end

  def self.most_frequent_terms
    Rails.cache.fetch('most_frequent_terms', expires_in: 15.seconds) do
      order(count: :desc).limit(5)
    end
  end

  def self.term_similarity(term1, term2)
    Levenshtein.distance(term1.downcase, term2.downcase)
  end

  def self.log_search(term, ip_address)
    recent_search = where(ip_address: ip_address).order(created_at: :desc).first

    if recent_search && (Time.current - recent_search.created_at) <= 1.minutes && term_similarity(recent_search.term,
                                                                                                  term) <= 5
      recent_search.update(term: term, count: recent_search.count + 1)
    else
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
