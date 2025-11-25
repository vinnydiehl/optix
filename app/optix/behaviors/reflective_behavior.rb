module ReflectiveBehavior
  def on_light_hit(beam, point, depth)
    normal = (@angle + 180) % 360
    reflect_angle = (2 * normal - beam.angle) % 360

    [
      Beam.new(
        start: point,
        angle: reflect_angle,
        color: beam.color,
        depth: depth,
        last_hit: self,
      )
    ]
  end
end
