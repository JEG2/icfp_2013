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

  it "evaluates and" do
    and_operator = Sherlock::AST::AndOperator.new(one, zero)
    expect(and_operator.evaluate({})).to eq(0)
  end

  it "evaluates or" do
    or_operator = Sherlock::AST::OrOperator.new(zero, one)
    expect(or_operator.evaluate({})).to eq(1)
  end

  it "evaluates xor" do
    xor_operator = Sherlock::AST::XorOperator.new(zero, one)
    expect(xor_operator.evaluate({})).to eq(1)
  end

  it "evaluates plus" do
    plus = Sherlock::AST::PlusOperator.new(one, one)
    expect(plus.evaluate({})).to eq(2)
  end

  it "evaluates fold" do
    # (lambda (x)(fold x 0 (lambda(x y)(plus x y))))
    y    = Sherlock::AST::Variable.new("y")
    plus = Sherlock::AST::PlusOperator.new(x, y)
    fold = Sherlock::AST::Fold.new(x, zero, x, y, plus)

    { 0 => 0, 1 => 1,
      0x0101010101010101 => 8,
      0xFFFFFFFFFFFFFFFF => 0x7F8,
      0xFFFFFFFF00000000 => 0x3FC,
      0x0123456789ABCDEF => 0x3C0,
      0xFFFF0000 => 0x1FE }.each do |variable, answer|
      expect(fold.evaluate({"x" => variable})).to eq(answer)
    end
  end

  it "evaluates identity fold" do
    y    = Sherlock::AST::Variable.new("y")
    plus = Sherlock::AST::PlusOperator.new(x, y)
    fold = Sherlock::AST::Fold.new(zero, x, x, y, plus)

    { 0 => 0, 1 => 1,
      0x0101010101010101 => 0x0101010101010101,
      0xFFFFFFFFFFFFFFFF => 0xFFFFFFFFFFFFFFFF,
      0xFFFFFFFF00000000 => 0xFFFFFFFF00000000,
      0x0123456789ABCDEF => 0x0123456789ABCDEF,
      0xFFFF0000 => 0xFFFF0000 }.each do |variable, answer|
      expect(fold.evaluate({"x" => variable})).to eq(answer)
    end
  end

  it "evaluates fold 1" do
    y    = Sherlock::AST::Variable.new("y")
    plus = Sherlock::AST::PlusOperator.new(x, y)
    fold = Sherlock::AST::Fold.new(one, x, x, y, plus)

    { 0 => 1, 1 => 2,
      0x0101010101010101 => 0x0101010101010102,
      0xFFFFFFFFFFFFFFFF => 0,
      0xFFFFFFFF00000000 => 0xFFFFFFFF00000001,
      0x0123456789ABCDEF => 0x0123456789ABCDF0,
      0xFFFF0000 => 0xFFFF0001 }.each do |variable, answer|
      expect(fold.evaluate({"x" => variable})).to eq(answer)
    end
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

    it "evaluates MAX_VECTOR shr1 case" do
      shr1 = Sherlock::AST::ShiftRightOne.new(x)
      expect(shr1.evaluate({"x" => Sherlock::AST::Expression::MAX_VECTOR})).to eq(0x7FFFFFFFFFFFFFFF)
    end

    it "evaluates 0xFFFFFFFF00000000 shr1 case" do
      shr1 = Sherlock::AST::ShiftRightOne.new(x)
      expect(shr1.evaluate({"x" => 0xFFFFFFFF00000000})).to eq(0x7FFFFFFF80000000)
    end

    it "evaluates 0x0123456789ABCDEF shr1 case" do
      shr1 = Sherlock::AST::ShiftRightOne.new(x)
      expect(shr1.evaluate({"x" => 0x0123456789ABCDEF})).to eq(0x91A2B3C4D5E6F7)
    end

    it "evaluates 0xFFFF0000 shr1 case" do
      shr1 = Sherlock::AST::ShiftRightOne.new(x)
      expect(shr1.evaluate({"x" => 0xFFFF0000})).to eq(0x7FFF8000)
    end

    # ------------------------

    it "evaluates zero shr4 case" do
      shr4 = Sherlock::AST::ShiftRightFour.new(zero)
      expect(shr4.evaluate({})).to eq(0)
    end

    it "evaluate one shr4 case" do
      shr4 = Sherlock::AST::ShiftRightFour.new(one)
      expect(shr4.evaluate({})).to eq(0)
    end

    it "evaluates MAX_VECTOR shr4 case" do
      shr4 = Sherlock::AST::ShiftRightFour.new(x)
      expect(shr4.evaluate({"x" => Sherlock::AST::Expression::MAX_VECTOR})).to eq(0x0FFFFFFFFFFFFFFF)
    end

    it "evaluates 0xFFFFFFFF00000000 shr4 case" do
      shr4 = Sherlock::AST::ShiftRightFour.new(x)
      expect(shr4.evaluate({"x" => 0xFFFFFFFF00000000})).to eq(0x0FFFFFFFF0000000)
    end

    it "evaluates 0x0123456789ABCDEF shr4 case" do
      shr4 = Sherlock::AST::ShiftRightFour.new(x)
      expect(shr4.evaluate({"x" => 0x0123456789ABCDEF})).to eq(0x123456789ABCDE)
    end

    it "evaluates 0xFFFF0000 shr4 case" do
      shr4 = Sherlock::AST::ShiftRightFour.new(x)
      expect(shr4.evaluate({"x" => 0xFFFF0000})).to eq(0xFFFF000)
    end

    # ------------------------

    it "evaluates zero shr16 case" do
      shr16 = Sherlock::AST::ShiftRightSixteen.new(zero)
      expect(shr16.evaluate({})).to eq(0)
    end

    it "evaluate one shr16 case" do
      shr16 = Sherlock::AST::ShiftRightSixteen.new(one)
      expect(shr16.evaluate({})).to eq(0)
    end

    it "evaluates MAX_VECTOR shr16 case" do
      shr16 = Sherlock::AST::ShiftRightSixteen.new(x)
      expect(shr16.evaluate({"x" => Sherlock::AST::Expression::MAX_VECTOR})).to eq(0xFFFFFFFFFFFF)
    end

    it "evaluates 0xFFFFFFFF00000000 shr16 case" do
      shr16 = Sherlock::AST::ShiftRightSixteen.new(x)
      expect(shr16.evaluate({"x" => 0xFFFFFFFF00000000})).to eq(0x0FFFFFFFF0000)
    end

    it "evaluates 0x0123456789ABCDEF shr16 case" do
      shr16 = Sherlock::AST::ShiftRightSixteen.new(x)
      expect(shr16.evaluate({"x" => 0x0123456789ABCDEF})).to eq(0x123456789AB)
    end

    it "evaluates 0xFFFF0000 shr16 case" do
      shr16 = Sherlock::AST::ShiftRightSixteen.new(x)
      expect(shr16.evaluate({"x" => 0xFFFF0000})).to eq(0xFFFF)
    end

    # ------------------------

    it "evaluates zero and_operator case" do
      and_operator = Sherlock::AST::AndOperator.new(zero, zero)
      expect(and_operator.evaluate({})).to eq(0)
    end

    it "evaluate one and_operator case" do
      and_operator = Sherlock::AST::AndOperator.new(one, one)
      expect(and_operator.evaluate({})).to eq(1)
    end

    it "evaluates MAX_VECTOR and_operator case" do
      and_operator = Sherlock::AST::AndOperator.new(x, x)
      expect(and_operator.evaluate({"x" => Sherlock::AST::Expression::MAX_VECTOR})).to eq(Sherlock::AST::Expression::MAX_VECTOR)
    end

    it "evaluates 0xFFFFFFFF00000000 and_operator case" do
      and_operator = Sherlock::AST::AndOperator.new(x, x)
      expect(and_operator.evaluate({"x" => 0xFFFFFFFF00000000})).to eq(0xFFFFFFFF00000000)
    end

    it "evaluates 0x0123456789ABCDEF and_operator case" do
      and_operator = Sherlock::AST::AndOperator.new(x, x)
      expect(and_operator.evaluate({"x" => 0x0123456789ABCDEF})).to eq(0x0123456789ABCDEF)
    end

    it "evaluates 0xFFFF0000 and_operator case" do
      and_operator = Sherlock::AST::AndOperator.new(x, x)
      expect(and_operator.evaluate({"x" => 0xFFFF0000})).to eq(0xFFFF0000)
    end

    it "evaluates 0x0123456789ABCDEF and 0 and_operator case" do
      and_operator = Sherlock::AST::AndOperator.new(x, zero)
      expect(and_operator.evaluate({"x" => 0x0123456789ABCDEF})).to eq(0)
    end

    it "evaluates 0x0123456789ABCDEF and 1 and_operator case" do
      and_operator = Sherlock::AST::AndOperator.new(x, one)
      expect(and_operator.evaluate({"x" => 0x0123456789ABCDEF})).to eq(1)
    end

    # ------------------------

    it "evaluates zero or_operator case" do
      or_operator = Sherlock::AST::OrOperator.new(zero, zero)
      expect(or_operator.evaluate({})).to eq(0)
    end

    it "evaluate one or_operator case" do
      or_operator = Sherlock::AST::OrOperator.new(one, one)
      expect(or_operator.evaluate({})).to eq(1)
    end

    it "evaluates MAX_VECTOR or_operator case" do
      or_operator = Sherlock::AST::OrOperator.new(x, x)
      expect(or_operator.evaluate({"x" => Sherlock::AST::Expression::MAX_VECTOR})).to eq(Sherlock::AST::Expression::MAX_VECTOR)
    end

    it "evaluates 0xFFFFFFFF00000000 or_operator case" do
      or_operator = Sherlock::AST::OrOperator.new(x, x)
      expect(or_operator.evaluate({"x" => 0xFFFFFFFF00000000})).to eq(0xFFFFFFFF00000000)
    end

    it "evaluates 0x0123456789ABCDEF or_operator case" do
      or_operator = Sherlock::AST::OrOperator.new(x, x)
      expect(or_operator.evaluate({"x" => 0x0123456789ABCDEF})).to eq(0x0123456789ABCDEF)
    end

    it "evaluates 0xFFFF0000 or_operator case" do
      or_operator = Sherlock::AST::OrOperator.new(x, one)
      expect(or_operator.evaluate({"x" => 0xFFFF0000})).to eq(0xFFFF0001)
    end

    it "evaluates 0x0123456789ABCDEF and 0 or_operator case" do
      or_operator = Sherlock::AST::OrOperator.new(x, zero)
      expect(or_operator.evaluate({"x" => 0x0123456789ABCDEF})).to eq(0x0123456789ABCDEF)
    end

    it "evaluates 0x0123456789ABCDEF and 1 or_operator case" do
      or_operator = Sherlock::AST::OrOperator.new(x, one)
      expect(or_operator.evaluate({"x" => 0x0123456789ABCDEF})).to eq(0x0123456789ABCDEF)
    end

    # ------------------------

    it "evaluates zero xor_operator case" do
      xor_operator = Sherlock::AST::XorOperator.new(zero, zero)
      expect(xor_operator.evaluate({})).to eq(0)
    end

    it "evaluate one xor_operator case" do
      xor_operator = Sherlock::AST::XorOperator.new(one, one)
      expect(xor_operator.evaluate({})).to eq(0)
    end

    it "evaluates MAX_VECTOR xor_operator case" do
      xor_operator = Sherlock::AST::XorOperator.new(x, x)
      expect(xor_operator.evaluate({"x" => Sherlock::AST::Expression::MAX_VECTOR})).to eq(0)
    end

    it "evaluates 0xFFFFFFFF00000000 xor_operator case" do
      xor_operator = Sherlock::AST::XorOperator.new(x, x)
      expect(xor_operator.evaluate({"x" => 0xFFFFFFFF00000000})).to eq(0)
    end

    it "evaluates 0x0123456789ABCDEF xor_operator case" do
      xor_operator = Sherlock::AST::XorOperator.new(x, x)
      expect(xor_operator.evaluate({"x" => 0x0123456789ABCDEF})).to eq(0)
    end

    it "evaluates 0xFFFF0000 xor_operator case" do
      xor_operator = Sherlock::AST::XorOperator.new(x, one)
      expect(xor_operator.evaluate({"x" => 0xFFFF0000})).to eq(0xFFFF0001)
    end

    it "evaluates 0x0123456789ABCDEF and 0 xor_operator case" do
      xor_operator = Sherlock::AST::XorOperator.new(x, zero)
      expect(xor_operator.evaluate({"x" => 0x0123456789ABCDEF})).to eq(0x0123456789ABCDEF)
    end

    it "evaluates 0x0123456789ABCDEF and 1 xor_operator case" do
      xor_operator = Sherlock::AST::XorOperator.new(x, one)
      expect(xor_operator.evaluate({"x" => 0x0123456789ABCDEF})).to eq(0x0123456789ABCDEE)
    end

    # ------------------------

    it "evaluates zero plus_operator case" do
      plus_operator = Sherlock::AST::PlusOperator.new(zero, zero)
      expect(plus_operator.evaluate({})).to eq(0)
    end

    it "evaluate one plus_operator case" do
      plus_operator = Sherlock::AST::PlusOperator.new(one, one)
      expect(plus_operator.evaluate({})).to eq(2)
    end

    it "evaluates MAX_VECTOR plus_operator case" do
      plus_operator = Sherlock::AST::PlusOperator.new(x, x)
      expect(plus_operator.evaluate({"x" => Sherlock::AST::Expression::MAX_VECTOR})).to eq(0xFFFFFFFFFFFFFFFE)
    end

    it "evaluates 0xFFFFFFFF00000000 plus_operator case" do
      plus_operator = Sherlock::AST::PlusOperator.new(x, x)
      expect(plus_operator.evaluate({"x" => 0xFFFFFFFF00000000})).to eq(0xFFFFFFFe00000000)
    end

    it "evaluates 0x0123456789ABCDEF plus_operator case" do
      plus_operator = Sherlock::AST::PlusOperator.new(x, x)
      expect(plus_operator.evaluate({"x" => 0x0123456789ABCDEF})).to eq(0x02468ACF13579BDE)
    end

    it "evaluates 0xFFFF0000 plus_operator case" do
      plus_operator = Sherlock::AST::PlusOperator.new(x, x)
      expect(plus_operator.evaluate({"x" => 0xFFFF0000})).to eq(0x1FFFE0000)
    end

    it "evaluates 0x0123456789ABCDEF and 0 plus_operator case" do
      plus_operator = Sherlock::AST::PlusOperator.new(x, zero)
      expect(plus_operator.evaluate({"x" => 0x0123456789ABCDEF})).to eq(0x0123456789ABCDEF)
    end

    it "evaluates 0x0123456789ABCDEF and 1 plus_operator case" do
      plus_operator = Sherlock::AST::PlusOperator.new(x, one)
      expect(plus_operator.evaluate({"x" => 0x0123456789ABCDEF})).to eq(0x0123456789ABCDF0)
    end

    # ------------------------

    it "evaluates zero if0 case" do
      if0 = Sherlock::AST::IfOperator.new(zero, zero, one)
      expect(if0.evaluate({})).to eq(0)
    end

    it "evaluate one if0 case" do
      if0 = Sherlock::AST::IfOperator.new(one, zero, one)
      expect(if0.evaluate({})).to eq(1)
    end

    it "evaluates MAX_VECTOR if0 case" do
      if0 = Sherlock::AST::IfOperator.new(x, zero, one)
      expect(if0.evaluate({"x" => Sherlock::AST::Expression::MAX_VECTOR})).to eq(1)
    end

    it "evaluates 0xFFFFFFFF00000000 if0 case" do
      if0 = Sherlock::AST::IfOperator.new(x, zero, one)
      expect(if0.evaluate({"x" => 0xFFFFFFFF00000000})).to eq(1)
    end

    it "evaluates 0x0123456789ABCDEF if0 case" do
      if0 = Sherlock::AST::IfOperator.new(x, zero, one)
      expect(if0.evaluate({"x" => 0x0123456789ABCDEF})).to eq(1)
    end

    it "evaluates 0xFFFF0000 if0 case" do
      if0 = Sherlock::AST::IfOperator.new(x, zero, one)
      expect(if0.evaluate({"x" => 0xFFFF0000})).to eq(1)
    end

    it "evaluates 0x0123456789ABCDEF and 0 if0 case" do
      if0 = Sherlock::AST::IfOperator.new(x, zero, one)
      expect(if0.evaluate({"x" => 0x0123456789ABCDEF})).to eq(1)
    end

    it "evaluates 0x0123456789ABCDEF and 1 if0 case" do
      if0 = Sherlock::AST::IfOperator.new(x, zero, one)
      expect(if0.evaluate({"x" => 0x0123456789ABCDEF})).to eq(1)
    end
  end

  it "evaluates a program" do
    program = "(lambda (x_34791) (fold x_34791 0 (lambda (x_34791 x_34792) (xor (shr16 (or (if0 (or (shr16 (not x_34791)) (not x_34791)) x_34791 x_34792) x_34792)) x_34791))))"
    ast = Sherlock::Parser.parse(program)
    { 0 => 0, 1 => 0,
      0x0101010101010101 => 1,
      0xFFFFFFFFFFFFFFFF => 0xFF,
      0xFFFFFFFF00000000 => 0xFF,
      0x0123456789ABCDEF => 1,
      0xFFFF0000 => 0 }.each do |variable, answer|
        expect(ast.run(variable)).to eq(answer)
    end
  end
end
