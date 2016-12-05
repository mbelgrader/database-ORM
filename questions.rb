require_relative 'database'
require_relative 'users'
require_relative 'replies'
require_relative 'tables'

class Question < Table
  attr_accessor :id, :title, :body, :author_id
  TABLE_NAME = 'questions'

  def self.find_by_author_id(author_id)
    questions = QuestionsDatabase.instance.execute(<<-SQL, author_id)
      SELECT
        *
      FROM
        questions
      WHERE
        author_id = ?
    SQL
    Question.new(questions.first)
  end

  def self.most_liked(n)
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
    @title = options['title']
    @body = options['body']
    @author_id = options['author_id']
  end

  def author
    User.find_by_id(@author_id)
  end

  def replies
    Reply.find_by_question_id(@id)
  end

  def likers
    Like.likers_for_question_id(@id)
  end

  def num_likes
    Like.num_likes_for_question_id(@id)
  end

  def save
    @id.nil? ? create : update
  end

  def create
    raise "#{self} already in database" if @id
    QuestionsDatabase.instance.execute(<<-SQL, @title, @body, @author_id)
      INSERT INTO
        questions(tite, body, author_id)
      VALUES
        (?, ?, ?)
        SQL
    @id = QuestionsDatabase.instance.last_insert_row_id
  end

  def update
    raise "#{self} is not in database" unless @id
    QuestionsDatabase.instance.execute(<<-SQL, @title, @body, @author_id, @id)
      UPDATE
        questions
      SET
        title = ?, body = ?, author_id = ?
      WHERE
        id = ?
      SQL
  end




end
