require 'open-uri'
require 'json'

class GamesController < ApplicationController
  def new
    @start_time = Time.now
    @letters = generate_letters
  end

  def generate_letters
    letters = []
    10.times do
      letters <<  ('A'..'Z').to_a[rand(26)]
    end
    letters
  end

  def score
    @end_time = Time.now
    @attempt = params[:attempt]
    @result = run_game(params[:attempt], params[:letters], Time.parse(params[:start_time]), @end_time)
    file = Net::HTTP.get_response(URI.parse("https://wagon-dictionary.herokuapp.com/#{params[:attempt]}"))
    @hsh = JSON.parse(file.body)
    if @hsh["found"] && included?(@attempt, params[:letters])
      score_and_message(@attempt, params[:letters], @time)
    end
  end

  def run_game(attempt, letters, start_time, end_time)
    result = { time: end_time - start_time }
    result[:score], result[:message] = score_and_message(attempt, letters, result[:time])
    result
  end

  def included?(attempt, letters)
    the_letters = letters.chars
    attempt.chars.each do |letter|
      if the_letters.include? (letter)
        the_letters.delete_at(the_letters.index(letter))
      end
    end
  end




  def score_and_message(attempt, letters, time)
    if included?(attempt.upcase, letters)
      score = get_score(attempt, time)
      [score, "Congratulations"]
    else
      [0, "no"]
    end
  end

  def get_score(attempt, start_time)
    attempt.size
  end


end
