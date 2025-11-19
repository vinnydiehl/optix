class Beam
  attr_reader :depth

  def initialize(start:, angle:, color:, depth: 1)
    @start, @angle, @color, @depth = start, angle, color, depth
  end

  def primitive
    x1, x2, y1, y2 = @start.x, @end.x, @start.y, @end.y

    dx = x2 - x1
    dy = y2 - y1
    length = Math.sqrt((dx * dx) + (dy * dy))
    angle = Math.atan2(dy, dx) * 180 / Math::PI

    {
      x: x1, y: y1,
      w: length, h: BEAM_THICKNESS,
      angle: @angle,
      anchor_x: 0, anchor_y: 0.5,
      angle_anchor_x: 0, angle_anchor_y: 0.5,
      **@color,
      path: :solid,
    }
  end

  def set_endpoint(pos)
    if pos == :offscreen
      offscreen_point = @start.dup.tap { |p| p.x = $grid.w * 4 }
      @end = Geometry.rotate_point(offscreen_point, @angle)
    else
      @end = pos
    end
  end
end
