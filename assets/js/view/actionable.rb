# frozen_string_literal: true

require 'lib/storage'
require 'engine/game_error'

module View
  module Actionable
    def self.included(base)
      base.needs :game_data, default: {}, store: true
      base.needs :game, store: true
      base.needs :flash_opts, default: {}, store: true
      base.needs :connection, store: true, default: nil
    end

    def process_action(action)
      game = @game.process_action(action)
      @game_data[:actions] << action.to_h
      store(:game_data, @game_data, skip: true)

      if @game_data[:mode] == :hotseat
        Lib::Storage[@game_data[:id]] = @game_data
      else
        @connection.safe_post("/game/#{@game_data['id']}/action", action.to_h)
      end

      store(:game, game)
    rescue StandardError => e
      store(:game, @game.clone(@game.actions), skip: true)
      store(:flash_opts, e.message)
      e.backtrace.each { |line| puts line }
    end

    def rollback
      game = @game.rollback
      @game_data[:actions].pop
      store(:game_data, @game_data, skip: true)

      if @game_data[:mode] == :hotseat
        Lib::Storage[@game_data[:id]] = @game_data
      else
        @connection&.safe_post("/game/#{@game_data['id']}/action/rollback")
      end

      store(:game, game)
    end
  end
end
