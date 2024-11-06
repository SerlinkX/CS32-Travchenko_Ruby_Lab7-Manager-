require 'json'
require 'date'

# Клас для збереження даних задачі
class Task
  attr_accessor :title, :deadline, :completed

  def initialize(title, deadline, completed = false)
    @title = title
    @deadline = Date.parse(deadline)
    @completed = completed
  end

  def to_h
    {
      title: @title,
      deadline: @deadline.to_s,
      completed: @completed
    }
  end

  def self.from_h(hash)
    Task.new(hash['title'], hash['deadline'], hash['completed'])
  end
end

# Клас для управління задачами
class TaskManager
  def initialize(filename = 'tasks.json')
    @filename = filename
    @tasks = load_tasks
  end

  def add_task(title, deadline)
    task = Task.new(title, deadline)
    @tasks << task
    save_tasks
  end

  def remove_task(index)
    @tasks.delete_at(index)
    save_tasks
  end

  def edit_task(index, title: nil, deadline: nil, completed: nil)
    task = @tasks[index]
    task.title = title if title
    task.deadline = Date.parse(deadline) if deadline
    task.completed = completed unless completed.nil?
    save_tasks
  end

  def filter_tasks(status: nil, due_date: nil)
    result = @tasks
    result = result.select { |task| task.completed == status } unless status.nil?
    result = result.select { |task| task.deadline <= Date.parse(due_date) } if due_date
    result
  end

  def list_tasks
    @tasks.each_with_index do |task, index|
      puts "#{index + 1}. #{task.title} | Deadline: #{task.deadline} | Completed: #{task.completed}"
    end
  end

  private

  def save_tasks
    File.write(@filename, JSON.pretty_generate(@tasks.map(&:to_h)))
  end

  def load_tasks
    return [] unless File.exist?(@filename)
    JSON.parse(File.read(@filename)).map { |task_data| Task.from_h(task_data) }
  end
end

# Основний консольний інтерфейс
class ConsoleApp
  def initialize
    @manager = TaskManager.new
  end

  def run
    loop do
      puts "\nTask Manager Menu:"
      puts "1. Add Task"
      puts "2. Edit Task"
      puts "3. Remove Task"
      puts "4. List Tasks"
      puts "5. Filter Tasks"
      puts "6. Exit"
      print "Choose an option: "
      choice = gets.chomp.to_i

      case choice
      when 1
        add_task
      when 2
        edit_task
      when 3
        remove_task
      when 4
        list_tasks
      when 5
        filter_tasks
      when 6
        break
      else
        puts "Invalid option. Please choose again."
      end
    end
  end

  private

  def add_task
    print "Enter task title: "
    title = gets.chomp
    print "Enter task deadline (YYYY-MM-DD): "
    deadline = gets.chomp
    @manager.add_task(title, deadline)
    puts "Task added successfully."
  end

  def edit_task
    list_tasks
    print "Enter task number to edit: "
    index = gets.chomp.to_i - 1
    print "Enter new title (leave blank to keep current): "
    title = gets.chomp
    print "Enter new deadline (YYYY-MM-DD, leave blank to keep current): "
    deadline = gets.chomp
    print "Is the task completed? (yes/no, leave blank to keep current): "
    completed_input = gets.chomp
    completed = case completed_input.downcase
                when 'yes' then true
                when 'no' then false
                else nil
                end
    @manager.edit_task(index, title: title.empty? ? nil : title, deadline: deadline.empty? ? nil : deadline, completed: completed)
    puts "Task updated successfully."
  end

  def remove_task
    list_tasks
    print "Enter task number to remove: "
    index = gets.chomp.to_i - 1
    @manager.remove_task(index)
    puts "Task removed successfully."
  end

  def list_tasks
    @manager.list_tasks
  end

  def filter_tasks
    print "Filter by completion status (completed/not completed/leave blank): "
    status_input = gets.chomp
    status = case status_input.downcase
             when 'completed' then true
             when 'not completed' then false
             else nil
             end
    print "Filter by due date (YYYY-MM-DD, leave blank for no filter): "
    due_date = gets.chomp
    tasks = @manager.filter_tasks(status: status, due_date: due_date.empty? ? nil : due_date)
    tasks.each_with_index do |task, index|
      puts "#{index + 1}. #{task.title} | Deadline: #{task.deadline} | Completed: #{task.completed}"
    end
  end
end

# Запуск програми
app = ConsoleApp.new
app.run
