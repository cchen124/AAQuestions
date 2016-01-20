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

    result = QuestionsDatabase.instance.execute(<<-SQL, author_id)
      SELECT
        *
      FROM
        questions
      WHERE
        id = ?
    SQL

    Questions.new(result.first)

  end

  def author
    author_id = QuestionsDatabase.instance.execute(<<-SQL, associated_author_id)
      SELECT
        id
      FROM
        questions
      WHERE
        id = ?
    SQL

    Users.find_by_id(author_id.first['id'])
  end

  def replies
    id_of_interest = QuestionsDatabase.instance.execute(<<-SQL, id)
      SELECT
        id
      FROM
        questions
      WHERE
        id = ?
    SQL

    Replies.find_by_question_id(id_of_interest.first['id'])
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

  def self.find_by_name(fname, lname)
    result = QuestionsDatabase.instance.execute(<<-SQL, fname, lname)
      SELECT
        *
      FROM
        users
      WHERE
        fname = ? AND lname = ?
    SQL
    Users.new(result.first)
  end

  def authored_questions


    poi_id = QuestionsDatabase.instance.execute(<<-SQL, fname, lname)
      SELECT
        id
      FROM
        users
      WHERE
        fname = ? AND lname = ?
    SQL
    Questions.find_by_author_id(poi_id.first['id'])
  end

  def authored_replies

    replies = QuestionsDatabase.instance.execute(<<-SQL, fname, lname)
      SELECT
        id
      FROM
        users
      WHERE
        fname = ? AND lname = ?

    SQL

    Replies.find_by_id(replies.first['id'])

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

  def self.find_by_user_id(user_id)
      Replies.find_by_id(user_id)
  end

  def self.find_by_question_id(question_id)
    result = QuestionsDatabase.instance.execute(<<-SQL, question_id)
      SELECT
        *
      FROM
        replies
      WHERE
        subject_question_id = ?
    SQL

    Replies.new(result.first)
  end

  attr_accessor :id, :subject_question_id, :parent_reply_id, :author_id, :body

  def initialize(options = {})
    @id = options["id"]
    @subject_question_id = options['subject_question_id']
    @parent_reply_id = options['parent_reply_id']
    @author_id = options['author_id']
    @body = options['body']
  end

  def author
    my_id = QuestionsDatabase.instance.execute(<<-SQL, author_id)
      SELECT
        author_id
      FROM
        replies
      WHERE
        author_id = ?
    SQL

    Users.find_by_id(my_id.first['author_id'])
  end

  def question
    subject_id = QuestionsDatabase.instance.execute(<<-SQL, subject_question_id)
      SELECT
        subject_question_id
      FROM
        replies
      WHERE
        subject_question_id = ?
    SQL

    Questions.find_by_id(subject_id.first['subject_question_id'])
  end

  def parent_reply
    parent_reply = QuestionsDatabase.instance.execute(<<-SQL, parent_reply_id)
      SELECT
        parent_reply_id
      FROM
        replies
      WHERE
        parent_reply_id = ?
    SQL

    Replies.find_by_id(parent_reply.first['parent_reply_id'])
  end

  def child_replies
    child_reply = QuestionsDatabase.instance.execute(<<-SQL, id)
      SELECT
        id
      FROM
        replies
      WHERE
        parent_reply_id = ?
    SQL

    Replies.find_by_id(child_reply.first['id'])

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
