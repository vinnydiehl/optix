module FilterBehavior
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
end
