require_relative "spec_helper"

describe Sherlock::Solver do
  it "runs added strategies over the provided problems" do
    problem  = double
    strategy = double.tap do |s|
      s.should_receive(:can_handle?).with(problem)
    end

    solver = Sherlock::Solver.new(train: false)
    solver.add_strategy(strategy)
    solver.find_strategy(problem)
  end

  it "tries to find a strategy for each problem" do
    problem  = {"size" => 3}
    strategy = double.tap do |s|
      s.should_receive(:can_handle?)
       .with(problem)
       .and_return(false)
    end
    api      = double(my_problems: [:success, [problem]])
    solver   = Sherlock::Solver.new(api: api, train: false)
    solver.add_strategy(strategy)
    solver.solve
  end

  it "reports on the problem being solved" do
    problem  = {"size" => 3}
    strategy = double(can_handle?: true, new: double(solve: nil))
    api      = double(my_problems: [:success, [problem]])
    io       = StringIO.new
    solver   = Sherlock::Solver.new(api: api, io: io, train: false)
    solver.add_strategy(strategy)
    solver.solve
    expect(io.string).not_to be_empty
  end

  it "asks a matching strategy to solve the given problem" do
    problem  = {"size" => 3}
    api      = double(my_problems: [:success, [problem]])
    io       = StringIO.new
    instance = double.tap do |i|
      i.should_receive(:solve)
    end
    strategy = double(can_handle?: true).tap do |s|
      s.should_receive(:new)
       .with(problem, hash_including(api: api, io: io))
       .and_return(instance)
    end
    solver   = Sherlock::Solver.new(api: api, io: io, train: false)
    solver.add_strategy(strategy)
    solver.solve
  end

  it "ignores the problem list unless the API request was a success" do
    problem = double
    api     = double(my_problems: [:error, [problem]])
    io      = StringIO.new
    solver  = Sherlock::Solver.new(api: api, io: io, train: false)
    expect do
      solver.to_enum(:problems).next
    end.to raise_error(StopIteration)
    expect(io.string).not_to be_empty
  end

  it "fetches problems from the api" do
    problem = {"size" => 3}
    api     = double(my_problems: [:success, [problem]])
    solver  = Sherlock::Solver.new(api: api, train: false)
    expect(solver.to_enum(:problems).next).to eq(problem)
  end

  it "can fetch training problems until the stream errors out" do
    problem = {"size" => 3}
    api     = double.tap do |a|
      a.should_receive(:train)
       .with(hash_including(operators: "fold"))
       .and_return([:success, problem], [:success, problem], [:error, nil])
    end
    io      = StringIO.new
    solver  = Sherlock::Solver.new(api: api, train: true, io: io)
    enum    = solver.to_enum(:problems)
    expect(enum.next).to eq(problem)
    expect(enum.next).to eq(problem)
    expect do
      enum.next
    end.to raise_error(StopIteration)
  end

  it "skips over any solved problems" do
    solved_right = {"size" => 3, "solved" => true}
    solved_wrong = {"size" => 3, "solved" => false}
    unsolved     = {"size" => 3}
    api          = double( my_problems: [ :success, [ solved_right,
                                                      solved_wrong,
                                                      unsolved ] ] )
    solver       = Sherlock::Solver.new(api: api, train: false)
    expect(solver.to_enum(:problems).next).to eq(unsolved)
  end

  it "orders problems by size" do
    last   = {"size" => 4}
    first  = {"size" => 3}
    api    = double(my_problems: [:success, [last, first]])
    solver = Sherlock::Solver.new(api: api, train: false)
    enum   = solver.to_enum(:problems)
    expect(enum.next).to eq(first)
    expect(enum.next).to eq(last)
  end

  it "finds the first matching strategy" do
    problem = double
    skipped = double(can_handle?: false)
    match   = double(can_handle?: true)

    solver = Sherlock::Solver.new(train: false)
    solver.add_strategy(skipped)
    solver.add_strategy(match)
    expect(solver.find_strategy(problem)).to eq(match)
  end
end
