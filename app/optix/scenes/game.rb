class OptixGame
  def game_init
    @emitters = [
      Emitter.new(pos: { x: 200, y: 200 }, angle: 30, color: RED)
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

      # DEV: Nothing is happening here right now, but collision with
      # an object will go something like this
      hit = false #first_intersection(beam)
      if hit
        new_segments, spawn = process_interaction(hit)
        @beams += new_segments
        queue += spawn
      else
        # For now we're just sending beams offscreen
        beam.set_endpoint(:offscreen)
        @beams << beam
      end
    end
  end
end
