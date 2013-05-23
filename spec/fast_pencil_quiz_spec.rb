#!/usr/bin/ruby
require_relative '../fast_pencil_quiz.rb'

describe FastPencilQuiz do
	before(:each) do
		@fast_pencil_quiz = FastPencilQuiz.new
		subject { @fast_pencil_quiz }
	end

	context "when #find_sequences has not yet been run" do
		subject { @fast_pencil_quiz.q_and_a_candidates }
		it { should be_a Hash }
		it { should be_empty }
	end

	context "when #run" do
		before(:each) do
			@dictionary_file_name = "dictionary_file.txt"
			@questions_file_name = "./dictionary_file.questions.txt"
			@answers_file_name   = "./dictionary_file.answers.txt"
			ARGV << @dictionary_file_name
			@dictionary_mock_file = mock(File)
			@questions_mock_file = mock(File)
			@answers_mock_file   = mock(File)
			File.should_receive(:exists?).with(@dictionary_file_name).and_return(true)
			File.should_receive(:file?).with(@dictionary_file_name).and_return(true)
			File.should_receive(:readable?).with(@dictionary_file_name).and_return(true)
			@fast_pencil_quiz.should_receive(:dictionary_file_name).any_number_of_times.and_return(@dictionary_file_name)
			@fast_pencil_quiz.should_receive(:questions_file_name).and_return(@questions_file_name)
			@fast_pencil_quiz.should_receive(:answers_file_name).and_return(@answers_file_name)
			File.should_receive(:open).with(@dictionary_file_name, "r").and_return(@dictionary_mock_file)
			File.should_receive(:open).with(@questions_file_name, "w").and_return(@questions_mock_file)
			File.should_receive(:open).with(@answers_file_name, "w").and_return(@answers_mock_file)
			@dictionary_mock_file.should_receive(:close).and_return(true)
			@questions_mock_file.should_receive(:close).and_return(true)
			@answers_mock_file.should_receive(:close).and_return(true)
		end

		context "with an empty word list" do
			before(:each) do
				@words = []
				@dictionary_mock_file.stub(:each).with(any_args).and_return nil
				@fast_pencil_quiz.run
			end
			
			it { should_not_receive(:determine_unique_sequences) }
	
			context "q_and_a_candidates" do
				subject { @fast_pencil_quiz.q_and_a_candidates }
				it { should be_a Hash }
				it { should be_empty }
			end
		end

		context "with a valid word list" do
			before(:each) do
				@words = %w[arrows food carrots give me food]
				@sequences = %w[arro carr food give rots rows rrot rrow]
				@unique_sequences = @sequences - %w[arro food]
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
				@unique_words = (@containing_words - [%w[arrows carrots], %w[food food]]).flatten.sort
				@questions = []
				@answers   = []
				@dictionary_mock_file.should_receive(:each).with(no_args).and_yield("arrows").and_yield("food").and_yield("carrots").and_yield("give").and_yield("me").and_yield("food")
				@questions_mock_file.stub(:puts) {|sequence| @questions << sequence }
				@answers_mock_file.stub(:puts) {|word| @answers << word }
				@fast_pencil_quiz.run
			end
		
			context "q_and_a_candidates" do
				subject { @fast_pencil_quiz.q_and_a_candidates }
				it { should be_a Hash }
				it { should_not be_empty }
				its(:size) { should == 8 }
			end
		
			specify { @fast_pencil_quiz.q_and_a_candidates.keys.sort.should == @sequences }

			(0...8).each do |i|
				context "when testing sequence " + i.to_s do 
					specify { @fast_pencil_quiz.q_and_a_candidates[@sequences[i]].should == @containing_words[i] }
				end
			end

			context "when #determine_unique_sequences is run" do
				it "only unique sequences should be written to the questions file" do
					@questions.sort.should == @unique_sequences
				end

				it "only words for unique suequences should be written to the answers file" do
					@answers.sort.should == @unique_words
				end
			end
		end
	end
end

