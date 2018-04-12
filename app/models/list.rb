class List < ApplicationRecord
  has_many :tasks, dependent: :destroy
  has_and_belongs_to_many :users

  validates :name, presence: true
  validates :slack_channel_id, presence: true

  before_create :generate_webhook_token
  
  def next_user(excluded_user_name = nil)
    list_users = users.alphabetically.cycle(2).to_a
    latest_task_user = tasks.not_archived.newest.first&.user
    next_index = list_users.index(latest_task_user)&.succ || 0

    next_user =
      if list_users[next_index]&.slack_name == excluded_user_name
        list_users[next_index.succ]
      else
        list_users[next_index]
      end

    next_user || list_users.first
  end

  private

  def generate_webhook_token
    loop do
      new_webhook_token = SecureRandom.hex(64)
      if List.where(webhook_token: new_webhook_token).empty?
        self.webhook_token = new_webhook_token
        break
      end
    end
  end
end
