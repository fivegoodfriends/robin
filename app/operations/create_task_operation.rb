require "operation"

class CreateTaskOperation < Operation::Base
  def call(params)
    list = List.find(params[:list_id])
    task = list.tasks.build(description: params[:description], user: list.next_user)
    if task.save
      SlackMessage.new.post_task_assigned(task: task)
      success
    else
      failure
    end
  end
end
