# encoding: utf-8

module SportDb
  module Model

#############################################################
# collect depreciated or methods for future removal here
# - keep for now for compatibility (for old code)

class Game

  ### getter/setters for deprecated attribs (score3,4,5,6) n national
  def score3()   score1et  end
  def score4()   score2et  end
  def score5()   score1p   end
  def score6()   score2p   end

  def score3=(value)   self.score1et = value  end
  def score4=(value)   self.score2et = value  end
  def score5=(value)   self.score1p = value   end
  def score6=(value)   self.score2p = value   end

  def self.create_knockouts_from_ary!( games, round )
    Game.create_from_ary!( games, round, true )
  end

  def self.create_from_ary!( games, round, knockout=false )

### fix:
#  replace knockout=false with more attribs
#    see create teams and than merge attribs

    games.each_with_index do |values,index|
      
      value_pos      = index+1
      value_scores   = []
      value_teams    = []
      value_knockout = knockout
      value_play_at  = round.start_at  # if no date present use it from round
      value_group    = nil
      
      ### lets you use arguments in any order
      ##   makes pos optional (if not present counting from 1 to n)
      
      values.each do |value|
        if value.kind_of? Numeric
          value_pos = value
        elsif value.kind_of?( TrueClass ) || value.kind_of?( FalseClass )
          value_knockout = value
        elsif value.kind_of? Array
          value_scores = value
        elsif value.kind_of? Team
          value_teams << value
        elsif value.kind_of? Group
          value_group = value
        elsif value.kind_of?( Date ) || value.kind_of?( Time ) || value.kind_of?( DateTime )
          value_play_at = value
        else
          # issue an error/warning here
        end
      end

      Game.create!(
        :round     => round,
        :pos       => value_pos,
        :team1     => value_teams[0],
        :score1    => value_scores[0],
        :score2    => value_scores[1],
        :score1et  => value_scores[2],
        :score2et  => value_scores[3],
        :score1p   => value_scores[4],
        :score2p   => value_scores[5],
        :team2     => value_teams[1],
        :play_at   => value_play_at,
        :group     => value_group,     # Note: group is optional (may be null/nil)
        :knockout  => value_knockout )
    end # each games
  end

  def self.create_pairs_from_ary_for_group!( pairs, group )
    
    pairs.each do |pair|
      game1_attribs = {
        :round     =>pair[0][5],
        :pos       =>pair[0][0],
        :team1     =>pair[0][1],
        :score1    =>pair[0][2][0],
        :score2    =>pair[0][2][1],
        :team2     =>pair[0][3],
        :play_at   =>pair[0][4],
        :group     =>group }

      game2_attribs = {
        :round     =>pair[1][5],
        :pos       =>pair[1][0],
        :team1     =>pair[1][1],
        :score1    =>pair[1][2][0],
        :score2    =>pair[1][2][1],
        :team2     =>pair[1][3],
        :play_at   =>pair[1][4],
        :group     =>group }
  
      game1 = Game.create!( game1_attribs )
      game2 = Game.create!( game2_attribs )

      # linkup games
      game1.next_game_id = game2.id
      game1.save!
  
      game2.prev_game_id = game1.id
      game2.save!
    end # each pair
  end

  def self.create_knockout_pairs_from_ary!( pairs, round1, round2 )
    
    pairs.each do |pair|
      game1_attribs = {
        :round     =>round1,
        :pos       =>pair[0][0],
        :team1     =>pair[0][1],
        :score1    =>pair[0][2][0],
        :score2    =>pair[0][2][1],
        :team2     =>pair[0][3],
        :play_at   =>pair[0][4] }

      game2_attribs = {
        :round     =>round2,
        :pos       =>pair[1][0],
        :team1     =>pair[1][1],
        :score1    =>pair[1][2][0],
        :score2    =>pair[1][2][1],
        :score1et  =>pair[1][2][2],
        :score2et  =>pair[1][2][3],
        :score1p   =>pair[1][2][4],
        :score1p   =>pair[1][2][5],
        :team2     =>pair[1][3],
        :play_at   =>pair[1][4],
        :knockout  =>true }
  
      game1 = Game.create!( game1_attribs )
      game2 = Game.create!( game2_attribs )

      # linkup games
      game1.next_game_id = game2.id
      game1.save!
  
      game2.prev_game_id = game1.id
      game2.save!
    end # each pair
  end

end # class Game


  end # module Model
end # module SportDb
