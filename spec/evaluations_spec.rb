describe "AST evaluation" do

  let(:one)  { Sherlock::AST::Constant.new(1)  }
  let(:zero) { Sherlock::AST::Constant.new(0)  }
  let(:x)    { Sherlock::AST::Variable.new("x")}

  it "evaluates a constant" do
    expect(one.evaluate({})).to eq(1)
  end

  it "evaluates a variable" do
    expect(x.evaluate({"x" => 42})).to eq(42)
  end

  it "evaluates not" do
    not_operator = Sherlock::AST::NotOperator.new(one)
    expect(not_operator.evaluate({})).to eq(1 ^ Sherlock::AST::Expression::MAX_VECTOR)
  end

  it "evaluates shl1" do
    shl1 = Sherlock::AST::ShiftLeftOne.new(one)
    expect(shl1.evaluate({})).to eq(2)
  end

  it "evaluates shr1" do
    shr1 = Sherlock::AST::ShiftRightOne.new(one)
    expect(shr1.evaluate({})).to eq(0)
  end

  it "evaluates shr4" do
    shr4 = Sherlock::AST::ShiftRightFour.new(x)
    expect(shr4.evaluate({"x" => 1 << 4})).to eq(1)
  end

  it "evaluates shr16" do
    shr16 = Sherlock::AST::ShiftRightSixteen.new(x)
    expect(shr16.evaluate({"x" => 1 << 16})).to eq(1)
  end

  describe "edgecases" do
    it "evaluates zero not case" do
      not_operator = Sherlock::AST::NotOperator.new(zero)
      expect(not_operator.evaluate({})).to eq(Sherlock::AST::Expression::MAX_VECTOR)
    end

    it "evaluates MAX_VECTOR not case" do
      not_operator = Sherlock::AST::NotOperator.new(x)
      expect(not_operator.evaluate({"x" => Sherlock::AST::Expression::MAX_VECTOR})).to eq(0)
    end

    it "evaluates 0xFFFFFFFF00000000 not case" do
      not_operator = Sherlock::AST::NotOperator.new(x)
      expect(not_operator.evaluate({"x" => 0xFFFFFFFF00000000})).to eq(0x00000000FFFFFFFF)
    end

    it "evaluates 0x0123456789ABCDEF not case" do
      not_operator = Sherlock::AST::NotOperator.new(x)
      expect(not_operator.evaluate({"x" => 0x0123456789ABCDEF})).to eq(0xFEDCBA9876543210)
    end

    it "evaluates 0xFFFF0000 not case" do
      not_operator = Sherlock::AST::NotOperator.new(x)
      expect(not_operator.evaluate({"x" => 0xFFFF0000})).to eq(0xFFFFFFFF0000FFFF)
    end

# ------------------------
    
    it "evaluates zero shl1 case" do
      shl1 = Sherlock::AST::ShiftLeftOne.new(zero)
      expect(shl1.evaluate({})).to eq(0)
    end

    it "evaluates MAX_VECTOR shl1 case" do
      shl1 = Sherlock::AST::ShiftLeftOne.new(x)
      expect(shl1.evaluate({"x" => Sherlock::AST::Expression::MAX_VECTOR})).to eq(Sherlock::AST::Expression::MAX_VECTOR - 1)
    end

    it "evaluates 0xFFFFFFFF00000000 shl1 case" do
      shl1 = Sherlock::AST::ShiftLeftOne.new(x)
      expect(shl1.evaluate({"x" => 0xFFFFFFFF00000000})).to eq(0xFFFFFFFe00000000)
    end

    it "evaluates 0x0123456789ABCDEF shl1 case" do
      shl1 = Sherlock::AST::ShiftLeftOne.new(x)
      expect(shl1.evaluate({"x" => 0x0123456789ABCDEF})).to eq(0x02468ACF13579BDE)
    end
    
    it "evaluates 0xFFFF0000 shl1 case" do
      shl1 = Sherlock::AST::ShiftLeftOne.new(x)
      expect(shl1.evaluate({"x" => 0xFFFF0000})).to eq(0x1FFFE0000)
    end

# ------------------------
    
    it "evaluates zero shr1 case" do
      shr1 = Sherlock::AST::ShiftRightOne.new(zero)
      expect(shr1.evaluate({})).to eq(0)
    end

    it "evaluates MAX_VECTOR shl1 case" do
      shl1 = Sherlock::AST::ShiftLeftOne.new(x)
      expect(shl1.evaluate({"x" => Sherlock::AST::Expression::MAX_VECTOR})).to eq(Sherlock::AST::Expression::MAX_VECTOR - 1)
    end

    it "evaluates 0xFFFFFFFF00000000 shl1 case" do
      shl1 = Sherlock::AST::ShiftLeftOne.new(x)
      expect(shl1.evaluate({"x" => 0xFFFFFFFF00000000})).to eq(0xFFFFFFFe00000000)
    end

    it "evaluates 0x0123456789ABCDEF shl1 case" do
      shl1 = Sherlock::AST::ShiftLeftOne.new(x)
      expect(shl1.evaluate({"x" => 0x0123456789ABCDEF})).to eq(0x02468ACF13579BDE)
    end
    
    it "evaluates 0xFFFF0000 shl1 case" do
      shl1 = Sherlock::AST::ShiftLeftOne.new(x)
      expect(shl1.evaluate({"x" => 0xFFFF0000})).to eq(0x1FFFE0000)
    end

    it "evaluates 0x8000000000000000 shl1 case" do
      shl1 = Sherlock::AST::ShiftLeftOne.new(x)
      expect(shl1.evaluate({"x" => 0x8000000000000000})).to eq(0x0000000000000000)
    end

  end
end
