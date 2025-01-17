class Dog
    attr_accessor :name, :breed
    attr_reader :id
  
    def initialize(name:, breed:, id: nil)
      @name = name
      @breed = breed
      @id = id
    end
  
    def self.create_table
      sql = <<-SQL
        CREATE TABLE IF NOT EXISTS dogs (
          id INTEGER PRIMARY KEY,
          name TEXT,
          breed TEXT
        )
      SQL
  
      DB[:conn].execute(sql)
    end 

    def save
      sql = <<-SQL
      INSERT INTO dogs(name,breed) VALUES (?,?)
      SQL
      DB[:conn].execute(sql,self.name,self.breed)
      @id = DB[:conn].execute("SELECT last_insert_rowid()FROM dogs")[0][0]
    end
    def self.drop_table
        sql = "DROP TABLE IF EXISTS dogs"
        DB[:conn].execute(sql)
      end

      def self.create(name:, breed:)
        dog = Dog.new(name: name, breed: breed)
        dog.save
        dog
      end  
      def self.new_from_db(row)
        self.new(id: row[0],name: row[1], breed: row[2])
      end
      def self.all
        sql = <<-SQL
          SELECT * FROM dogs
        SQL
        rows = DB[:conn].execute(sql)
        dogs = []
        rows.each do |row|
          dog = Dog.new(id: row[0], name: row[1], breed: row[2])
          dogs << dog
        end
        dogs
      end
      def self.find_by_name(name)
        sql = <<-SQL
        SELECT * FROM dogs WHERE name = ? LIMIT 1
        SQL
        DB[:conn].execute(sql,name).map do |row|
          self.new_from_db(row)
        end.first
      end

      def self.find(id)
        sql = <<-SQL
          SELECT * FROM dogs WHERE id = ? LIMIT 1
        SQL
      
        row = DB[:conn].execute(sql, id)[0]
        self.new_from_db(row)
      end
      
  end
  
