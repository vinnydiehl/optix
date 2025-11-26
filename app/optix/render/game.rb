class OptixGame
  def render_game
    @outputs.background_color = BACKGROUND_COLOR.to_h

    render(@beams)
    render(@components)
  end

  def render(arr)
    arr.each { |obj| @primitives << obj.sprite }
  end
end
