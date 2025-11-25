class Emitter < Component
  include AbsorbentBehavior

  def initialize(data)
    super(data)

    @type = :rect
    @color = data[:color]
  end

  def beam
    Beam.new(start: @pos, angle: @angle, color: @color, last_hit: self)
  end

  def rect
    {
      x: @pos.x, y: @pos.y,
      w: COMPONENT_SIZE, h: COMPONENT_SIZE,
      angle: @angle,
      anchor_x: 0.5, anchor_y: 0.5,
      angle_anchor_x: 0.5, angle_anchor_y: 0.5,
    }
  end

  def sprite
    {
      **rect,
      path: "sprites/circle/white.png",
      **@color,
    }
  end
end
