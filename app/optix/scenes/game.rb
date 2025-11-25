class OptixGame
  def game_init
    @components = [
      Emitter.new(pos: { x: 200, y: 200 }, angle: 0, color: RED),
      Mirror.new(pos: { x: 1000, y: 270 }, angle: 70),
      Mirror.new(pos: { x: 800, y: 200 }, angle: 10),
    ]

    @emitters, @optical_objects = @components.partition { |c| c.is_a?(Emitter) }

    # All components are movable for now
    # @movable_components = @components.select(&:movable?)
    @movable_components = @components
  end

  def game_tick
    handle_mouse_input
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
        queue += hit.object.on_light_hit(beam, hit.point, beam.depth + 1)
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

    @optical_objects.each do |object|
      c_line = object.line
      cx, cy = object.pos.x, object.pos.y

      # quick check: is object in front of beam start? (dot product)
      vx, vy = cx - beam.start.x, cy - beam.start.y
      t = vx * beam.dx + vy * beam.dy
      next if t <= 0 # object is behind the ray origin

      if (intersection = Geometry.line_intersect(object.line, beam.ray))
        # we use t as the measure of distance along the ray to the object's closest approach
        if t < closest_t
          closest_t = t
          closest = {
            object: object,
            point: intersection,
          }
        end
      end
    end

    closest
  end
end
