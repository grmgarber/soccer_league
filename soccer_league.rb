# Read results of soccer games from a file (ggarber/sample-input.txt)
# and display the team standings.
# Run it as follows:
# ruby -e "require './soccer_league.rb'; SoccerLeague.process"
class SoccerLeague
  GAME_RESULT_REGEX = /\A(.+)\s(\d+)\,\s(.+)\s(\d+)\Z/
  WIN_POINTS = 3
  DRAW_POINTS = 1
  PT_SINGULAR = 'pt'.freeze
  PT_PLURAL = 'pts'.freeze
  DEFAULT_INPUT_FILE_SPEC = './grmgarber/sample-input.txt'.freeze

  attr_reader :standings # hash of TeamName => NbrOfPoints

  def initialize
    @standings = {}
  end

  def self.process
    new.process_games
  end

  def process_games(game_results_file_spec = DEFAULT_INPUT_FILE_SPEC)
    read_data(game_results_file_spec)
    display_standings
  end

  private

  def read_data(game_results_file_spec)
    IO.foreach(game_results_file_spec) { |line| record_game_result(line) }
  rescue StandardError => exc
    puts "Error processing input data file #{game_results_file_spec}: #{exc}"
  end

  def record_game_result(game_result)
    team1, score1, team2, score2 = *game_result.scan(GAME_RESULT_REGEX).first
    score1 = score1.to_i
    score2 = score2.to_i
    if score1 > score2 then record_win(won: team1, lost: team2)
    elsif score1 < score2 then record_win(won: team2, lost: team1)
    else
      record_draw(team1)
      record_draw(team2)
    end
  end

  def record_win(won:, lost:)
    standings[won] = standings[won].to_i + WIN_POINTS
    standings[lost] = standings[lost].to_i
  end

  def record_draw(team)
    standings[team] = standings[team].to_i + DRAW_POINTS
  end

  def display_standings
    teams_grouped_by_points.inject(1) do |place, group|
      group.last.sort_by(&:first).each do |team_points|
        puts "#{place}. #{team_points.first}, #{points_wording(group.first)}"
      end
      place + group.last.size
    end
  end

  # return tiers of teams grouped by the nbr of points acquired in all games
  def teams_grouped_by_points
    standings.each_pair.group_by(&:last).sort { |a, b| b.first <=> a.first }
  end

  def points_wording(nbr_of_points)
    "#{nbr_of_points} #{nbr_of_points == 1 ? PT_SINGULAR : PT_PLURAL}"
  end
end
