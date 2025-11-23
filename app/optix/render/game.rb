class OptixGame
  def render_game
    @outputs.background_color = BACKGROUND_COLOR

    render_beams
    render_emitters
    render_components
  end

  def render_beams
    @beams.each do |beam|
      @primitives << beam.primitive
    end
  end

  def render_emitters
    @emitters.each do |emitter|
      @primitives << emitter.sprite
    end
  end

  def render_components
    @components.each do |component|
      @primitives << component.sprite
    end
  end
end
