class Emitter < Component
  include AbsorbentBehavior
  include SquareShape

  def initialize(data)
    super(data)

    @color = data[:color]
  end

  def beam
    Beam.new(start: @pos, angle: @angle, color: @color, last_hit: self)
  end

  def sprite
    {
      **rect,
      path: "sprites/circle/white.png",
      **@color.to_h,
    }
  end
end
