require 'pg'

def db_connection
  begin
    connection = PG.connect(dbname: 'recipes')

    yield(connection)

  ensure
    connection.close
  end
end


class Recipe
  attr_reader :id, :name

  def initialize(id)
    query = "SELECT * FROM recipes WHERE id = $1"
    recipe = db_connection do |conn|
      conn.exec_params(query,[id])
    end
    @id = id
    @name = recipe.to_a[0]["name"]
  end


  def self.all
    query = "SELECT * FROM recipes"
    recipes = db_connection do |conn|
      conn.exec(query)
    end
    return recipes.to_a
  end


end
