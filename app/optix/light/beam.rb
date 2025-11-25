class Beam
  attr_reader :start, :angle, :color, :depth, :ray, :dx, :dy, :last_hit

  def initialize(start:, angle:, color:, depth: 1, last_hit: nil)
    @start, @angle, @color, @depth, @last_hit =
      start, angle, color, depth, last_hit

    # Beam direction unit vector
    ang_rad = angle.to_radians
    @dx = Math.cos(ang_rad)
    @dy = Math.sin(ang_rad)

    # Define a ray that extendes well beyond the screen (for
    # calculating intersections)
    max_dist = Math.sqrt(($grid.w ** 2) + ($grid.h ** 2)) * 2
    ex = start.x + dx * max_dist
    ey = start.y + dy * max_dist
    @ray = { x: start.x, y: start.y, x2: ex, y2: ey }
  end

  def sprite
    x1, x2, y1, y2 = @start.x, @end.x, @start.y, @end.y

    dx = x2 - x1
    dy = y2 - y1
    length = Math.sqrt((dx * dx) + (dy * dy))
    angle = Math.atan2(dy, dx).to_radians

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
