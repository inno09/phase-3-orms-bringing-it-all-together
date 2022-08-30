class Dog
    attr_accessor :name, :id, :breed

    def initialize(id: nil, name:, breed:)
        @id = id
        @name = name
        @breed = breed
    end

    ##CREATE THE TABLE
    def self.create_table
        sql = <<-SQL
        CREATE TABLE IF NOT EXISTS dogs(
            id INTEGER PRIMARY KEY,
            name TEXT,
            breed TEXT
        )
        SQL
        DB[:conn].execute(sql)
    end

    ##DROP THE DOG TABLE IF ANY EXISTS

    def self.drop_table
        sql = "DROP TABLE IF EXISTS dogs"
        DB[:conn].execute(sql)
    end

    ## SAVE THE CREATED TABLE ROW VALUES INTO THE DATABASE

    def save
        if self.id
          self.update
        else
          sql = <<-SQL
            INSERT INTO dogs (name, breed)
            VALUES (?, ?)
          SQL
          DB[:conn].execute(sql, self.name, self.breed)
          self.id = DB[:conn].execute("SELECT last_insert_rowid() FROM dogs")[0][0]
        end
        self
    end

    ## CREATE A NEW ROW OF VALUES TO THE TABLE

    def self.create(name:, breed:)
        dog = Dog.new(name: name, breed: breed)
        dog.save
    end

    ## CREATE NEW INSTANCE VALUES FROM THE DATABASE

    def self.new_from_db(row)
        self.new(id: row[0], name: row[1], breed: row[2])
    end

    ## RETURN ALL THE INSTANCES OF DOGS IN THE DATABASE

    def self.all
        sql = <<-SQL
        SELECT *
        FROM dogs;
        SQL

        DB[:conn].execute(sql).map do|row|
            self.new_from_db(row)
        end
    end

    #FIND AN INSTANCE IN THE DATABASE BY NAME

    def self.find_by_name(name)
        sql = <<-SQL
        SELECT * 
        FROM dogs 
        WHERE dogs.name = ?
        LIMIT 1;
        SQL

        DB[:conn].execute(sql, name).map do|row|
            self.new_from_db(row)
        end.first
    end

    ## FIND AN INSTANCE FROM THE DATABASE USING THE ID

    def self.find(id)
        sql = <<-SQL
        SELECT *
        FROM dogs
        WHERE dogs.id = ?
        LIMIT 1
        SQL

        DB[:conn].execute(sql,id).map do|row|
            self.new_from_db(row)
        end.first
    end

    # FIND OR CREATE BY

    def self.find_or_create_by(name:, breed:)
        sql = <<-SQL
        SELECT *
        FROM dogs
        WHERE name = ?
        WHERE breed = ?
        LIMIT 1
        SQL

       if DB[:conn].execute(sql, name, breed).first
        self.new_from_db(row)
       else
        self.create(name: name, breed: breed)
       end
    end

    def update
        sql = <<-SQL
        UPDATE dogs
        SET 
        name = ?
        breed = ?
        WHERE id = ?
        SQL

        DB[:conn].execute(sql, self.name, self.breed, self.id)
    end
end