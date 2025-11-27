class Filter < Component
  include FlatShape

  def initialize(data)
    super(data)

    @movable = true
    @color = data[:color]
  end

  def on_light_hit(beam, point, depth)
    [
      Beam.new(
        start: point,
        angle: beam.angle,
        color: beam.color.filter(@color),
        depth: depth,
        last_hit: self,
      )
    ]
  end

  def sprite
    set_line
    {
      **line,
      **@color.to_h,
    }
  end
end
