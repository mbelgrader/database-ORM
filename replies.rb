require_relative 'database'
require_relative 'tables'

class Reply < Table
  attr_accessor :id, :questions_id, :parent_reply_id, :users_id, :body
  TABLE_NAME = 'replies'

  def initialize(options)
    @id = options['id']
    @questions_id = options['questions_id']
    @parent_reply_id = options['parent_reply_id']
    @users_id = options['users_id']
    @body = options['body']
  end

  def author
    User.find_by_id(@users_id)
  end

  def question
    Question.find_by_id(@questions_id)
  end

  def parent_reply
    Reply.find_by_id(@parent_reply_id)
  end

  def child_replies
    Reply.all.select { |reply| reply.parent_reply_id == @id }
  end

  # def save
  #   @id.nil? ? create : update
  # end
  #
  # def create
  #   raise "#{self} already in database" if @id
  #   QuestionsDatabase.instance.execute(<<-SQL, @questions_id, @parent_reply_id, @users_id, @body)
  #     INSERT INTO
  #       replies(questions_id, parent_reply_id, users_id, body)
  #     VALUES
  #       (?, ?, ?, ?)
  #     SQL
  #   @id = QuestionsDatabase.instance.last_insert_row_id
  # end
  #
  # def update
  #   raise "#{self} is not in database" unless @id
  #   QuestionsDatabase.instance.execute(<<-SQL, @questions_id, @parent_reply_id, @users_id, @body, @id)
  #     UPDATE
  #       replies
  #     SET
  #       questions_id = ?, parent_reply_id = ?, users_id = ?, body = ?
  #     WHERE
  #       id = ?
  #     SQL
  # end

end
