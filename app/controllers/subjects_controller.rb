class SubjectsController < ApplicationController
  def index
    render_page
  end

  def show
    render_page('show')
  end

  protected

  def subject
    return unless params[:id]

    @subject ||= Subject.find(params[:id])
  end

  def date
    return @date if @date

    prv = params[:date].sub!(/-$/, '')
    nxt = params[:date].sub!(/\+$/, '')
    @date = Date.parse(params[:date])
    @date = subject&.last_before(@date) if prv
    @date = subject&.first_after(@date) if nxt
  rescue TypeError
    @date = subject&.last_update || (Time.zone.today - 1.day)
  end

  def papers
    @papers ||= subject&.categories&.to_h do
      [it.arxiv, it.papers.where(submitted: date).as_json(Paper.inertia_params)]
    end
  end

  def render_page(page = 'index')
    render inertia: "subjects/#{page}", props: {
      subject: -> { subject&.inertia_json },
      papers: -> { papers },
      date: -> { date },
    }
  end
end
