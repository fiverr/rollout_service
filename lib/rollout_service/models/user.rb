module RolloutService
  class User
    attr_reader :name, :email

    def initialize(env)
      user = env['User-Details'] || ''
      name, email = user.split(':')
      @name = name || 'Anonymous'
      @email = email || 'anonymous@anonymous.con'
    end
  end
end
