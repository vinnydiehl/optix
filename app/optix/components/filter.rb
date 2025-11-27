class Filter < Component
  include FilterBehavior
  include FlatShape

  def initialize(data)
    super(data)

    @movable = true
    @color = data[:color]
  end

  def sprite
    set_line
    {
      **line,
      **@color.to_h,
    }
  end
end
