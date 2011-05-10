module SharedWorkforce
  class Configuration
    
    attr_accessor :api_key
    attr_accessor :load_path
    attr_accessor :http_end_point
    attr_accessor :callback_host
    attr_accessor :request_class
    attr_writer :callback_path
    
    def initialize
      @http_end_point = "http://api.sharedworkforce.com"
      @load_path = "tasks"
      @request_class = HttpTaskRequest
    end
    
    def callback_url
      callback_host.to_s + '/' + callback_path.to_s
    end
    
    def callback_path
      @callback_path ||= "hci_task_result"
    end 
    
  end
end