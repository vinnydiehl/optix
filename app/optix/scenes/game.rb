class OptixGame
  def game_init
    @components = [
      Wall.new(pos: { x: 400, y: 300 }, w: 20, h: 500, angle: 20),
      Emitter.new(pos: { x: 200, y: 200 }, angle: 0, color: RED),
      Emitter.new(pos: { x: 200, y: 500 }, angle: 270, color: BLUE),
      Emitter.new(pos: { x: 300, y: 500 }, angle: 270, color: GREEN),
      Emitter.new(pos: { x: 200, y: 150 }, angle: 0, color: MAGENTA),
      Mirror.new(pos: { x: 50, y: 50 }, angle: 45),
      Mirror.new(pos: { x: 50, y: 100 }, angle: 45),
      Mirror.new(pos: { x: 50, y: 150 }, angle: 45),
      Mirror.new(pos: { x: 50, y: 200 }, angle: 45),
      Combiner.new(pos: { x: 50, y: 250 }, angle: 0),
      Splitter.new(pos: { x: 50, y: 300 }, angle: 0),
      Filter.new(pos: { x: 50, y: 350 }, angle: 90, color: RED),
      Receiver.new(pos: { x: 1100, y: 150 }, angle: 180, color: RED),
      Receiver.new(pos: { x: 600, y: 350 }, angle: 90, color: BLUE),
      Receiver.new(pos: { x: 800, y: 250 }, angle: 180, color: MAGENTA),
    ]

    @emitters = @components.grep(Emitter)
    @receivers = @components.grep(Receiver)
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
    @compilers.each(&:reset)
    # Track last known compiler output color
    last_colors = @compilers.map { |c| [c, nil] }.to_h

    # I'm not entirely sure that this is necessary, but I was fighting
    # an infinite loop implementing this, so I'm leaving it for now, with
    # a warning if it gets triggered
    iteration = 0
    max_iterations = 20
    loop do
      iteration += 1
      if iteration > max_iterations
        puts "Warning: compiler propagation hit iteration cap #{max_iterations}"
        break
      end

      @beams = []
      # Need to reset receivers at the beginning of each pass so they don't
      # activate due to an old compiler beam which was superceded in a later pass
      @receivers.each(&:reset)

      # First, propagate emitters
      propagate_set(@emitters.map(&:beam))

      # Then compile & propagate compiler outputs; the compilers haven't been
      # reset, so if beams from the emitters hit them, they'll get added
      # to the compiler's @colors
      new_compiler_beams = @compilers.flat_map { |c| c.compile }.compact

      # Break if no compilers are active and emitters produced everything
      break if new_compiler_beams.empty? && last_colors.values.all?(&:nil?)

      # Now propagate compiler-generated beams
      propagate_set(new_compiler_beams)

      # Detect if any compiler’s output color changed, and track the last
      # color if so
      changed = @compilers.any? do |comp|
        color = comp.compile&.first&.color
        last_colors[comp].tap { last_colors[comp] = color } != color
      end

      # If no compiler's output color changed, propagation has stabilized
      break unless changed
    end
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
        Geometry.beam_intersect_rotated_rect(beam, component.rect)
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
