class OptixGame
  def render_game
    @outputs.background_color = BACKGROUND_COLOR

    render_beams
    render_emitters
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
end
