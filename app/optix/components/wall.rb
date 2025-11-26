class Wall < Component
  include AbsorbentBehavior

  def initialize(data)
    super(data)

    @w, @h = data[:w], data[:h]

    @type = :rect
  end

  def rect
    {
      x: @pos.x, y: @pos.y,
      w: @w, h: @h,
      angle: @angle,
      anchor_x: 0.5, anchor_y: 0.5,
      angle_anchor_x: 0.5, angle_anchor_y: 0.5,
    }
  end

  def sprite
    {
      **rect,
      path: :solid,
      **BLACK.to_h,
    }
  end
end
