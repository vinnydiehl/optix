class Combiner < Component
  include CompilerBehavior
  include SquareShape

  def initialize(data)
    super(data)

    @movable = true
  end

  def compile
    if active?
      [
        Beam.new(
          start: @pos,
          angle: @angle,
          color: color_sum,
          last_hit: self,
        )
      ]
    end
  end

  def sprite
    {
      **rect,
      path: "sprites/triangle/black.png",
    }
  end
end
