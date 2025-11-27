class Wall < Component
  include AbsorbentBehavior

  attr_writer :w, :h

  def initialize(data)
    super(data)

    @w, @h = data[:w], data[:h]

    @type = :rect
  end

  def rect
    {
      x: @pos.x, y: @pos.y,
      w: @w, h: @h,
      angle: @angle,
      anchor_x: 0.5, anchor_y: 0.5,
      angle_anchor_x: 0.5, angle_anchor_y: 0.5,
    }
  end

  def sprite
    {
      **rect,
      path: :solid,
      **BLACK.to_h,
    }
  end

  # Resizes the wall so that one corner follows the mouse while the opposite
  # corner stays fixed.
  def apply_resize(corner_index, mouse_pos)
    corners = Geometry.rotated_rect_corners(rect)

    # Determine the opposite corner which will remain fixed.
    opp = corners[(corner_index + 2) % 4]

    # Convert the fixed and dragged corners into local space.
    opp_local  = Geometry.world_to_local(opp, rect)
    drag_local = Geometry.world_to_local(mouse_pos, rect)

    # Compute new width and height in local space.
    new_w = (drag_local.x - opp_local.x).abs
    new_h = (drag_local.y - opp_local.y).abs
    return if new_w < 2 || new_h < 2

    # Compute the new local center based on midpoint between corners.
    new_center_local = {
      x: (drag_local.x + opp_local.x) / 2,
      y: (drag_local.y + opp_local.y) / 2,
    }

    # Convert the new center back into world coordinates.
    new_center = Geometry.local_to_world(new_center_local, rect)

    @pos = new_center
    @w = new_w
    @h = new_h
  end
end
