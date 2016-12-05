require 'byebug'
class Table


  def self.all
    rows = QuestionsDatabase.instance.execute("SELECT * FROM #{self::TABLE_NAME}")
    rows.map { |row| self.new(row) }
  end

  def self.find_by_id(id)
    rows = QuestionsDatabase.instance.execute(<<-SQL, id)
      SELECT
        *
      FROM
        #{self::TABLE_NAME}
      WHERE
        id = ?
    SQL
    self.new(rows.first)
  end

  def variables
    variables = self.instance_variables
    hash = {}
    variables.each do |variable|
      hash[variable.to_s[1..-1]] = instance_variable_get(variable)
    end
    hash
  end

  def save
    variables['id'].nil? ? create : update
  end

  def create
    raise "#{self} already in database" if variables[:id]
    QuestionsDatabase.instance.execute(<<-SQL, variables)
      INSERT INTO
        self.class::TABLE_NAME
      VALUES
        (#{variables.keys.join(", ")})
      SQL
    @id = QuestionsDatabase.instance.last_insert_row_id
  end


  def update
    # debugger
    raise "#{self} is not in database" unless variables[:id]
    pairs = variables.keys.map { |key| "#{key} = #{variables[key]}"}.join(", ")
    QuestionsDatabase.instance.execute(<<-SQL, variables)
      UPDATE
        self.class::TABLE_NAME
      SET
        #{pairs}
      WHERE
        id = id
      SQL
  end


end
