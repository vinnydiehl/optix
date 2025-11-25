class OptixGame
  def game_init
    @components = [
      Emitter.new(pos: { x: 200, y: 200 }, angle: 0, color: RED),
      Emitter.new(pos: { x: 200, y: 500 }, angle: 270, color: BLUE),
      Mirror.new(pos: { x: 1000, y: 270 }, angle: 70),
      Mirror.new(pos: { x: 800, y: 200 }, angle: 10),
      Receiver.new(pos: { x: 1100, y: 200 }, angle: 180, color: RED),
      Receiver.new(pos: { x: 600, y: 350 }, angle: 135, color: BLUE),
    ]

    @emitters = @components.grep(Emitter)
    @receivers = @components.grep(Receiver)

    # All components are movable for now
    # @movable_components = @components.select(&:movable?)
    @movable_components = @components
  end

  def game_tick
    handle_mouse_input
    propagate_beams
  end

  def propagate_beams
    # Deactivate all receivers, their activation is calculated on
    # a frame-by-frame basis
    @receivers.each(&:deactivate)

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
      # Stop beam from hitting the same component twice
      next if beam.last_hit == component

      intersection = case component.type
      when :flat
        Geometry.line_intersect(component.line, beam.ray)
      when :rect
        beam_intersect_rotated_rect(beam, component.rect)
      end

      if intersection
        t = Geometry.distance_squared(beam.start, intersection)
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
