require 'pg'
require 'pry'

def db_connection
  begin
    connection = PG.connect(dbname: 'recipes')

    yield(connection)

  ensure
    connection.close
  end
end


class Recipe
  attr_reader :id, :name, :instructions,:description

  def initialize(id, name, instructions, description)
    @id = id
    @name = name
    @instructions = instructions
    @description = description
  end


  def self.all
    query = "SELECT * FROM recipes"
    recipes = db_connection do |conn|
      conn.exec(query)
    end
    recipes_objects = []
    recipes.to_a.each do |recipe|
      recipes_objects << Recipe.new(recipe["id"], recipe["name"], recipe["instructions"], recipe["description"])
    end
    return recipes_objects
  end

  def self.find(id)
    query = "SELECT * FROM recipes WHERE id = $1"
    recipe = db_connection do |conn|
      conn.exec_params(query, [id])
    end

    recipe = recipe.to_a
    recipe = recipe[0]
    recipe = Recipe.new(recipe["id"], recipe["name"], recipe["instructions"], recipe["description"])

    return recipe
  end


end
