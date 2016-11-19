class Response
   attr_accessor :data

   def initialize(data)
       @data = data
   end

   def to_s
       {data: self.data}.to_json
   end
end