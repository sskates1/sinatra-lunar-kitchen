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
  attr_reader :id, :name, :instructions,:description, :ingredients

  def initialize(id, name, instructions = nil, description = nil, ingredients= [])
    @id = id
    @name = name
    if instructions == nil
      @instructions = "This recipe doesn't have any instructions."
    else
      @instructions = instructions
    end

    if description == nil
      @description = "This recipe doesn't have a description."
    else
      @description = description
    end
    @ingredients = ingredients
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
    query = "SELECT r.id, r.name, instructions, description, i.id as ingredient_id, i.name as ingredient
            FROM recipes r
            JOIN ingredients i on r.id = i.recipe_id
            WHERE r.id = $1"
    recipe = db_connection do |conn|
      conn.exec_params(query, [id])
    end

    recipe = recipe.to_a
    ingredients = []
    recipe.each do |row|
      ingredients << Ingredient.new(row["ingredient_id"], row["ingredient"])
    end

    recipe = recipe[0]
    recipe = Recipe.new(recipe["id"], recipe["name"], recipe["instructions"], recipe["description"], ingredients )
    return recipe
  end


end
