module SharedWorkforce
  class Client
  
    @http_end_point = "http://hci.heroku.com"
    @load_path = "tasks"
  
    class << self
      attr_accessor :api_key
      attr_accessor :load_path
      attr_accessor :http_end_point
      attr_accessor :callback_host
      attr_accessor :callback_path
      
      def version
        SharedWorkforce::VERSION
      end
    
      def load!
        Dir[File.join(load_path, "*.rb")].each do |file|
          load file
        end
      end
      
      def callback_url
        callback_host + '/' + callback_path
      end
      
      def callback_path
        "hci_task_result"
      end
    end
  
  end
end