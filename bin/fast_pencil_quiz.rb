#!/usr/bin/ruby
require_relative File.join('..', 'lib', 'fast_pencil_quiz')

if __FILE__ == $PROGRAM_NAME
  FastPencilQuiz.new.run
end

