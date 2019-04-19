# frozen_string_literal: true

class MyController < ApplicationController
  def create
    # some code here
  rescue MyException => exception # <= flagged
    render_my_exception(exception)
  rescue MyAnotherException => exception # <= not flagged
    render_an_another_exception(exception)
  end
end
