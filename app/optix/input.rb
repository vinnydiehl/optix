class OptixGame
  def handle_mouse_input
    if @mouse.key_down.left
      @component_held = @movable_components.find do |c|
        Geometry.intersect_circle?(Geometry.rect_to_circle(@mouse.rect), c.hitbox)
      end
    end

    if @component_held
      if @mouse.key_held.left
        @component_held.pos = @mouse.position.slice(:x, :y)
      elsif @mouse.key_up.left
        @component_held = nil
      end
    end
  end
end
