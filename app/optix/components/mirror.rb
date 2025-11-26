class Mirror < Component
  include ReflectiveBehavior
  include FlatShape

  def initialize(data)
    super(data)

    @movable = true
  end

  def sprite
    set_line
    {
      **line,
      **WHITE.to_h,
    }
  end
end
