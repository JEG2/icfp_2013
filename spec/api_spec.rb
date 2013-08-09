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
      .with(/\bmyproblems\b/, { })
      .and_return(double(status: 200, body: [problem].to_json))
    result, content = api.my_problems

    expect(result).to  eq(:success)
    expect(content).to eq([problem])
  end

  it "can request and return training problems" do
    problem = { "challenge" => "(lambda (x) (not x))",
                "id"        => 12345,
                "size"      => 3,
                "operators" => ["not"] }

    ua.stub(new: ua)
    ua.should_receive(:post)
      .with(/\btrain\b/, { })
      .and_return(double(status: 200, body: problem.to_json))
    result, content = api.train

    expect(result).to  eq(:success)
    expect(content).to eq(problem)
  end

  it "interprets error codes" do
    ua.stub(new: ua)
    ua.should_receive(:post)
      .with(/\bmyproblems\b/, { })
      .and_return(double(status: 403, body: nil))
    result, content = api.my_problems

    expect(result).to  eq(Sherlock::API::STATUS_CODES[403])
    expect(content).to be_nil
  end
end
