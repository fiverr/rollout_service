class ScriptStep
  attr_reader :time, :rollout_value
  attr_accessor :active


  def initialize(time:, rollout_value:)
    @time = time
    @rollout_value = rollout_value
    @active = true
  end

  def validate
    @time.is_a?(Numeric) &&
    @rollout_value.is_a?(Numeric) &&
    (0..100).include?(@rollout_value)

  end

  def active?
    @active
  end

  def as_json
    {
      time: @time,
      rollout_value: @rollout_value
    }
  end

end