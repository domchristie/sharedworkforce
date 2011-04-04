module SharedWorkforce
  class EndPoint

    def initialize(app)
      @app = app
    end

    def call(env)
      if env["PATH_INFO"] =~ /^\/#{Client.callback_path}/
        process_request(env)
      else
        @app.call(env)
      end

    end

    private

    def process_request(env)
      req = Rack::Request.new(env)
      body = JSON.parse(req.body.read)
      puts "processing hit callback"
      puts body.inspect
      SharedWorkforce::HitResult.new(body).process!
    
      [ 200,
        { "Content-Type"   => "text/html",
          "Content-Length" => "0" },
        [""]  
      ]
    end

  end
end