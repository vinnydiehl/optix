class Receiver < OpticalObject
  include AbsorbentBehavior

  def initialize(data)
    super(data)

    @type = :square
    @color = data[:color]
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
      path: "sprites/square/black.png",
    }
  end
end
