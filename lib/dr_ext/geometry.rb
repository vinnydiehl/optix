module Geometry
  extend self

  # Returns whether the +point+ exists within +rect+.
  # +rect+ must contain an :angle and be anchored in the center.
  def point_in_rotated_rect?(point, rect)
    local = world_to_local(point, rect)

    half_w = rect.w / 2
    half_h = rect.h / 2

    local.x.abs <= half_w && local.y.abs <= half_h
  end

  # If +beam+ intersects the rotated rect, return a Hash with the
  # point of intersection, and the side that the beam hit.
  # +rect+ must contain an :angle and be anchored in the center.
  def beam_intersect_rotated_rect(beam, rect)
    lx, ly = beam.start.x, beam.start.y
    dx, dy = beam.dx, beam.dy

    cx, cy = rect.x, rect.y
    w, h = rect.w, rect.h
    ang = rect.angle.to_radians

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
    hw = w / 2
    hh = h / 2
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

    # Determine which side was hit:
    # Normal in unrotated space
    hit_normal_local =
      if ix.abs > iy.abs
        # Right or left normal ("front" or "back")
        ix > 0 ? [1, 0] : [-1, 0]
      else
        # Bottom or top normal ("right" or "left")
        iy > 0 ? [0, 1] : [0, -1]
      end
    # Rotate normal back into world space
    hit_normal_world = {
      x: hit_normal_local[0] * cos_a - hit_normal_local[1] * sin_a,
      y: hit_normal_local[0] * sin_a + hit_normal_local[1] * cos_a,
    }
    # Normalize
    len = Math.sqrt(hit_normal_world[:x]**2 + hit_normal_world[:y]**2)
    nx = hit_normal_world[:x] / len
    ny = hit_normal_world[:y] / len
    # Rect's "front" normal (angle == 0 -> (1,0))
    rect_front = {
      x: Math.cos(ang),
      y: Math.sin(ang),
    }
    # Left and right normals
    rect_right = {
      x: Math.cos(ang - (Math::PI / 2)),
      y: Math.sin(ang - (Math::PI / 2)),
    }
    rect_left = {
      x: Math.cos(ang + (Math::PI / 2)),
      y: Math.sin(ang + (Math::PI / 2)),
    }
    # Back normal
    rect_back = {
      x: -rect_front[:x],
      y: -rect_front[:y],
    }
    # Dot products
    dot = {
      front: nx * rect_front[:x] + ny * rect_front[:y],
      back: nx * rect_back[:x] + ny * rect_back[:y],
      left: nx * rect_left[:x] + ny * rect_left[:y],
      right: nx * rect_right[:x] + ny * rect_right[:y],
    }
    # Pick the side with the strongest alignment
    side = dot.max_by { |_, v| v }.first

    # Rotate back into world space to get the coordinates
    # of the intersection
    local_to_world({ x: ix, y: iy }, rect).merge(side: side)
  end

  # Returns the four corners of a rotated rectangle in world space.
  def rotated_rect_corners(rect)
    cx, cy = rect.x, rect.y
    hw, hh = rect.w / 2, rect.h / 2
    ang = rect[:angle].to_radians
    cos_a = Math.cos(ang)
    sin_a = Math.sin(ang)

    [[-hw, -hh], [hw, -hh], [hw, hh], [-hw, hh]].map do |lx, ly|
      {
        x: cx + lx * cos_a - ly * sin_a,
        y: cy + lx * sin_a + ly * cos_a,
      }
    end
  end

  # Returns the index of the corner closest to the given point.
  def closest_rect_corner_index(wall, point)
    corners = rotated_rect_corners(wall.rect)
    corners.each_with_index.min_by { |c, _i| distance_squared(c, point) }[1]
  end

  # Converts a point from world coordinates into rectangle-local coordinates.
  # Expects rect to have :x, :y, and :angle.
  def world_to_local(point, rect)
    cx, cy = rect.x, rect.y
    ang = rect.angle.to_radians
    cos_a = Math.cos(ang)
    sin_a = Math.sin(ang)

    dx = point.x - cx
    dy = point.y - cy

    {
      x: dx * cos_a + dy * sin_a,
      y: -dx * sin_a + dy * cos_a,
    }
  end

  # Converts a point from rectangle-local coordinates back to world coordinates.
  def local_to_world(local_point, rect)
    cx, cy = rect.x, rect.y
    ang = rect.angle.to_radians
    cos_a = Math.cos(ang)
    sin_a = Math.sin(ang)

    {
      x: cx + local_point.x * cos_a - local_point.y * sin_a,
      y: cy + local_point.x * sin_a + local_point.y * cos_a,
    }
  end

  def rotated_triangle_vertices(pos, side_length, angle)
    # Offset the center by the distance to a vertex
    offset = pos.dup.tap do |p|
      p.x += side_length / Math.sqrt(3)
    end

    # Rotate the offset by the angles to each vertex (+ rotation)
    [-30, 90, 210].map do |rotate_amount|
      Geometry.rotate_point(offset, rotate_amount + angle, **pos)
    end
  end

  def rotated_triangle_lines(pos, side_length, angle)
    verts = rotated_triangle_vertices(pos, side_length, angle)

    {
      verts[0] => verts[1],
      verts[1] => verts[2],
      verts[2] => verts[0],
    }.map do |v1, v2|
      {
        x: v1.x, y: v1.y,
        x2: v2.x, y2: v2.y,
      }
    end
  end

  def beam_intersect_rotated_triangle(beam, lines)
    intersections = lines.map do |line|
      line_intersect(beam.ray, line)
    end.compact

    return if intersections.empty?

    intersections.min_by { |pt| distance_squared(pt, beam.start) }
  end

  def beam_intersect_rotated_triangle_missed_line(beam, lines)
    intersections = lines.find do |line|
      !line_intersect(beam.ray, line)
    end
  end

  def beam_intersect_rotated_triangle_far_line(beam, lines)
    intersections = lines.sort_by do |line|
      int = line_intersect(beam.ray, line)
      next -Float::INFINITY unless int
      distance_squared(beam.start, int)
    end.last
  end
end
