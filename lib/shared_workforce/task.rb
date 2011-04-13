module SharedWorkforce
  class Task
    
    class << self
    
      attr_accessor :tasks
    
      def tasks
        @tasks ||= {}
      end

      def define(name, &block)
        raise ConfigurationError, "Please set your SharedWorkforce api key with SharedWorkforce::Client.api_key = 'your-api-key-here'" unless Client.api_key
        raise ConfigurationError, "Please set your callback URL with SharedWorkforce::Client.callback_host = 'www.your-domain-name.com'" unless Client.callback_host
        
        task = self.new
        task.name = name
        yield task
        self.tasks[name] = task
      end
    
      def request(name, options)
        @tasks[name].request(options)
      end
      
      def cancel(name, options)
        @tasks[name].cancel(options)
      end
    
      def find(name)
        self.tasks[name]
      end
    
      def clear!
        @tasks = {}
      end
  
    end
  
    attr_accessor :name
    attr_accessor :directions
    attr_accessor :image_url
    attr_accessor :answer_options
    attr_accessor :answer_type
    attr_accessor :responses_required
    attr_accessor :replace # whether tasks with the same resource id and name should be overwritten

    def replace
      @replace ||= false
    end
  
    def request(options)
      task_request = TaskRequest.new(self, options)
      task_request.create
    end
    
    def cancel(options)
      task_request = TaskRequest.new(self, options)
      task_request.cancel
    end
  
    def to_hash
      {
        :name=>name,
        :directions => directions,
        :image_url => image_url,
        :answer_options => answer_options,
        :responses_required => responses_required,
        :answer_type => answer_type.to_s,
        :callback_url => Client.callback_url,
        :replace => replace
      }
    end
  
    # Callbacks
  
    def on_completion(&block)
      @on_complete_proc = block
    end
  
    def complete!(results)
      @on_complete_proc.call(results) if @on_complete_proc
    end
  
    def on_failure(&block)
      @on_failure_proc = block
    end
  
    def fail!(results)
      @on_failure_proc.call(results) if @on_failure_proc
    end
  
  
  end
end