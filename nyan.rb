#!/usr/bin/env ruby
#Written by: Chase Arnold
#Nov, 2011

require 'rubygems'
require 'twitter'
require 'gosu'
include Gosu


$tweet_array = []

Thread.new do
  loop{
    if $tweet_array.count > 50 then
      sleep(5)
    else
      Twitter.search('nyan', :lang => 'en').map do |status|
        $tweet_array << [status.text,status.from_user]
      end
    end
  }
end


class GameWindow < Gosu::Window
  def initialize
    super(800, 800, false)
    self.caption = 'Nyan Cat'
    @background_animation = Gosu::Image::load_tiles(self, "#{File.dirname($0)}/nyan_animation.png", 400, 400, false)
    Gosu::Sample.new(self, "#{File.dirname($0)}/nyanlooped.ogg").play(0.1, 1, true)
    @font = Gosu::Font.new(self, "#{File.dirname($0)}/8bit.ttf", 16)
    @current_message = ['','']
    @message_timer = 0
  end # End GameWindow Initialize
  
  def string_split(string, chars)
    result = []
    (string.length.to_f / chars.to_f).ceil.times do |i|
      result << [string[i * chars..((i + 1) * chars) - 1], i]
    end
    return result
  end
  
  def update
    if $tweet_array.count > 0 then
      if @message_timer < 1 then
        tweet = $tweet_array.shift
        @current_message[0] = tweet[1]
        @current_message[1] = tweet[0].gsub("\n",'').gsub('\u','').split('http')[0]
        @message_timer = 180
      else
        @message_timer -= 1
      end
    end
  end
  
  def draw
    @background_animation[Gosu::milliseconds / 70 % @background_animation.size].draw(0, 0, 0, 2, 2)
    @font.draw("#{@current_message[0]}:", 32, 48, 1)
    string_split(@current_message[1], 44).each do |message|
      @font.draw(message[0], 32, 96 + (message[1] * 18), 1)
    end
  end # End GameWindow Draw
  
  def button_down(id)
    if id == Gosu::Button::KbEscape
      close
    end
  end
end # End GameWindow class


window = GameWindow.new
window.show
