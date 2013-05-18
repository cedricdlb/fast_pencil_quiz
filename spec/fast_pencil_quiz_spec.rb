#!/usr/bin/ruby
require_relative '../fast_pencil_quiz.rb'

describe FastPencilQuiz do
	before do
		@fast_pencil_quiz = FastPencilQuiz.new
	end

	subject { @fast_pencil_quiz }

	context "when #find_sequences has not yet been run" do
		subject { @fast_pencil_quiz.q_and_a_candidates }
		it { should be_a Hash }
		it { should be_empty }
	end

	context "when #find_sequences is run" do
		context "with an empty word list" do
			before do
				@words = []
				@number_of_sequences = @fast_pencil_quiz.find_sequences(@words)
			end
	
			specify { @number_of_sequences.should == 0 }
			subject { @fast_pencil_quiz.q_and_a_candidates }
			it { should be_a Hash }
			it { should be_empty }
		end

		context "with a valid word list" do
			before do
				@words = %w[arrows food carrots give me food]
				@sequences = %w[arro carr food give rots rows rrot rrow]
				@containing_words = [
					%w[arrows carrots],
					%w[carrots],
					%w[food food],
					%w[give],
					%w[carrots],
					%w[arrows],
					%w[carrots],
					%w[arrows],
				]
				@number_of_sequences = @fast_pencil_quiz.find_sequences(@words)
			end
	
			specify { @number_of_sequences.should == @sequences.size }
		
			subject { @fast_pencil_quiz.q_and_a_candidates }
			it { should be_a Hash }
			it { should_not be_empty }
			its(:size) { should == 8 }
		
			its(:keys) { subject.sort.should == @sequences }

			(0...8).to_a.each do |i|
				context "when testing sequence " + i.to_s do 
					specify { @fast_pencil_quiz.q_and_a_candidates[@sequences[i]].should == @containing_words[i] }
				end
			end

			context "when #determine_unique_sequences is run" do
				before do
					#@unique_sequences = %w[carr give rots rows rrot rrow]
					@unique_sequences = @sequences - %w[arro food]
					@unique_words = @containing_words - [%w[arrows carrots], %w[food food]]
					@questions_file_name = "path to questions_file"
					@answers_file_name   = "path to answers_file"
					@mock_file_questions = mock(File)
					@mock_file_answers   = mock(File)
					@fast_pencil_quiz.should_receive(:questions_file_name).and_return(@questions_file_name)
					@fast_pencil_quiz.should_receive(:answers_file_name).and_return(@answers_file_name)
					File.should_receive(:open).with(@questions_file_name, "w").and_yield(@mock_file_questions)
					File.should_receive(:open).with(@answers_file_name, "w").and_yield(@mock_file_answers)
					@number_of_unique_sequences = @fast_pencil_quiz.determine_unique_sequences()
				end
	
				specify { @number_of_unique_sequences.should == @unique_sequences.size }

				it "should write out sequences found in only one word" do
					(0...5).to_a.each do |i|
						@mock_file_questions.should_receive(:puts).once().with(@unique_sequences[i])
					end
				end

				it "should only write enough times to include all the questions" do
					@mock_file_questions.should_receive(:puts).exactly(5).times
				end

				it "should write out words corresponding to unique sequences" do
					(0...5).to_a.each do |i|
						@mock_file_answers.should_receive(:puts).once().with(@unique_words[i])
					end
				end

				it "should only write enough times to include all the answers" do
					@mock_file_answers.should_receive(:puts).exactly(5).times
				end
			end
		end
	end
end


