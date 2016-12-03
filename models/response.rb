class Response

   def initialize(data = {}, message = '')
    @message = message
    @data = data
   end

   def to_s
     response = {}
     response[:data] = @data if @data.present?
     response[:message] = @message if @message.present?
     response.to_json
   end
end