require 'test'

class TestQuestionList < Test

  class TestQuestion < Question

    attr_reader :clicks, :asks, :responds

    def initialize(*args)
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


end