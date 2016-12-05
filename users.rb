require_relative 'database'
require_relative 'questions'
require_relative 'replies'
require_relative 'tables'

class User < Table
  attr_accessor :id, :fname, :lname
  TABLE_NAME = 'users'

  def self.find_by_name(fname, lname)
    users = QuestionsDatabase.instance.execute(<<-SQL, fname, lname)
      SELECT
        *
      FROM
        users
      WHERE
        fname = ? AND
        lname = ?
    SQL
    User.new(users.first)
  end

  def initialize(options)
    @id = options['id']
    @fname = options['fname']
    @lname = options['lname']
  end

  def authored_questions
    Question.find_by_author_id(@id)
  end

  def authored_replies
    Reply.find_by_user_id(@id)
  end

  def followed_questions
    Follow.followed_questions_for_user_id(@id)
  end

  def liked_questions
    Like.liked_questions_for_user_id(@id)
  end

  def average_karma
    QuestionsDatabase.instance.execute(<<-SQL, @id)
      SELECT
        (CAST(COUNT(DISTINCT question_likes.questions_id) AS FLOAT) / COUNT(questions.id)) AS average_karma
      FROM
        questions
      LEFT JOIN
        question_likes ON questions.id = question_likes.questions_id
      WHERE
        questions.author_id = ?
    SQL
  end

  def save
    @id.nil? ? create : update
  end

  def create
    raise "#{self} already in the database" if @id
    QuestionsDatabase.instance.execute(<<-SQL, @fname, @lname)
      INSERT INTO
        users(fname, lname)
      VALUES
        (?, ?)
    SQL

    @id = QuestionsDatabase.instance.last_insert_row_id
  end

  def update
    raise "#{self} is not in database" unless @id
    QuestionsDatabase.instance.execute(<<-SQL, @fname, @lname, @id)
      UPDATE
        users
      SET
       fname = ?, lname = ?
      WHERE id = ?
    SQL
  end

end
