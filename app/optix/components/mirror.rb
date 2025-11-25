class Mirror < Component
  include ReflectiveBehavior

  attr_reader :line

  def initialize(data)
    super(data)

    @type = :flat
    @movable = true
    set_line
  end

  def sprite
    set_line
    {
      **line,
      **WHITE,
    }
  end

  private

  def set_line
    offset = pos.dup
    offset.x += COMPONENT_SIZE / 2
    p1 = Geometry.rotate_point(offset, angle, **pos)
    p2 = Geometry.rotate_point(offset, angle + 180, **pos)

    @line = { x: p1.x, y: p1.y, x2: p2.x, y2: p2.y }
  end
end
