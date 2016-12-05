require_relative 'database'
require_relative 'users'
require_relative 'tables'

class Follow < Table
  attr_accessor :id, :questions_id, :users_id
  TABLE_NAME = 'question_follows'

  def self.followers_for_question_id(question_id)
    followers = QuestionsDatabase.instance.execute(<<-SQL, question_id)
      SELECT
        *
      FROM
        question_follows
      JOIN
        users
        ON
          users.id = question_follows.users_id
      WHERE
        question_follows.questions_id = ?
    SQL

    followers.map { |follower| User.new(follower)}
  end

  def self.followed_questions_for_user_id(user_id)
    questions = QuestionsDatabase.instance.execute(<<-SQL, user_id)
      SELECT
        *
      FROM
        question_follows
      JOIN
        questions
      ON
        question_follows.questions_id = questions.id
      WHERE
        question_follows.users_id = ?
    SQL

    questions.map { |question| Question.new(question) }
  end

  def self.most_followed_questions(n)
    followed_questions = QuestionsDatabase.instance.execute(<<-SQL, n)
      SELECT
        questions.*
      FROM
        question_follows
      JOIN
        questions
          ON
            questions.id = question_follows.questions_id
      GROUP BY
        question_follows.questions_id
      LIMIT
        ?
    SQL

    followed_questions.map { |question| Question.new(question) }
  end

  def initialize(options)
    @id = options['id']
    @questions_id = options['questions_id']
    @users_id = options['users_id']
  end

end
