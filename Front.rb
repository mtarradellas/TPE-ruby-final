require 'yaml'
require_relative 'TaskManager.rb'
require_relative 'Commands.rb'
require_relative 'InvalidFileException.rb'
require_relative 'InvalidCommandException.rb'

class Front

	def initialize
		@task_manager = TaskManager.new
		@command_manager = Commands.new
	end

	def save_file(file_name, task_manager)
		File.open("#{file_name}.yaml", "w") { |file| file.write(@task_manager.to_yaml)}
	end

	def open_file(file_name)
		YAML.load(File.read("#{file_name}"))
	end

	def prints(list)
		list.each{|task| puts task.format_all unless task.completed?}
		list.each{|task| puts task.format_all if task.completed?}
	end

	def execute
		
		while (command = (command = gets).gsub(/\s+/, " ").strip) != "exit"
		begin

			@command_manager.analize command
			action = @command_manager.obtain_command
			case action
			when Commands::ADD
				date = @command_manager.obtain_date
				group = @command_manager.obtain_group
				task = @command_manager.obtain_string
				id = @task_manager.add(task, date, group)
				puts "Todo [#{id}: #{task}] added."
			when Commands::COMPLETE
				id = @command_manager.obtain_string.to_i
				task = @task_manager.complete id
				puts "Todo [#{id}: #{task}] completed." unless task.nil?
				puts "Task #{id} already completed!" if task.nil?
			when Commands::LIST_ALL
				all_list = @task_manager.obtain_all_list
				puts 'All' unless all_list.empty?
				puts 'No tasks on list' if all_list.empty?
				prints(all_list)
			when Commands::LIST_GROUPS
				groups_list = @task_manager.obtain_groups_list
				puts 'No groups available' if groups_list.empty?
				groups_list.each{|group_name| puts @task_manager.format_group group_name }
			when Commands::LIST_A_GROUP
				group_name = @command_manager.obtain_string
				puts @task_manager.format_group group_name
			when Commands::LIST_THIS_WEEK
				dates_list = @task_manager.obtain_dates_list
				dates_list = dates_list.delete_if{|task| (task.due_date < Date.today) || ((task.due_date.wday < Date.today.wday) || (task.due_date > (Date.today + 6)))}
				puts "All" unless dates_list.empty?
				puts "No tasks on list" if dates_list.empty?
				prints(dates_list)
			when Commands::LIST_OVERDUE
				dates_list = @task_manager.obtain_dates_list
				dates_list = dates_list.delete_if{|task| task.due_date >= Date.today}
				puts "All" unless dates_list.empty?
				puts "No tasks on list" if dates_list.empty?	 	
				prints(dates_list)
			when Commands::LIST_DATE
				date = @command_manager.obtain_date
				dates_list = @task_manager.obtain_dates_list
				dates_list = dates_list.delete_if{|task| task.due_date != date }
				puts "All" unless dates_list.empty?
				puts "No tasks on list" if dates_list.empty?
				prints(dates_list)	
			when Commands::FIND
				find = @command_manager.obtain_string
				all_list = @task_manager.obtain_all_list
				all_list = all_list.delete_if{|task| !(task.task_name.upcase.include? find.upcase)}
				puts "No tasks on list" if all_list.empty?
				prints(all_list)
			when Commands::ARCHIVE
				@task_manager.archive
				puts "All completed todos have been archived!"
			when Commands::SAVE
				file = @command_manager.obtain_string
				save_file(file, @task_manager)
				puts "File save successful!"
			when Commands::OPEN
				file = @command_manager.obtain_string
				raise InvalidFile unless File.exist? file
				puts "Opening #{file} file will delete all current unsaved data, continue? (yes/no)"
				while ((answer = (answer = gets).gsub(/\s+/, " ").strip) != "yes" && answer != "no")
					puts "Enter yes or no"
				end
				if answer == "yes"
					@task_manager = open_file file 
					puts "#{file} file opened"
				elsif answer == "no"
					puts "File was not opened"
				end
			end

		rescue Exception => e 
			puts e
		end
		end
	end
end