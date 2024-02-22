class TodoCompleter
    def initialize(todo)
      @todo = todo
    end
  
    def call
      @todo.complete!
    end
  end