class TodoIncompleter
    def initialize(todo)
      @todo = todo
    end
  
    def call
      @todo.incomplete!
    end
  end
  