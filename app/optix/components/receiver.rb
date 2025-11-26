class Receiver < Component
  include AbsorbentBehavior
  include SquareShape

  def initialize(data)
    super(data)

    @color = data[:color]
    reset
  end

  def reset
    deactivate
  end

  def on_light_hit(beam, point, depth)
    if beam.color == @color && point.side == :front
      activate
    end

    super(beam, point, depth)
  end

  def sprite
    color = activated? ? {} : @color

    {
      **rect,
      path: "sprites/square/white.png",
      **color.to_h,
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
