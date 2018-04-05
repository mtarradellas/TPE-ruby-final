class GroupsHash
	
	def initialize
		@groups_hash = Hash.new
	end

	def add(task)
		if @groups_hash.key? task.group_name
			@groups_hash[task.group_name] << task 
		else 
			new_group = SortedSet.new
			new_group << task
			@groups_hash[task.group_name] = new_group
		end
	end

	def archive
		@groups_hash.each_value{|group_set| group_set.delete_if{|task| task.completed?}}
		@groups_hash.delete_if{|group_name, group_set| group_set.empty?}
	end

	def format_group(group_name)
		raise InvalidCommand unless @groups_hash.key? group_name
		format_string = group_name[1..-1] + "\n"
		@groups_hash[group_name].each{|task| format_string = format_string + task.format_group unless task.completed?}
		@groups_hash[group_name].each{|task| format_string = format_string + task.format_group if task.completed?}
		format_string
	end

	def obtain_groups_list
		@groups_hash.keys.dup
	end

end
