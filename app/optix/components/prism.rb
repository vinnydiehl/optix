class Prism < Component
  attr_reader :lines

  def initialize(data)
    super(data)

    @type = :triangle
    @side_length = COMPONENT_SIZE

    set_lines
    reset
  end

  def reset
    @through_beams = []
  end

  def on_light_hit(beam, entry_point, depth)
    # A prism refracts light directly across to the opposite side of the triangle
    # along the angle of the side which the beam would not have ever intersected.
    # To do this, first we need to find the line of the triangle which the beam
    # would miss if it passed all the way through
    missed = Geometry.beam_intersect_rotated_triangle_missed_line(beam, @lines)

    # If light hits a vertex perfectly, don't refract
    return [] unless missed

    # Find the angle of the missed line, normalized in the direction that the
    # beam is coming from
    missed_endpoints = [
      { x: missed.x, y: missed.y },
      { x: missed.x2, y: missed.y2 },
    ].sort_by { |ep| Geometry.distance_squared(ep, entry_point) }
    missed_angle = missed_endpoints[0].angle_to(missed_endpoints[1])

    # Now we need to find the exit point. We'll do this by casting a ray larger than
    # the prism from the entry point all the way through
    offset = entry_point.dup.tap { |p| p.x += @side_length }
    through_ray_endpoint = Geometry.rotate_point(offset, missed_angle, entry_point)
    through_ray = {
      x: entry_point.x, y: entry_point.y,
      x2: through_ray_endpoint.x, y2: through_ray_endpoint.y,
    }
    # Then determine where that ray would intersect the line on the opposite side
    far_line = Geometry.beam_intersect_rotated_triangle_far_line(beam, @lines)
    exit_point = Geometry.line_intersect(far_line, through_ray)

    # Make a little beam shining through the prism along this angle from the
    # entry point to the end point, and save it for rendering (this supports
    # multiple beams)
    @through_beams << Beam.new(
      start: entry_point,
      angle: missed_angle,
      color: beam.color,
    ).tap { |b| b.set_endpoint(exit_point) }

    # Calculate exit angle based on the difference between the entry angle
    # and the angle of the missed edge
    exit_angle = ((2 * missed_angle) - beam.angle) % 360

    # Spawn a new beam or beams from the exit point
    if beam.color == WHITE
      # Determine if the prism is upside-down (in which case the output
      # colors will be flipped)
      orientation =
        if missed_endpoints.first.y < entry_point.y
          1
        else
          -1
        end

      {
        RED => PRISM_SPREAD * orientation,
        GREEN => 0,
        BLUE => -PRISM_SPREAD * orientation,
      }.map do |color, angle_offset|
        Beam.new(
          start: exit_point,
          angle: exit_angle + angle_offset,
          color: color,
          depth: beam.depth + 1,
          last_hit: self,
        )
      end
    else
      [
        Beam.new(
          start: exit_point,
          angle: exit_angle,
          color: beam.color,
          depth: beam.depth + 1,
          last_hit: self,
        ),
      ]
    end
  end

  def sprite
    set_lines
    [
      @through_beams.map(&:sprite),
      @lines.map { |l| l.merge(**WHITE.to_h) },
    ]
  end

  private

  def set_lines
    @lines = Geometry.rotated_triangle_lines(@pos, @side_length, @angle)
  end
end
