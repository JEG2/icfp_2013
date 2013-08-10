require_relative "spec_helper"

describe Sherlock::API do
  let(:ua)  { double                }
  let(:api) { Sherlock::API.new(ua) }

  it "can request and return a list of problems" do
    problem = { "id"        => 12345,
                "size"      => 3,
                "operators" => ["not"] }

    ua.stub(new: ua)
    ua.should_receive(:post)
      .with(/\bmyproblems\b/)
      .and_return(double(status: 200, body: [problem].to_json))
    result, content = api.my_problems

    expect(result).to  eq(:success)
    expect(content).to eq([problem])
  end

  it "can evaluate problems" do
    solution = { id:        "ABC",
                 arguments: [0, 1, 2, 3] }
    response = { "status"    => "ok",
                 "outputs"   => ["0x0000000000000000"] * 4 }

    ua.stub(new: ua)
    ua.should_receive(:post)
      .with(/\beval\b/)
      .and_return(double(status: 200, body: response.to_json))
    result, content = api.eval(solution)

    expect(result).to  eq(:success)
    expect(content).to eq(response)
  end

  it "can evaluate programs" do
    solution = { program:   "(lambda (x) 0)",
                 arguments: [0, 1, 2, 3] }
    response = { "status"    => "ok",
                 "outputs"   => ["0x0000000000000000"] * 4 }

    ua.stub(new: ua)
    ua.should_receive(:post)
      .with(/\beval\b/)
      .and_return(double(status: 200, body: response.to_json))
    result, content = api.eval(solution)

    expect(result).to  eq(:success)
    expect(content).to eq(response)
  end

  it "it converts arguments to 64 bit vectors" do
    solution = { program:   "(lambda (x) 0)",
                 arguments: [0, 1, 2, 3] }

    ua.stub(new: ua)
    request = double.tap do |r|
      r.should_receive(:body=)
       .with( { program:   "(lambda (x) 0)",
                arguments: [ "0x0000000000000000",
                             "0x0000000000000001",
                             "0x0000000000000002",
                             "0x0000000000000003" ] }.to_json )
    end
    ua.should_receive(:post)
      .with(/\beval\b/)
      .and_yield(request)
      .and_return(double(status: 200, body: nil))
    api.eval(solution)
  end

  it "requires an ID or program for evaluation" do
    ua.stub(:new)
    expect do
      api.eval(arguments: [1])
    end.to raise_error(RuntimeError)
  end

  it "requires a valid ID for evaluation" do
    ua.stub(:new)
    expect do
      api.eval(id: " ", arguments: [1])
    end.to raise_error(RuntimeError)
  end

  it "requires a valid program for evaluation" do
    ua.stub(:new)
    expect do
      api.eval(program: "(lambda (x) x)" * 1_025, arguments: [1])
    end.to raise_error(RuntimeError)
  end

  it "requires some arguments for evaluation" do
    ua.stub(:new)
    expect do
      api.eval(id: "ABC", arguments: [])
    end.to raise_error(RuntimeError)
  end

  it "requires 256 or less arguments for evaluation" do
    ua.stub(:new)
    expect do
      api.eval(id: "ABC", arguments: [1] * 257)
    end.to raise_error(RuntimeError)
  end

  it "requires valid arguments for evaluation" do
    ua.stub(:new)
    expect do
      api.eval( id:        "ABC",
                arguments: [Sherlock::AST::Expression::MAX_VECTOR + 1] )
    end.to raise_error(RuntimeError)
  end

  it "can submit guesses" do
    guess    = { "id"      => "ABC",
                 "program" => "(lambda (x) x)" }
    response = {"status" => "win"}

    ua.stub(new: ua)
    request = double.tap do |r|
      r.should_receive(:body=)
       .with(guess.to_json)
    end
    ua.should_receive(:post)
      .with(/\bguess\b/)
      .and_yield(request)
      .and_return(double(status: 200, body: response.to_json))
    result, content = api.guess(guess["id"], guess["program"])

    expect(result).to  eq(:success)
    expect(content).to eq(response)
  end

  it "can request and return training problems" do
    problem = { "challenge" => "(lambda (x) (not x))",
                "id"        => 12345,
                "size"      => 3,
                "operators" => ["not"] }

    ua.stub(new: ua)
    ua.should_receive(:post)
      .with(/\btrain\b/)
      .and_return(double(status: 200, body: problem.to_json))
    result, content = api.train

    expect(result).to  eq(:success)
    expect(content).to eq(problem)
  end

  it "allows you to pass the optional parameters to train" do
    params = {size: 5, operators: %Q{["fold"]}}

    ua.stub(new: ua)
    request = double.tap do |r|
      r.should_receive(:body=)
       .with(params.to_json)
    end
    ua.should_receive(:post)
      .with(/\btrain\b/)
      .and_yield(request)
      .and_return(double(status: 200, body: nil))
    api.train(params)
  end

  it "turns the training operators into a list if needed" do
    ua.stub(new: ua)
    request = double.tap do |r|
      r.should_receive(:body=)
       .with({operators: %Q{["fold"]}}.to_json)
    end
    ua.should_receive(:post)
      .with(/\btrain\b/)
      .and_yield(request)
      .and_return(double(status: 200, body: nil))
    api.train(operators: "fold")
  end

  it "requires a valid size for training" do
    ua.stub(:new)
    expect do
      api.train(size: 10_000)
    end.to raise_error(RuntimeError)
  end

  it "requires valid operators for training" do
    ua.stub(:new)
    expect do
      api.train(operators: "invalid")
    end.to raise_error(RuntimeError)
  end

  it "can fetch the team's status" do
    status = {"contestScore" => 42_000_000}

    ua.stub(new: ua)
    ua.should_receive(:post)
      .with(/\bstatus\b/)
      .and_return(double(status: 200, body: status.to_json))
    result, content = api.status

    expect(result).to  eq(:success)
    expect(content).to eq(status)
  end

  it "forwards the base URL to the user agent" do
    ua.should_receive(:new)
      .with(hash_including(url: "http://icfpc2013.cloudapp.net"))
    Sherlock::API.new(ua)
  end

  it "interprets error codes" do
    ua.stub(new: ua)
    ua.should_receive(:post)
      .with(/\bmyproblems\b/)
      .and_return(double(status: 403, body: nil))
    result, content = api.my_problems

    expect(result).to  eq(Sherlock::API::STATUS_CODES[403])
    expect(content).to be_nil
  end
end
