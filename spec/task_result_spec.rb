require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe "TaskResult" do
  describe "#process!" do
    it "should invoke a tasks complete callback" do
      
      resources = {}
      resources['1'] = OpenStruct.new(:approved=>false)
      resources['2'] = OpenStruct.new(:approved=>false)
      resources['3'] = OpenStruct.new(:approved=>false)
        
      task = SharedWorkforce::Task.define("Approve photo") do |h|
        
        h.on_completion do |result|
          if result.responses.first.answer == 'yes'
            resources[result.callback_params['resource_id']].approved = true
          end
        end
        
      end
      
      SharedWorkforce::TaskResult.new({'callback_params'=>{'resource_id' => '2'}, 'responses'=>[{'answer'=>'yes'}], 'name'=>"Approve photo"}).process!
      
      resources['1'].approved.should == false
      resources['2'].approved.should == true
      resources['3'].approved.should == false
      
    end
  end
  
  describe "#answers" do
    it "should collect the answers" do  
      r = SharedWorkforce::TaskResult.new({'callback_params'=>{'resource_id' => '2'}, 'responses'=>[{'answer'=>'yes'}, {'answer'=>'no'}, {'answer'=>'yes'}], 'name'=>"Approve photo"})
      r.answers.should == ['yes', 'no', 'yes']
    end
  end
  
  describe "#usernames" do
    it "should collect the usernames" do  
      r = SharedWorkforce::TaskResult.new({'callback_params'=>{'resource_id' => '2'}, 'responses'=>[{'answer'=>'yes', 'username'=>'bilbo'}, {'answer'=>'no', 'username'=>'frodo'}, {'answer'=>'yes', 'username'=>'sam'}], 'name'=>"Approve photo"})
      r.usernames.should == ['bilbo', 'frodo', 'sam']
    end
  end
end