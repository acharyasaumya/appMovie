class FavoritesController < ApplicationController
  def index
    @favorite_movies = fetch_favorite_movies
  rescue StandardError => e
    Rails.logger.error("An error occurred while fetching favorite movies: #{e.message}")
    @favorite_movies = [] # Set an empty array if an error occurs
  end

  private
  def fetch_favorite_movies
    Rails.logger.info("Fetch fav was called now")
    favorite_movie_ids = session[:fav_ids]
    Rails.logger.info("#{favorite_movie_ids}")
    return [] if favorite_movie_ids.blank?

    favorite_movies = []

    favorite_movie_ids.each do |movie_id|
      api_url = "https://api.themoviedb.org/3/movie/#{movie_id}?api_key=#{api_key}"

      response = HTTParty.get(api_url)
      movie_details = handle_api_response(response)
      favorite_movies << movie_details unless movie_details.empty?
    end

    favorite_movies
  end
  def handle_api_response(response)
    if response.success?
      JSON.parse(response.body)
    else
      Rails.logger.error("TMDb API error: Status code #{response.code}, Message: #{response.message}")
      [] # Return an empty array in case of API error
    end
  rescue JSON::ParserError => e
    Rails.logger.error("Error parsing TMDb API response: #{e.message}")
    [] # Return an empty array if JSON parsing fails
  end
  def api_key
    ENV['TMDB_API_KEY']
  end
end