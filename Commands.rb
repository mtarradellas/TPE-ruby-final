require 'date'
require_relative 'InvalidCommandException.rb'
require_relative 'InvalidDateException.rb'
require_relative 'InvalidTaskException.rb'

class Commands

	ADD = 1
	LIST_ALL = 2
	LIST_DATE = 3
	LIST_GROUPS = 4
	LIST_OVERDUE = 5
	LIST_A_GROUP = 6
	LIST_THIS_WEEK = 7
	COMPLETE = 8
	ARCHIVE	 = 9
	SAVE = 10
	OPEN = 11
	FIND = 12

	@string
	@date

	def initialize
	end

	def analize(command)
		@string = command
	end

	def obtain_command
		
		if @string.start_with? "add "
			@string = @string[4..-1]
			command = ADD

		elsif @string.start_with? "list"
			if @string == "list"
				command = LIST_ALL
			elsif @string[4..-1] == " group"
				command = LIST_GROUPS
			elsif @string[4..5] == " +"
				@string = @string[5..-1]
				command = LIST_A_GROUP
			elsif @string[4..-1] == " overdue"
				command = LIST_OVERDUE
			elsif @string[4..-1] == " due this-week"
				@date = Date.today
				command = LIST_THIS_WEEK
			elsif @string[4..8] == " due "
				command = LIST_DATE
			else raise InvalidCommand
			end

		elsif @string.start_with? "complete "
			@string = @string[9..-1]
			raise InvalidTask unless @string.length == @string.to_i.to_s.length
			command = COMPLETE

		elsif @string == "ac"
			command = ARCHIVE

		elsif @string.start_with? "save "
			command = SAVE
			@string = @string[5..-1]

		elsif @string.start_with? "open "
			command = OPEN
			@string = @string[5..-1]

		elsif @string.start_with? "find "
			command = FIND
			@string = @string[5..-1]
		else
			raise InvalidCommand
		end
		command
	end

	def obtain_date

		idx = @string.index ' due '		
		unless idx.nil?
			@date = @string[idx+5..-1]
			@string = @string[0...idx]
			return validate_date
		end
		nil
	end

	def validate_date
		return @date = Date.today if @date == "today"
		return @date = Date.today - 1 if @date == "yesterday"
		return @date = Date.today + 1 if @date == "tomorrow"

		raise InvalidDate unless @date.length == 10
		raise InvalidDate if (/\d{2}\/\d{2}\/\d{4}/ =~ @date).nil?

		year = @date[6..9].to_i
		month = @date[3..4].to_i
		day = @date[0..1].to_i
		
		raise InvalidDate unless Date.valid_date?(year, month, day)
		
		@date = Date.new(year, month, day)
	end

	def obtain_group
		if @string.start_with? "+"
			group_end = @string.index(" ")
			raise InvalidTask if (group_end.nil? || group_end == 1)
			group = @string[0...group_end]
			@string = @string[group_end+1..-1]
			return group
		end
		nil
	end

	def obtain_string
		raise InvalidTask if (@string.start_with? "due " or @string == "due")
		@string
	end

end