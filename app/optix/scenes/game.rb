class OptixGame
  def game_init
    @components = [
      Emitter.new(pos: { x: 200, y: 200 }, angle: 0, color: RED),
      Mirror.new(pos: { x: 1000, y: 270 }, angle: 70),
      Mirror.new(pos: { x: 800, y: 200 }, angle: 10),
      Receiver.new(pos: { x: 1100, y: 200 }, angle: 180, color: RED),
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
      # Stop beam from hitting the same object twice
      next if beam.last_hit == object

      intersection = case object.type
      when :flat
        Geometry.line_intersect(object.line, beam.ray)
      when :square
        beam_intersect_rotated_rect(beam, object.rect, object.angle)
      end

      if intersection
        t = Geometry.distance_squared(beam.start, intersection)
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

  def beam_intersect_rotated_rect(beam, rect, angle)
    lx, ly = beam.start.x, beam.start.y
    dx, dy = beam.dx, beam.dy

    cx, cy = rect.x, rect.y
    w, h = rect.w, rect.h
    ang = angle.to_radians

    cos_a = Math.cos(ang)
    sin_a = Math.sin(ang)

    # Translate so rect center is origin
    lx -= cx
    ly -= cy

    # Unrotate the ray by -angle:
    # Rotate point
    un_lx = lx * cos_a + ly * sin_a
    un_ly = -lx * sin_a + ly * cos_a
    # Rotate direction
    un_dx = dx * cos_a + dy * sin_a
    un_dy = -dx * sin_a + dy * cos_a

    # Ray–AABB intersection (slab method):
    tmin = -Float::INFINITY
    tmax = Float::INFINITY
    # Axis-aligned half extents
    hw = w / 2.0
    hh = h / 2.0
    # X slabs
    if un_dx.abs < 1e-9
      return nil if un_lx < -hw || un_lx > hw
    else
      tx1 = (-hw - un_lx) / un_dx
      tx2 = (hw - un_lx) / un_dx
      tmin = [tmin, [tx1, tx2].min].max
      tmax = [tmax, [tx1, tx2].max].min
    end
    # Y slabs
    if un_dy.abs < 1e-9
      return nil if un_ly < -hh || un_ly > hh
    else
      ty1 = (-hh - un_ly) / un_dy
      ty2 = (hh - un_ly) / un_dy
      tmin = [tmin, [ty1, ty2].min].max
      tmax = [tmax, [ty1, ty2].max].min
    end

    return nil if tmax < 0 || tmin > tmax

    # The first intersection going forward is tmin if it's >= 0
    t = tmin >= 0 ? tmin : tmax
    return nil if t < 0

    # Intersection in unrotated space
    ix = un_lx + un_dx * t
    iy = un_ly + un_dy * t

    # Rotate back into world space to get the coordinates
    # of the intersection
    {
      x: ix * cos_a - iy * sin_a + cx,
      y: ix * sin_a + iy * cos_a + cy,
    }
  end
end
