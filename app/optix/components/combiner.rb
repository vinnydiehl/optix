class Combiner < Component
  include AbsorbentBehavior
  include SquareShape

  def initialize(data)
    super(data)

    reset
  end

  def reset
    @colors = []
  end

  def on_light_hit(beam, point, depth)
    if point.side == :back
      @colors << beam.color
    end

    super(beam, point, depth)
  end

  def compile
    if @colors.any?
      Beam.new(start: @pos, angle: @angle, color: @colors.inject(:+), last_hit: self)
    end
  end

  def sprite
    {
      **rect,
      path: "sprites/triangle/black.png",
    }
  end
end
