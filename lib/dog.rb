require 'pry'
class Dog

  attr_accessor :name, :breed
  attr_reader :id

  def initialize(params)
      self.name = params[:name]
      self.breed = params[:breed]
      if params[:id]
        @id = params[:id]
      end
  end


  def self.create_table
    sql =  <<-SQL
      CREATE TABLE IF NOT EXISTS dogs (
        id INTEGER PRIMARY KEY,
        name TEXT,
        breed TEXT
        )
    SQL
    DB[:conn].execute(sql)
  end

  def self.drop_table
    DB[:conn].execute("DROP TABLE IF EXISTS dogs;")
  end

  def save
    if self.id
      return self.update
    end
    sql = <<-SQL
    INSERT INTO dogs
    (name, breed)
    VALUES (?, ?);
    SQL
    new_row = DB[:conn].execute(sql,self.name, self.breed)
    @id = DB[:conn].execute("SELECT last_insert_rowid() FROM dogs;")[0][0]
    self

  end

  def self.create(params)
    new_dog = self.new(params)
    new_dog.save
  end

  def self.find_by_id(id)
    new_row = DB[:conn].execute("SELECT * FROM dogs WHERE id = ?", id)[0]
    new_dog = self.new_from_db(new_row)
  end

  def self.new_from_db(row)
    # [0] is id, [1] is name, [2] is breed
    return nil if row.empty?
    new_dog = self.new({id: row[0], name: row[1], breed: row[2]})
  end

  def update
    sql = <<-SQL
    UPDATE dogs
    SET name = ?,
    breed = ?
    WHERE id = ?;
    SQL
    DB[:conn].execute(sql, self.name, self.breed, self.id)
    self

  end

  def self.find_by_name(name)
    sql = <<-SQL
    SELECT * FROM dogs
    WHERE name = ?;
    SQL
    new_row = DB[:conn].execute(sql,name)[0]
    self.new_from_db(new_row)
  end

  def self.find_or_create_by(params)
    possible_dog = DB[:conn].execute("SELECT * FROM dogs WHERE name = ? AND breed = ?;", params[:name],params[:breed])
    if !possible_dog.empty?
      possible_dog = possible_dog[0]
      new_dog = self.new_from_db(possible_dog)
    else
      new_dog = self.create(params)
    end
    new_dog

  end


end # of class
