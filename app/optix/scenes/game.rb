class OptixGame
  def game_init
    @emitters = [
      Emitter.new(pos: { x: 200, y: 200 }, angle: 0, color: RED)
    ]
    @components = [
      Mirror.new(pos: { x: 1000, y: 270 }, angle: 70),
      Mirror.new(pos: { x: 800, y: 200 }, angle: 10),
    ]
  end

  def game_tick
    propagate_beams
  end

  def propagate_beams
    @beams = []

    # Emit initial beams
    queue = @emitters.map(&:beam)

    # BFS-like propagation
    until queue.empty?
      beam = queue.shift
      next if beam.depth >= MAX_DEPTH

      if (hit = first_intersection(beam))
        # Initial beam
        beam.set_endpoint(hit.point)
        @beams << beam

        # Resultant beam(s)
        queue += hit.component.on_light_hit(beam, hit.point, beam.depth + 1)
      else
        # Beam goes offscreen
        beam.set_endpoint(:offscreen)
        @beams << beam
      end
    end
  end

  def first_intersection(beam)
    closest = nil
    closest_t = Float::INFINITY

    @components.each do |component|
      c_line = component.line
      cx, cy = component.pos.x, component.pos.y

      # quick check: is object in front of beam start? (dot product)
      vx, vy = cx - beam.start.x, cy - beam.start.y
      t = vx * beam.dx + vy * beam.dy
      next if t <= 0 # object is behind the ray origin

      if (intersection = Geometry.line_intersect(component.line, beam.ray))
        # we use t as the measure of distance along the ray to the object's closest approach
        if t < closest_t
          closest_t = t
          closest = {
            component: component,
            point: intersection,
          }
        end
      end
    end

    closest
  end
end
