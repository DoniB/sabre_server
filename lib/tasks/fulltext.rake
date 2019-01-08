require 'factory_bot_rails'
require 'recipe_status'

INGREDIENTS_FOR_SEARCH = [
    "banana",
    "alho",
    "ovo",
    "frango",
    "leite condensado"
]

OTHER_INGREDIENTS = [
    "ovomaltine",
    "creme de leite",
    "maça",
    "cebola",
    "macarrão"
]

REPORT_FILE = "full_text_search_report.html"

namespace :fulltext do
  desc "Test the search for recipes with Full Text Search"
  task test: :environment do
    puts "WARING: This task will erase all stored recipes and users"
    puts "Type 'yes' to proceed"
    user_input = STDIN.gets.chomp
    if user_input == "yes"

      print "Clean up database..."
      sabre_clear_database
      puts "ok"

      print "Creating recipes..."
      sabre_create_recipes
      puts "ok"

      puts "Total recipes: #{Recipe.count}"
      puts "Ingredientes for search: #{INGREDIENTS_FOR_SEARCH}"

      rs = recipes_status

      write_start_report
      write_info_report rs

      test_tsearch
      test_dmetaphone
      test_trigram

      write_results_report

      write_end_report

    else
      puts "Stopping task"
    end

  end

end

def test_trigram
  (1..50).to_a.map{ |i| i/50.0 }.each { |j|
    define_scope({trigram: {threshold: j}})
    @result << normalize_results(Recipe.search_t(INGREDIENTS_FOR_SEARCH.join(', ')), "trigram: threshold=#{j}")
  }

  (200..300).to_a.map{ |i| i/1000.0 }.each { |j|
    define_scope({trigram: {threshold: j}})
    @result << normalize_results(Recipe.search_t(INGREDIENTS_FOR_SEARCH.join(', ')), "trigram: threshold=#{j}")
  }
end

def test_dmetaphone
  define_scope({dmetaphone: {any_word: false}})
  @result << normalize_results(Recipe.search_t(INGREDIENTS_FOR_SEARCH.join(', ')), "dmetaphone: any_word=false")
  define_scope({dmetaphone: {any_word: true}})
  @result << normalize_results(Recipe.search_t(INGREDIENTS_FOR_SEARCH.join(', ')), "dmetaphone: any_word=true")
end

def test_tsearch
  @result = []
  define_scope({tsearch: {prefix: false}})
  @result << normalize_results(Recipe.search_t(INGREDIENTS_FOR_SEARCH.join(', ')), "tsearch: prefix=false")
  define_scope({tsearch: {prefix: true}})
  @result << normalize_results(Recipe.search_t(INGREDIENTS_FOR_SEARCH.join(', ')), "tsearch: prefix=true")
end

def normalize_results(recipes, option)
  recipes_id = recipes.map { |r| r.id}
  result = {option: option, total: recipes.size, total_valid: 0, total_invalid: 0}
  recipes_id.inject(result) {|result, id|
    if @valid_ids.include? id
      result[:total_valid] += 1
    else
      result[:total_invalid] += 1
    end
    result
  }
end

def define_scope(using)
  Recipe.pg_search_scope(:search_t,
                         against: (:ingredients),
                         ignoring: :accents,
                         using: using)
end

def write_results_report
  r = @result.sort do |left, right|
    result = right[:total_valid] <=> left[:total_valid]
    if result == 0 && @valid_ids.size
      left[:total_invalid] <=> right[:total_invalid]
    else
      result
    end
  end

  write_table_start

  until r.empty?
    current = r.shift
    content = <<TABLE_ROW
<tr>
    <th>#{current[:option]}</th>
    <th>#{current[:total]}</th> 
    <th>#{current[:total_valid]}</th>
    <th>#{current[:total_invalid]}</th>
</tr>
TABLE_ROW
    File.write(REPORT_FILE,
               content,
               mode: 'a')
  end

  write_table_end
end

def sabre_clear_database
  User.delete_all
  Recipe.delete_all

  raise "Unable to delete all users" if User.count > 0
  raise "Unable to delete all recipes" if Recipe.count > 0
end

def sabre_create_recipes
  all_ingredients = (INGREDIENTS_FOR_SEARCH + OTHER_INGREDIENTS).uniq
  all_combinations = all_ingredients.combination(2).to_a +
      all_ingredients.combination(3).to_a +
      all_ingredients.combination(4).to_a +
      all_ingredients.combination(5).to_a
  all_combinations.each do |c|
    FactoryBot::create :recipe, ingredients: c.join("\n"), status: RecipeStatus::ACTIVE
  end
end

def recipes_status
  status = {valid: [], invalid: [], total: 0, total_valid: 0, total_invalid: 0}
  Recipe.all.each do |r|
    valid = true
    r.ingredients.split("\n").each { |i|
      if OTHER_INGREDIENTS.include? i
        valid = false
      end
    }
    if valid
      status[:valid] << r.id
      status[:total_valid] += 1
    else
      status[:invalid] << r.id
      status[:total_invalid] += 1
    end
    status[:total] += 1
  end
  @valid_ids = status[:valid]
  @invalid_ids = status[:invalid]
  status
end

def write_start_report
  content = <<START
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <meta http-equiv="X-UA-Compatible" content="ie=edge">
  <title>Recipe Report</title>
  <style>
    .hidden {
      display: none;
    }
  </style>
</head>
<body>
START
  File.write(REPORT_FILE, content, mode: 'w')
end

def write_info_report(status)
  content = <<INFO
<div>
  <p>Total recipes: #{status[:total]}</p>
  <p>Total valid recipes: #{status[:total_valid]}</p>
  <p>Total invalid recipes: #{status[:total_invalid]}</p>
  </p>
</div>
INFO
  File.write(REPORT_FILE, content, mode: 'a')
end

def write_end_report
  content = <<END
  <script>
	  document.querySelectorAll('.click-to-show').forEach(c => {
		  c.onclick = (e) => {
			  e.preventDefault()
			  const link = e.target
			  const span = link.previousElementSibling
			  link.remove()
			  span.classList.remove('hidden')
		  }
	  })
  </script>
</body>
</html>
END
  File.write(REPORT_FILE, content, mode: 'a')
end

def write_table_start
  content = <<TABLE_START
<table style="width:100%">
<tr>
    <th>option</th>
    <th>total</th> 
    <th>total_valid</th>
    <th>total_valid</th>
</tr>
TABLE_START
  File.write(REPORT_FILE, content, mode: 'a')
end

def write_table_end
  content = <<TABLE_END
</table>
TABLE_END
  File.write(REPORT_FILE, content, mode: 'a')
end