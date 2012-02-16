require File.expand_path(File.dirname(__FILE__) + '/spec_helper')
require 'ostruct'

describe "Task" do
  it "should define a task with default attributes" do
    task_class = Class.new do
      include SharedWorkforce::Task

      title 'Approve Photo'
      instruction 'Please classify this photo by choosing the appropriate tickboxes.'
      responses_required 3
      image_url "http://www.google.com/logo.png"

      answer_options ['Obscenity', 'Nudity', 'Blurry', 'Upside down or sideways']

      on_complete :puts_complete
      on_failure :puts_failure

      def puts_complete(results)
        puts "Complete"
      end

      def puts_failure(results)
        puts "Failure"
      end
    end
    
    task = task_class.new
    task.instruction.should == "Please classify this photo by choosing the appropriate tickboxes."
    task.title.should == "Approve Photo"
    task.responses_required.should == 3
    task.image_url.should == "http://www.google.com/logo.png"
    task.answer_options.should == ['Obscenity', 'Nudity', 'Blurry', 'Upside down or sideways']
  end

  it "should allow certain default attributes to be overwritten" do
    task_class = Class.new do
      include SharedWorkforce::Task

      title 'Approve Photo'
      instruction 'Please classify this photo by choosing the appropriate tickboxes.'
      responses_required 3
      image_url "http://www.google.com/logo.png"
      replace false

      answer_options ['Obscenity', 'Nudity', 'Blurry', 'Upside down or sideways']

      text "A photo"

      on_complete :puts_complete
      on_failure :puts_failure

      def puts_complete(results)
        puts "Complete"
      end

      def puts_failure(results)
        puts "Failure"
      end
    end
    
    task = task_class.new
    
    task.image_url = "http://www.bing.com"
    task.answer_options = ['Poor quality']
    task.responses_required = 10
    task.instruction = nil
    task.replace = true

    task.image_url.should == "http://www.bing.com"
    task.answer_options.should == ['Poor quality']
    task.responses_required.should == 10
    task.instruction.should == nil
    task.replace.should == true
    task.text.should == "A photo"
  end
  
  describe "#process_result" do
    it "should run a completion callback" do
      class PhotoApprover; def approve; end; end
          
      task = Class.new do
        include SharedWorkforce::Task
        title "Approve photo"
        
        on_complete :log_approval
        
        def log_approval(result)
          PhotoApprover.approve
        end
      end
      
      PhotoApprover.should_receive(:approve).once
      task.new.process_result({})
    end

    it "should run a success callback" do

      class PhotoApprover; def approve; end; end
          
      task = Class.new do
        include SharedWorkforce::Task
        title "Approve photo"
        
        on_success :log_approval
        
        def log_approval(result)
          PhotoApprover.approve
        end
      end
      
      PhotoApprover.should_receive(:approve).once
      task.new.process_result({})
    end
  end
  
  describe "#fail!" do
    it "should run a failure callback" do

      class PhotoApprover; def resubmit; end; end
      
      task = Class.new do
        include SharedWorkforce::Task
        title "Approve photo"
        
        on_failure :resubmit_photo
        
        def resubmit_photo(result)
          PhotoApprover.resubmit
        end
      end
      
      PhotoApprover.should_receive(:resubmit).once
      task.new.fail!({})
    end

    it "should not raise an error if there is no callback defined" do
      lambda {
        task = Class.new { include SharedWorkforce::Task }
        task.new.fail!({})
      }.should_not raise_error
    end
  end

  describe ".new" do
    it "setup should be called" do
      task_class = Class.new { include SharedWorkforce::Task; def setup; end }
      task_class.any_instance.should_receive(:setup).once
      task_class.new
    end
  end

  describe "#request" do
    it "should make a new task http request" do
      task = Class.new { include SharedWorkforce::Task }

      stub_request(:post, "http://api.sharedworkforce.com/tasks")
      task.new.request(:request_id=>'123')
      a_request(:post, "http://api.sharedworkforce.com/tasks").should have_been_made.once
    end
  end
  
  describe "#cancel" do
    it "should send a cancel task http request" do
      task = Class.new { include SharedWorkforce::Task }

      stub_request(:post, "http://api.sharedworkforce.com/tasks/cancel")
      task.new.cancel(:request_id=>'123')
      a_request(:post, "http://api.sharedworkforce.com/tasks/cancel").should have_been_made.once
    end

    it "should raise a ConfigurationError if a callback host is not set" do
      task = Class.new { include SharedWorkforce::Task }
      with_configuration do |config|
        config.callback_host = nil
        lambda {
          task.new.cancel(:request_id=>'123')
        }.should raise_error SharedWorkforce::ConfigurationError
      end
    end
    
    it "should raise a ConfigurationError if an API key is not set" do
      task = Class.new { include SharedWorkforce::Task }
      with_configuration do |config|
        config.api_key = nil
        lambda {
          task.new.cancel(:request_id=>'123')
        }.should raise_error SharedWorkforce::ConfigurationError
      end
    end
  end

  describe "#resource" do
    it "should return the resource that passed to as an argument to new" do
      task_class = Class.new { include SharedWorkforce::Task }
      resource = double
      task = task_class.new(resource)
      task.resource.should == resource
    end

    it "should return the resource from the callback params" do
      class ResourceFinder; def self.find(id); return "#{id}ABCD"; end; end
      task_class = Class.new { include SharedWorkforce::Task }
      task = task_class.new(SharedWorkforce::TaskResult.new({'callback_params'=>{'resource_class_name'=>'ResourceFinder', 'resource_id' => '2'}}))
      task.resource.should == "2ABCD"
    end

    it "should return nil if the callback params do not specify a resource" do
      task_class = Class.new { include SharedWorkforce::Task }
      task = task_class.new(SharedWorkforce::TaskResult.new({'callback_params'=>{}}))
      task.resource.should == nil
    end
  end

  describe "#to_hash" do
    it "should include the class name and id of the resource in the callback params" do
      task_class = Class.new { include SharedWorkforce::Task }
      resource = double("user", :id=>333)
      task = task_class.new(resource)
      task.to_hash[:callback_params][:resource_id].should == 333
      task.to_hash[:callback_params][:resource_class_name].should == "RSpec::Mocks::Mock"
    end
  end
end


