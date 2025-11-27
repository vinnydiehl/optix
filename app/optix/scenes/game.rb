class OptixGame
  def game_init
    @components = [
      # Wall.new(pos: { x: 400, y: 300 }, w: 20, h: 500, angle: 20),
      Emitter.new(pos: { x: 200, y: 200 }, angle: 0, color: RED),
      Emitter.new(pos: { x: 200, y: 500 }, angle: 270, color: BLUE),
      Emitter.new(pos: { x: 300, y: 500 }, angle: 270, color: GREEN),
      Emitter.new(pos: { x: 200, y: 150 }, angle: 0, color: MAGENTA),
      Mirror.new(pos: { x: 50, y: 50 }, angle: 45),
      Mirror.new(pos: { x: 50, y: 100 }, angle: 45),
      Mirror.new(pos: { x: 50, y: 150 }, angle: 45),
      Mirror.new(pos: { x: 50, y: 200 }, angle: 45),
      Combiner.new(pos: { x: 50, y: 250 }, angle: 0),
      Filter.new(pos: { x: 50, y: 300 }, angle: 90, color: RED),
      Receiver.new(pos: { x: 1100, y: 150 }, angle: 180, color: RED),
      Receiver.new(pos: { x: 600, y: 350 }, angle: 90, color: BLUE),
      Receiver.new(pos: { x: 800, y: 250 }, angle: 180, color: MAGENTA),
    ]

    @emitters = @components.grep(Emitter)
    @receivers = @components.grep(Receiver)
    @resettables = @components.select { |c| c.respond_to?(:reset) }
    @compilers = @components.select { |c| c.respond_to?(:compile) }

    # All components are movable for now
    # @movable_components = @components.select(&:movable?)
    @movable_components = @components
  end

  def game_tick
    handle_mouse_input
    propagate_beams
  end

  def propagate_beams
    # Any components that can be reset should be, so each frame
    # propagates the beams from square one
    @resettables.each(&:reset)

    @beams = []

    # Emit initial beams
    propagate_set(@emitters.map(&:beam))
    # Second pass for compiled beams
    propagate_set(@compilers.map(&:compile).compact)
  end

  def propagate_set(queue)
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
