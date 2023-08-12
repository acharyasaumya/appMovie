class FavoritesController < ApplicationController
  def index
    @favorite_movies = fetch_favorite_movies
  rescue StandardError => e
    Rails.logger.error("An error occurred while fetching favorite movies: #{e.message}")
    @favorite_movies = [] # Set an empty array if an error occurs
  end

  private

  def fetch_favorite_movies
    Rails.logger.info("Fetch fav was called")
    favorite_movie_ids = @fav_ids
    Rails.logger.info("#{favorite_movie_ids}")
    return [] if favorite_movie_ids.blank?

    api_key = 'd7143e44b3214786f97ab592245abff3'
    movie_ids_string = favorite_movie_ids.join(',')
    api_url = "https://api.themoviedb.org/3/movie/#{movie_ids_string}?api_key=#{api_key}"

    response = HTTParty.get(api_url)
    handle_api_response(response)
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
end