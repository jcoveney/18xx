# frozen_string_literal: true

require 'view/game_row'

module View
  class GameCard < Snabberb::Component
    include GameManager

    needs :user
    needs :gdata # can't conflict with game_data

    ENTER_GREEN = '#3CB371'
    JOIN_YELLOW = '#F0E58C'
    YOUR_TURN_ORANGE = '#FF8C00'
    FINISHED_GREY = '#D3D3D3'

    def render
      props = {
        style: {
          display: 'inline-block',
          border: 'solid 1px black',
          padding: '0.5rem',
          width: '320px',
          'margin': '0 0.5rem 0.5rem 0',
          'vertical-align': 'top',
        }
      }

      h(:div, props, [
        render_header,
        render_body,
      ])
    end

    def new?
      @gdata['status'] == 'new'
    end

    def owner?
      user_owns_game?(@user, @gdata)
    end

    def players
      @gdata['players']
    end

    def render_header
      buttons = []
      buttons << render_button('Delete', -> { delete_game(@gdata) }) if owner?

      color =
        case @gdata['status']
        when 'new'
          if owner?
          elsif user_in_game?(@user, @gdata)
            buttons << render_button('Leave', -> { leave_game(@gdata) })
          else
            buttons << render_button('Join', -> { join_game(@gdata) })
          end
          JOIN_YELLOW
        when 'active'
          buttons << render_button('Enter', -> { enter_game(@gdata) })
          ENTER_GREEN
        when 'finished'
          buttons << render_button('Review', -> { enter_game(@gdata) })
          FINISHED_GREY
        end

      buttons << render_button('Start', -> { start_game(@gdata) }) if owner? && new? && players.size > 1

      props = {
        style: {
          position: 'relative',
          margin: '-0.5em',
          padding: '0.5em',
          'background-color': color,
        }
      }

      text_props = {
        style: {
          display: 'inline-block',
          width: '160px',
        }
      }

      h('div', props, [
        h(:div, text_props, [
          h(:div, "Game: #{@gdata['title']}"),
          h(:div, "Owner: #{@gdata['user']['name']}"),
        ]),
        *buttons,
      ])
    end

    def render_button(text, action)
      props = {
        style: {
          top: '1rem',
          float: 'right',
        },
        on: {
          click: action,
        },
      }

      h('button.button', props, text)
    end

    def render_body
      props = {
        style: {
          'margin-top': '0.5rem',
          'line-height': '1.2rem',
        }
      }

      p_elm = players.map { |p| p['name'] }.join(', ')

      if owner? && new?
        p_elm = players.map do |player|
          if player['id'] == @user['id']
            player['name']
          else
            button_props = {
               on: { click: -> { kick(@gdata, player) } },
               style: {
                 'margin-left': '0.5rem',
               },
            }
            h('button.button', button_props, player['name'])
          end
        end
      end

      h(:div, props, [
        h(:div, [h(:b, 'Id: '), @gdata['id']]),
        h(:div, [h(:b, 'Description: '), @gdata['description']]),
        h(:div, [h(:b, 'Max Players: '), @gdata['max_players']]),
        h(:div, [h(:b, 'Players: '), *p_elm]),
        h(:div, [h(:b, 'Created: '), @gdata['created_at']]),
      ])
    end
  end
end
