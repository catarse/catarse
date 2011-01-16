require 'sexy_pg_constraints'
class DeconstrainRewardsDescription < ActiveRecord::Migration
  def self.up
    deconstrain :rewards do |t|
      t.description :not_blank, :length_within
    end
  end

  def self.down
    constrain :rewards do |t|
      t.description :not_blank => true, :length_within => 1..140
    end
  end
end
