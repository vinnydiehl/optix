module SquareShape
  def initialize(data)
    super(data)
    @type = :rect
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
end
