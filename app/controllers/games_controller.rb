require 'json'
require 'open-uri'

class GamesController < ApplicationController
  def new
    @letters = []
    10.times { @letters << ('A'..'Z').to_a.sample }
    @letters
  end

  def score
    @grid = params[:letters]
    @guess = params[:guess]
    @result = 0
    if word_validation(@guess, @grid) && word_english(@guess)
      @result = 3
      session[:points].nil? ? session[:points] = @guess.size : session[:points] += @guess.size
    elsif word_validation(@guess, @grid)
      @result = 2
    else
      @result = 1
    end
    @result
  end
  # result
  # 1 => the word doesn't match the grid => LOSE
  # 2 => the word matches the grid but it's not an English word => LOSE
  # 3 => the word matches the grid and it's an English word => WIN

  def word_validation(attempt, grid)
    word = attempt.upcase.chars.to_h { |letter| [letter, attempt.upcase.chars.count(letter)] }
    alphabet = ('A'..'Z').to_h { |letter| [letter, grid.chars.count(letter)] }
    word.all? { |letter, number| number <= alphabet[letter] }
  end

  def word_english(attempt)
    url = "https://wagon-dictionary.herokuapp.com/#{attempt}"
    in_dictionary = JSON.parse(URI.open(url).read)
    in_dictionary['found']
  end
end
