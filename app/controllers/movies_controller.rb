class MoviesController < ApplicationController
  require 'themoviedb-api'

  before_action :initialize_session
  api_key = 
  def index
    begin
      @latest_movie = fetch_upcoming_movies
      @movies = search_movies(params[:search]) if params[:search].present?
    rescue StandardError => e
      Rails.logger.error("An error occurred while fetching or searching movies: #{e.message}")
      @latest_movie = []
      @movies = []
    end
  end

  def show
    begin
      movie_id = params[:id]
      @movie_details = fetch_movie_details(movie_id)
    rescue StandardError => e
      Rails.logger.error("An error occurred while fetching movie details: #{e.message}")
      @movie_details = {}
    end
  end

  def add_to_favorites
    begin
      movie_id = params[:id]
      session[:fav_ids] << movie_id
      Rails.logger.info("#{session[:fav_ids]}")
      redirect_to movies_path, notice: 'Movie added to favorites!'
    rescue StandardError => e
      Rails.logger.error("An error occurred while adding movie to favorites: #{e.message}")
      redirect_to movies_path, alert: 'Error adding movie to favorites. Please try again.'
    end
  end

  private

  def initialize_session
    session[:fav_ids] ||= []
  end

  def fetch_upcoming_movies
    response = HTTParty.get("https://api.themoviedb.org/3/movie/upcoming?api_key=#{api_key}")
    JSON.parse(response.body)['results']
  end

  def search_movies(query)
    encoded_query = URI.encode_www_form_component(query)
    response = HTTParty.get("https://api.themoviedb.org/3/search/movie?api_key=#{api_key}&query=#{encoded_query}")
    JSON.parse(response.body)['results']
  end

  def fetch_movie_details(movie_id)
    response = HTTParty.get("https://api.themoviedb.org/3/movie/#{movie_id}?api_key=#{api_key}")
    JSON.parse(response.body)
  end

  def api_key
    ENV['TMDB_API_KEY']
  end
end

