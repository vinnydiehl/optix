class OptixGame
  # Returns whether not +point+ exists within +rect+. +rect+ must
  # contain an :angle and be anchored in the center.
  def point_in_rotated_rect?(point, rect)
    cx, cy = rect.x, rect.y
    w, h = rect.w, rect.h
    ang = rect.angle.to_radians

    # Translate point into rect-centered coordinates
    dx = point.x - cx
    dy = point.y - cy

    # Unrotate the point by -angle
    cos_a = Math.cos(-ang)
    sin_a = Math.sin(-ang)

    rx = dx * cos_a - dy * sin_a
    ry = dx * sin_a + dy * cos_a

    # Check bounds in local space
    half_w = w / 2.0
    half_h = h / 2.0

    rx.abs <= half_w && ry.abs <= half_h
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

    # Determine which side was hit:
    # Normal in unrotated space
    hit_normal_local =
      if ix.abs > iy.abs
        if ix > 0
          # Right side ("front")
          [1, 0]
        else
          # Left side ("back")
          [-1, 0]
        end
      else
        if iy > 0
          # Bottom side ("right")
          [0, 1]
        else
          # Top side ("left")
          [0, -1]
        end
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
    {
      x: ix * cos_a - iy * sin_a + cx,
      y: ix * sin_a + iy * cos_a + cy,
      side: side,
    }
  end
end
