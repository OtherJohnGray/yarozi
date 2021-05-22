require 'test'

class TestQuestionList < Test

  class TestQuestion < Question

    attr_reader :clicks, :asks, :responds

    def initialize(*args)
      super(nil)
      @clicks = args
      @asks = 0
      @responds = 0
    end

    def ask
      @asks += 1
    end

    def respond
      @responds += 1
    end

    def clicked
      @clicks.shift
    end

  end

  def test_f_f_b_f_f
    l = QuestionList.new
    l.append TestQuestion.new( "next" )
    l.append TestQuestion.new( "next", "next" )
    l.append TestQuestion.new( "back", "next" )
    assert l.ask
    l.questions.each do |q|
      assert_equal 0, q.clicks.length
    end
    assert_equal 1, l.questions[0].asks
    assert_equal 1, l.questions[0].responds
    assert_equal 2, l.questions[1].asks
    assert_equal 2, l.questions[1].responds
    assert_equal 2, l.questions[2].asks
    assert_equal 1, l.questions[2].responds
  end

  def test_f_f_b_b_b
    l = QuestionList.new
    l.append TestQuestion.new( "next", "back" )
    l.append TestQuestion.new( "next", "back" )
    l.append TestQuestion.new( "back" )
    assert !l.ask
    l.questions.each do |q|
      assert_equal 0, q.clicks.length
    end
    assert_equal 2, l.questions[0].asks
    assert_equal 1, l.questions[0].responds
    assert_equal 2, l.questions[1].asks
    assert_equal 1, l.questions[1].responds
    assert_equal 1, l.questions[2].asks
    assert_equal 0, l.questions[2].responds
  end

  def test_f_sub_f_f_super_f
    l = QuestionList.new
    l.append TestQuestion.new( "next" )
    l.append TestQuestion.new( "next" )
    l.questions[0].define_singleton_method(:ask){ subquestions.append TestQuestion.new("next"); subquestions.append TestQuestion.new("next"); @asks += 1 }
    assert l.ask
    l.questions.each do |q|
      assert_equal 0, q.clicks.length
      q.subquestions.each do |s|
        assert_equal 0, s.clicks.length
      end
    end
    assert_equal 1, l.questions[0].asks
    assert_equal 1, l.questions[0].responds
    assert_equal 1, l.questions[1].asks
    assert_equal 1, l.questions[1].responds
    assert_equal 1, l.questions[0].subquestions[0].asks
    assert_equal 1, l.questions[0].subquestions[0].responds
    assert_equal 1, l.questions[0].subquestions[1].asks
    assert_equal 1, l.questions[0].subquestions[1].responds
  end


  def test_f_sub_f_f_super_b_f_sub_f_f_super_f
    l = QuestionList.new
    l.append TestQuestion.new( "next", "next" )
    l.append TestQuestion.new( "back", "next" )
    l.questions[0].define_singleton_method(:ask){ subquestions.append TestQuestion.new("next"); subquestions.append TestQuestion.new("next"); @asks += 1 }
    assert l.ask
    l.questions.each do |q|
      assert_equal 0, q.clicks.length
      q.subquestions.each do |s|
        assert_equal 0, s.clicks.length
      end
    end
    assert_equal 2, l.questions[0].asks
    assert_equal 2, l.questions[0].responds
    assert_equal 2, l.questions[1].asks
    assert_equal 1, l.questions[1].responds
    assert_equal 1, l.questions[0].subquestions[0].asks
    assert_equal 1, l.questions[0].subquestions[0].responds
    assert_equal 1, l.questions[0].subquestions[1].asks
    assert_equal 1, l.questions[0].subquestions[1].responds
  end

  def test_f_sub_f_b_b_super_f_sub_f_f_super_f
    l = QuestionList.new
    l.append TestQuestion.new( "next", "next" )
    l.append TestQuestion.new( "next" )
    l.questions[0].instance_variable_set :@subs, [ TestQuestion.new("next", "back"), TestQuestion.new("back"), TestQuestion.new("next"), TestQuestion.new("next")]
    l.questions[0].define_singleton_method(:ask){ subquestions.append @subs.shift; subquestions.append @subs.shift; @asks += 1 }
    assert l.ask
    l.questions.each do |q|
      assert_equal 0, q.clicks.length
      q.subquestions.each do |s|
        assert_equal 0, s.clicks.length
      end
    end
    assert_equal 2, l.questions[0].asks
    assert_equal 2, l.questions[0].responds
    assert_equal 1, l.questions[1].asks
    assert_equal 1, l.questions[1].responds
    assert_equal 1, l.questions[0].subquestions[0].asks
    assert_equal 1, l.questions[0].subquestions[0].responds
    assert_equal 1, l.questions[0].subquestions[1].asks
    assert_equal 1, l.questions[0].subquestions[1].responds
  end

  def test_f_sub_f_b_b_super_b
    l = QuestionList.new
    l.append TestQuestion.new( "next", "back" )
    l.append TestQuestion.new( "next" )
    l.questions[0].define_singleton_method(:ask){ subquestions.append TestQuestion.new("next", "back"); subquestions.append TestQuestion.new("back"); @asks += 1 }
    assert !l.ask
    assert_equal 0, l.questions[0].clicks.length
    assert_equal 2, l.questions[0].subquestions[0].clicks.length
    assert_equal 1, l.questions[0].subquestions[1].clicks.length
    assert_equal 1, l.questions[1].clicks.length
    assert_equal 2, l.questions[0].asks
    assert_equal 1, l.questions[0].responds
    assert_equal 0, l.questions[1].asks
    assert_equal 0, l.questions[1].responds
    assert_equal 0, l.questions[0].subquestions[0].asks
    assert_equal 0, l.questions[0].subquestions[0].responds
    assert_equal 0, l.questions[0].subquestions[1].asks
    assert_equal 0, l.questions[0].subquestions[1].responds
  end

  def test_f_quit
    l = QuestionList.new
    l.append TestQuestion.new( "next" )
    l.append TestQuestion.new( "cancel" )
    with_dialog :yesno, true do
      assert_equal 1, (quit_code { l.ask })
    end
    assert_equal 0, l.questions[0].clicks.length
    assert_equal 1, l.questions[0].asks
    assert_equal 1, l.questions[0].responds
    assert_equal 2, l.questions[1].asks
    assert_equal 0, l.questions[1].responds
  end

  def test_f_quit_f
    l = QuestionList.new
    l.append TestQuestion.new( "next" )
    l.append TestQuestion.new( "cancel", "next" )
    with_dialog :yesno, false do
      assert_nil (quit_code { assert l.ask })
    end
    assert_equal 0, l.questions[0].clicks.length
    assert_equal 1, l.questions[0].asks
    assert_equal 1, l.questions[0].responds
    assert_equal 2, l.questions[1].asks
    assert_equal 1, l.questions[1].responds
  end

end