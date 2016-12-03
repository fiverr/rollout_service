class Script
  attr_accessor :active, :script_steps
  to_json :start_time

  def initialize(script_steps:)
    @start_time = Time.now.to_i
    @script_steps = script_steps
  end

  def validate
    @script_steps.is_a?(Array)&&
    @script_steps.any? &&
    @script_steps.all? {|step| step.is_a?(ScriptStep) && step.validate }
  end

  def active?
    @active
  end

  def available_step
    return false unless @active
    current_seconds_diffrense = Time.now.to_i - @start_time.to_i
    script = @script_steps.find do |step|
      step.active? && current_seconds_diffrense > step.time
    end
    return false if script.nil?
    script
  end

  def completed?
    @script_steps.all do |script|
      script.active?
    end
  end

  def marshal_dump
    [@start_time, @script_steps, @active]
  end

  def marshal_load(array)
    @start_time, @script_steps, @active = array
  end

  def self.unserialized(serialized_object)
    Marshal.load(Base64.decode64(serialized_object))
  end

  def self.serialized(object)
    Base64.encode64(Marshal.dump(object))
  end

  def as_json
    {
      start_time: @start_time,
      script_steps: @script_steps.map {|step| step.as_json }
    }
  end

end