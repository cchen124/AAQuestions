require 'singleton'
require 'sqlite3'
require 'byebug'

class QuestionsDatabase < SQLite3::Database
  include Singleton

  def initialize
    super('questions.db')
    self.results_as_hash = true
    self.type_translation = true
  end
end

class Questions
  def self.all
    results = QuestionsDatabase.instance.execute('SELECT * FROM questions')
    results.map { |result| Questions.new(result) }
  end

  def self.find_by_id(id)
    results = QuestionsDatabase.instance.execute(<<-SQL, id)
      SELECT
        *
      FROM
        questions
      WHERE
        id = ?
    SQL

    Questions.new(results.first)
  end

  def self.create(title, body, associated_author_id)

    QuestionsDatabase.instance.execute(<<-SQL, title, body, associated_author_id)
    INSERT INTO
    questions (title, body, associated_author_id)
    VALUES
    (?, ?, ?)
    SQL

    id = QuestionsDatabase.instance.last_insert_row_id
    Questions.find_by_id(id)
  end

  def self.find_by_author_id(author_id)

    QuestionsDatabase.instance.execute(<<-SQL, author_id)
      SELECT
        *
      FROM
        questions
      WHERE
        id = ?
    SQL

  end

  attr_accessor :id, :title, :body, :associated_author_id

  def initialize(options = {})
    @id = options["id"]
    @title = options['title']
    @body = options['body']
    @associated_author_id = options['associated_author_id']
  end
end


###################################################################
class Users
  def self.all
    results = QuestionsDatabase.instance.execute('SELECT * FROM users')
    results.map { |result| Users.new(result) }
  end

  def self.find_by_id(id)
    result = QuestionsDatabase.instance.execute(<<-SQL, id)
      SELECT
        *
      FROM
        users
      WHERE
        id = ?
    SQL
    Users.new(result.first)
  end

  def self.create(fname, lname)
    # raise 'already saved!' unless self.id.nil?

    QuestionsDatabase.instance.execute(<<-SQL, fname, lname)
    INSERT INTO
    users (fname, lname)
    VALUES
    (?, ?)
    SQL

    id = QuestionsDatabase.instance.last_insert_row_id
    Users.find_by_id(id)
  end

  attr_accessor :id, :fname, :lname

  def initialize(options = {})
    @id = options['id']
    @fname = options['fname']
    @lname = options['lname']
  end
end


###################################################################
class QuestionsFollows
  def self.all
    results = QuestionsDatabase.instance.execute('SELECT * FROM question_follows')
    results.map { |result| QuestionsFollows.new(result) }
  end

  def self.find_by_id(id)
    result = QuestionsDatabase.instance.execute(<<-SQL, id)
      SELECT
        *
      FROM
        question_follows
      WHERE
        id = ?
    SQL

    QuestionsFollows.new(result.first)
  end

  def self.create(user_id, question_id)
    # raise 'already saved!' unless self.id.nil?

    QuestionsDatabase.instance.execute(<<-SQL, user_id, question_id)
      INSERT INTO
        question_follows (user_id, question_id)
      VALUES
        (?, ?)
    SQL

    @id = QuestionsDatabase.instance.last_insert_row_id
    QuestionsFollows.find_by_id(@id)
  end

  attr_accessor :id, :user_id, :question_id

  def initialize(options = {})
    p options
    @id = options["id"]
    @user_id = options['user_id']
    @question_id = options['question_id']

    # @id, @user_id, @question_id = options.values_at("id", "user_id", "question_id")
  end
end
##################################################################

class Replies
  def self.all
    results = QuestionsDatabase.instance.execute('SELECT * FROM replies')
    results.map { |result| Replies.new(result) }
  end

  def self.find_by_id(id)
    result = QuestionsDatabase.instance.execute(<<-SQL, id)
      SELECT
        *
      FROM
        replies
      WHERE
        id = ?
    SQL

    Replies.new(result.first)
  end

  def self.create(subject_question_id, parent_reply_id, author_id, body)
    # raise 'already saved!' unless self.id.nil?

    QuestionsDatabase.instance.execute(<<-SQL, subject_question_id, parent_reply_id, author_id, body)
      INSERT INTO
        replies (subject_question_id, parent_reply_id, author_id, body)
      VALUES
        (?, ?, ?, ?)
    SQL

    @id = QuestionsDatabase.instance.last_insert_row_id
    Replies.find_by_id(@id)
  end


  attr_accessor :id, :subject_question_id, :parent_reply_id, :author_id, :body

  def initialize(options = {})
    @id = options["id"]
    @subject_question_id = options['subject_question_id']
    @parent_reply_id = options['parent_reply_id']
    @author_id = options['author_id']
    @body = options['body']
  end
end


###################################################################

class QuestionsLikes
  def self.all
    results = QuestionsDatabase.instance.execute('SELECT * FROM questions_likes')
    results.map { |result| QuestionsLikes.new(result) }
  end

  def self.find_by_id(id)
    result = QuestionsDatabase.instance.execute(<<-SQL, id)
      SELECT
        *
      FROM
        questions_likes
      WHERE
        id = ?
    SQL

    QuestionsLikes.new(result.first)

  end

  def self.create(user_id, question_id)
    # raise 'already saved!' unless self.id.nil?

    QuestionsDatabase.instance.execute(<<-SQL, user_id, question_id)
      INSERT INTO
        questions_likes (user_id, question_id)
      VALUES
        (?, ?)
    SQL

    @id = QuestionsDatabase.instance.last_insert_row_id
    QuestionsLikes.find_by_id(@id)
  end

  attr_accessor :id, :user_id, :question_id

  def initialize(options = {})
    @id = options["id"]
    @user_id = options['user_id']
    @question_id = options['question_id']
  end
end
