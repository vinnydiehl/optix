class Receiver < OpticalObject
  include AbsorbentBehavior

  def initialize(data)
    super(data)

    @type = :square
    @color = data[:color]
    @activated = false
  end

  def on_light_hit(beam, point, depth)
    if beam.color == @color && point.side == :front
      activate
    end

    super(beam, point, depth)
  end

  def rect
    {
      x: @pos.x, y: @pos.y,
      w: COMPONENT_SIZE, h: COMPONENT_SIZE,
    }
  end

  def sprite
    color = activated? ? {} : @color

    {
      **rect,
      angle: @angle,
      anchor_x: 0.5, anchor_y: 0.5,
      angle_anchor_x: 0.5, angle_anchor_y: 0.5,
      path: "sprites/square/white.png",
      **color,
    }
  end

  def activate
    @activated = true
  end

  def deactivate
    @activated = false
  end

  def activated?
    @activated
  end
end
