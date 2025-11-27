class OptixGame
  def handle_mouse_input
    handle_lmb
    handle_rmb
    handle_scroll
  end

  def handle_lmb
    if @mouse.key_down.left
      @component_held = component_under_mouse
    end

    if @component_held
      if @mouse.key_held.left
        @component_held.pos = @mouse.position.slice(:x, :y)
      elsif @mouse.key_up.left
        @component_held = nil
      end
    end
  end

  def handle_rmb
    if @mouse.key_down.right && (c = component_under_mouse).is_a?(Wall)
      @resize_wall = c
      @resize_corner_index = Geometry.closest_rect_corner_index(
        @resize_wall,
        @mouse.position,
      )
    end

    if @resize_wall
      if @mouse.key_held.right
        @resize_wall.apply_resize(@resize_corner_index, @mouse.position)
      elsif @mouse.key_up.right
        @resize_wall = nil
        @resize_corner_index = nil
      end
    end
  end

  # Scroll to change the angle of a component
  def handle_scroll
    return unless (d = @mouse.wheel&.y)

    # Hold shift to rotate slower
    d /= 10 if @kb.key_held.shift

    if (c = @component_held || component_under_mouse)
      c.angle += d
    end
  end

  # Returns the movable component under the mouse, or nil.
  def component_under_mouse
    @movable_components.find do |c|
      case c.type
      when :rect
        Geometry.point_in_rotated_rect?(@mouse.position, c.rect)
      else
        Geometry.intersect_circle?(Geometry.rect_to_circle(@mouse.rect), c.hitbox)
      end
    end
  end
end
