class SubjectsController < ApplicationController
  DEFAULT_SUBJECT = Subject.find('math')
  public_constant :DEFAULT_SUBJECT

  def show
    render inertia: {
      subject: -> {
        subject&.inertia_json(
          include: { categories: Category.inertia_params },
        )
      },
      subjects: -> { policy_scope(Subject).as_json(Subject.inertia_params) },
      papers: -> { papers },
      date: -> { date },
    }
  end

  protected

  def object
    @object ||= super || current_user&.subject || DEFAULT_SUBJECT
  end

  alias_method :subject, :object

  # rubocop: disable Metrics/PerceivedComplexity
  # rubocop: disable Metrics/CyclomaticComplexity
  def date
    return @date if @date

    prv = params[:date].sub!(/-$/, '')
    nxt = params[:date].sub!(/\+$/, '')
    @date = Date.parse(params[:date])
    @date = subject&.last_before(@date) if prv
    @date = subject&.first_after(@date) if nxt
  rescue TypeError, NoMethodError
    @date = subject&.last_update || (Time.zone.today - 1.day)
  end
  # rubocop: enable Metrics/PerceivedComplexity
  # rubocop: enable Metrics/CyclomaticComplexity

  def papers
    @papers ||= subject&.categories&.to_h do
      [
        it.arxiv,
        it.papers.
          where(submitted: date).
          as_json(
            Paper.inertia_params(include: { authors: Author.inertia_params }),
          ),
      ]
    end
  end

  def user_inertia_params
    super.vdeep_merge(include: { categories: Category.inertia_params })
  end
end
