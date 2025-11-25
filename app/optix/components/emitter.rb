class Emitter < Component
  include AbsorbentBehavior

  def initialize(data)
    super(data)
    @color = data[:color]
    @type = :square
  end

  def beam
    Beam.new(start: @pos, angle: @angle, color: @color, last_hit: self)
  end

  def rect
    {
      x: @pos.x, y: @pos.y,
      w: COMPONENT_SIZE, h: COMPONENT_SIZE,
    }
  end

  def sprite
    {
      **rect,
      angle: @angle,
      anchor_x: 0.5, anchor_y: 0.5,
      angle_anchor_x: 0.5, angle_anchor_y: 0.5,
      path: "sprites/circle/white.png",
      **@color,
    }
  end
end
