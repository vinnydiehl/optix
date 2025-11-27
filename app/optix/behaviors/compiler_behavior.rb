module CompilerBehavior
  def initialize(data)
    super(data)

    reset
  end

  def reset
    @colors = []
  end

  def on_light_hit(beam, point, depth)
    # Only accept beams from the "back" side
    @colors << beam.color if point.side == :back

    # Don't emit a beam here
    []
  end

  def color_sum
    @colors.inject(:+)
  end

  def active?
    @colors.any?
  end
end
