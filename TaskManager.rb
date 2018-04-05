require_relative 'Sets.rb'
require_relative 'Task.rb'
class TaskManager

	def initialize
		@tasks_hash = Hash.new
		@sets = Sets.new
		@id_counter = 0
	end

	def add(task_name, due_date, group_name)
		@id_counter += 1
		@tasks_hash[@id_counter] = Task.new(task_name, @id_counter, due_date, group_name)
		@sets.add(@tasks_hash[@id_counter])
		@id_counter 
	end

	def obtain_all_list
		@sets.obtain_all_list
	end

	def obtain_groups_list
		@sets.obtain_groups_list
	end

	def obtain_dates_list
	 	obtain_all_list.delete_if{|task| task.due_date.nil?}		
	end

	def format_group(group_name)
		@sets.format_group group_name
	end

	def complete(id)
		raise InvalidTask unless @tasks_hash.key? id
		return nil if @tasks_hash[id].completed?
		@tasks_hash[id].complete
		@tasks_hash[id].task_name
	end

	def archive
		@sets.archive
		@tasks_hash.delete_if{|task| @tasks_hash[task].completed?}
	end

end