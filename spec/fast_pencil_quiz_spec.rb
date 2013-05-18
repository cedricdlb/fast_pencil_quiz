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

			(1...8).to_a.each do |i|
				context "when testing sequence " + i.to_s do 
					specify { @fast_pencil_quiz.q_and_a_candidates[@sequences[i]].should == @containing_words[i] }
				end
			end
		end
	end
end


