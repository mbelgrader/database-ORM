require_relative 'database'
require_relative 'questions'
require_relative 'question_follows'
require_relative 'tables'

class Like < Table
  attr_accessor :users_id, :questions_id, :id
  TABLE_NAME = 'question_likes'

  def self.likers_for_question_id(question_id)
    likers = QuestionsDatabase.instance.execute(<<-SQL, question_id)
      SELECT
        users.*
      FROM
        question_likes
      JOIN
        users
        ON users.id = question_likes.users_id
      WHERE
        questions_id = ?
      SQL
    likers.map { |liker| Like.new(liker) }
  end

  def self.num_likes_for_question_id(question_id)
    count = QuestionsDatabase.instance.execute(<<-SQL, question_id)
      SELECT
        COUNT(users.id)
      FROM
        question_likes
      JOIN
        users
        ON users.id = question_likes.users_id
      WHERE
        questions_id = ?
      SQL
    count.first.values.first
  end

  def self.liked_questions_for_user_id(user_id)
    questions = QuestionsDatabase.instance.execute(<<-SQL, user_id)
      SELECT
        questions.*
      FROM
        question_likes
      JOIN questions
        ON questions.id = question_likes.questions_id
      WHERE
        question_likes.users_id = ?
      SQL

    questions.map { |question| Question.new(question) }
  end

  def self.most_liked_questions(n)
    questions = QuestionsDatabase.instance.execute(<<-SQL, n)
      SELECT
        questions.*
      FROM
        question_likes
      JOIN
        questions ON questions.id =question_likes.questions_id
      GROUP BY
        questions_id
      ORDER BY
        COUNT(questions_id)
      LIMIT
        ?
    SQL
    questions.map { |q| Question.new(q) }
  end


  def initialize(options)
    @id = options['id']
    @users_id = options['users_id']
    @questions_id = options['questions_id']
  end

end
