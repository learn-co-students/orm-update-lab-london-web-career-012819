require_relative "../config/environment.rb"

class Student

  attr_accessor :id, :name, :grade

  # Remember, you can access your database connection anywhere in this class
  #  with DB[:conn]

  def initialize(id = nil, name, grade)
    @id, @name, @grade = id, name, grade
  end

  def self.create_table
    sql = <<-EOT
      CREATE TABLE IF NOT EXISTS students(
        id INTEGER PRIMARY KEY,
        name TEXT,
        grade INTEGER)
    EOT
    DB[:conn].execute(sql)
  end

  def self.drop_table
    sql = "DROP TABLE students"
    DB[:conn].execute(sql)
  end

  def save
    if @id
      update
    else
      sql = <<-EOT
        INSERT INTO students (name, grade)
        VALUES (?,?)
      EOT
      DB[:conn].execute(sql, @name, @grade)
      @id = DB[:conn].execute("SELECT last_insert_rowid() FROM students")[0][0]
    end
  end

  def self.create(name, grade)
    student = Student.new(name, grade)
    student.save
    student
  end

  def self.new_from_db(row)
    Student.new(row[0], row[1], row[2])
  end

  def self.find_by_name(name)
    sql = "SELECT * FROM students WHERE name =? LIMIT 1"
    row = DB[:conn].execute(sql, name).first
    new_from_db(row)
  end

  def update
    sql = <<-EOT
      UPDATE students
      SET name = ?, grade = ?
      WHERE id = ?
    EOT
    DB[:conn].execute(sql, @name, @grade, @id)
  end
end
