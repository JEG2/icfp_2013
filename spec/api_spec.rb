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
