class ProjectState
  include Comparable

  def initialize(state)
    @state = state
  end

  def to_s
    @state
  end

  def inspect
    @state.to_sym
  end

  def <=>(state)
    states_order = [[:draft, 0],
                    [:in_analysis, 1],
                    [:rejected, 2], [:approved, 2],
                    [:online, 3],
                    [:waiting_funds, 4],
                    [:failed, 5], [:successful, 5]]
    states_order.assoc(@state.to_sym)[1] <=> states_order.assoc(state.to_sym)[1]
  end

end
