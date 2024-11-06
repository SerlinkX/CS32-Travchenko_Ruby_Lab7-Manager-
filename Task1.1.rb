require 'rspec'
require_relative 'Task1'

describe TaskManager do
  let(:manager) { TaskManager.new('test_tasks.json') }

  before(:each) do
    manager.instance_variable_set(:@tasks, [])
    manager.send(:save_tasks)
  end

  after(:each) do
    File.delete('test_tasks.json') if File.exist?('test_tasks.json')
  end

  it 'adds a task' do
    manager.add_task('Test Task', '2023-12-01')
    expect(manager.instance_variable_get(:@tasks).size).to eq(1)
  end

  it 'removes a task' do
    manager.add_task('Test Task', '2023-12-01')
    manager.remove_task(0)
    expect(manager.instance_variable_get(:@tasks).size).to eq(0)
  end

  it 'edits a task' do
    manager.add_task('Test Task', '2023-12-01')
    manager.edit_task(0, title: 'Updated Task', completed: true)
    task = manager.instance_variable_get(:@tasks)[0]
    expect(task.title).to eq('Updated Task')
    expect(task.completed).to eq(true)
  end

  it 'filters tasks by status' do
    manager.add_task('Completed Task', '2023-12-01')
    manager.add_task('Incomplete Task', '2023-12-02')
    manager.edit_task(0, completed: true)
    completed_tasks = manager.filter_tasks(status: true)
    expect(completed_tasks.size).to eq(1)
    expect(completed_tasks[0].title).to eq('Completed Task')
  end
end
