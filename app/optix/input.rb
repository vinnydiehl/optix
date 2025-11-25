class OptixGame
  def handle_mouse_input
    handle_lmb
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

  # Scroll to change the angle of a component
  def handle_scroll
    return unless (d = @mouse.wheel&.y)
    if (c = @component_held || component_under_mouse)
      c.angle += d / 10
    end
  end

  # Returns the movable component under the mouse, or nil.
  def component_under_mouse
    @movable_components.find do |c|
      Geometry.intersect_circle?(Geometry.rect_to_circle(@mouse.rect), c.hitbox)
    end
  end
end
