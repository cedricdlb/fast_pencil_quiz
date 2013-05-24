#!/usr/bin/ruby

class FastPencilQuiz
	attr_accessor :q_and_a_candidates
	attr_writer   :dictionary_file_name, :questions_file_name, :answers_file_name
	attr_accessor :dictionary_file,      :questions_file,      :answers_file

	def initialize
		@q_and_a_candidates = Hash.new {|hash, key| hash[key] = []}
	end

	def run
		if process_command_line
			open_files
			determine_unique_sequences if find_sequences > 0
			close_files
		end
	end

	FILE_NOT_SPECIFIED = 1
	FILE_NOT_EXISTANT  = 2
	FILE_NOT_PROPER    = 3
	FILE_NOT_READABLE  = 4

	def process_command_line
		were_inputs_ok = true
		were_inputs_ok = record_bad_input(FILE_NOT_SPECIFIED) unless dictionary_file_name
		were_inputs_ok = record_bad_input(FILE_NOT_EXISTANT) if were_inputs_ok && !File.exists?(dictionary_file_name)
		were_inputs_ok = record_bad_input(FILE_NOT_PROPER)   if were_inputs_ok && !File.file?(dictionary_file_name)
		were_inputs_ok = record_bad_input(FILE_NOT_READABLE) if were_inputs_ok && !File.readable?(dictionary_file_name)
		were_inputs_ok
	end

	def record_bad_input(message_type)
		puts case message_type
			 when FILE_NOT_SPECIFIED
				 "FAILURE: input file was not specified.  Please invoke with a path to a file containing one word per line"
			 when FILE_NOT_EXISTANT
				 "FAILURE: input file #{dictionary_file_name} does not exist"
			 when FILE_NOT_PROPER
				 "FAILURE: input file #{dictionary_file_name} is not a proper file"
			 when FILE_NOT_READABLE
				 "FAILURE: input file #{dictionary_file_name} is not readable"
			 else
				 "unknown error type"
			 end
		false
	end

	def find_sequences
		output_in_run_mode("input file is #{@dictionary_file_name}")
		@dictionary_file.each do |word|
			scan_limit = word.length - 4
			if scan_limit >= 0
				(0..scan_limit).each do |i|
					sequence = word[i,4]
					q_and_a_candidates[sequence] << word if sequence =~ /[a-zA-Z]{4}/
				end
			end
		end
		q_and_a_candidates.size
	end

	def determine_unique_sequences
		output_in_run_mode("Will write output to files #{questions_file_name} and #{answers_file_name}")
		q_and_a_candidates.each do |sequence, word_list|
			if 1 == word_list.length
				questions_file.puts(sequence)
				answers_file.puts(word_list[0])
			end
		end
	end

	def output_in_run_mode(message)
		puts message if File.join('bin', 'fast_pencil_quiz.rb') == $PROGRAM_NAME
	end

	def open_files
		@dictionary_file = File.open(dictionary_file_name, "r")
		@questions_file = File.open(questions_file_name, "w")
		@answers_file = File.open(answers_file_name, "w")
	end

	def close_files
		@dictionary_file.close
		@questions_file.close
		@answers_file.close
	end

	def dictionary_file_name
		@dictionary_file_name ||= ARGV.shift
		@dictionary_file_name
	end

	def questions_file_name
		unless @questions_file_name
			@base_name ||= File.basename(dictionary_file_name, ".*")
			@questions_file_name = File.join(File.dirname(dictionary_file_name), "#{@base_name}.questions.txt")
		end
		@questions_file_name
	end

	def answers_file_name
		unless @answers_file_name
			@base_name ||= File.basename(dictionary_file_name, ".*")
			@answers_file_name = File.join(File.dirname(dictionary_file_name), "#{@base_name}.answers.txt")
		end
		@answers_file_name
	end
end
