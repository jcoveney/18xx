# frozen_string_literal: true

require_relative 'passer'
require_relative 'share_holder'
require_relative 'spender'

module Engine
  class Player
    include Passer
    include ShareHolder
    include Spender

    attr_reader :name, :companies, :stock_value_change_history, :or_value_change_history

    def initialize(name)
      @name = name
      @cash = 0
      @companies = []
      @stock_value_change_history = []
      @or_value_change_history = []
    end

    def push_stock_initial_value!
      @stock_value_change_history.push([value])
    end

    def post_stock_final_value!
      @stock_value_change_history.last.push(value)
    end

    def push_or_initial_value!
      @or_value_change_history.push([value])
    end

    def push_or_next_value!
      @or_value_change_history.last.push(value)
    end

    def value
      @cash + shares.sum(&:price) + @companies.sum(&:value)
    end

    def id
      @name
    end

    def owner
      self
    end

    def player
      self
    end

    def ==(other)
      @name == other&.name
    end

    def player?
      true
    end

    def company?
      false
    end

    def corporation?
      false
    end

    def num_certs
      companies.count + shares.count { |s| s.corporation.counts_for_limit }
    end

    def to_s
      "#{self.class.name} - #{@name}"
    end
  end
end
