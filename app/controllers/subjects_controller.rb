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
    @date ||= Date.parse(params[:date])
  rescue TypeError
    @date ||= subject&.last_update || (Time.zone.today - 1.day)
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
