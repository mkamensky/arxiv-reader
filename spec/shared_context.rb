require 'rails_helper'

RSpec.shared_context 'general context' do |typ = find_model_type|
  typ.to_s.classify.constantize.
    reflect_on_all_associations(:belongs_to).each do
    meth = it.name.to_s == 'subject' ? '_subject' : it.name
    let(meth) { create(it.name) }
  end
  let(:type) { typ.to_s }
  let(:model) { type.classify.constantize }
  let(:relationships) { model.reflect_on_all_associations(:belongs_to) }
  let(:build_params) { attributes_for(type) }
  let(:types) { type.pluralize }
  let(:resource_class) { "#{type.classify}Resource".constantize }
  let(:objects) { create_list(type, 2) }
  let(:object) { create(type) }
  include_context "#{typ} context"
end

####### Action specific

RSpec.shared_context 'create context' do
  let(:payload) do
    {
      data: {
        type: types,
        attributes: build_params,
        relationships: relationships.to_h do
          meth = it.name.to_s == 'subject' ? '_subject' : it.name
          [
            it.name, {
              data: {
                type: it.name.to_s.pluralize,
                id: public_send(meth).id.to_s,
              },
            }
          ]
        end,
      },
    }
  end
  let(:instance) do
    resource_class.build(payload)
  end
end

RSpec.shared_context 'update context' do
  let(:payload) do
    {
      data: {
        type: types,
        id: object.id.to_s,
        attributes: update_params,
      },
    }
  end
  let(:instance) do
    resource_class.find(payload)
  end
  let(:update_object) do
    return change { object.reload.updated_at }.by(0) if update_params.blank?

    update_params.reduce(change { object.reload.updated_at }) do |res, (k, v)|
      res.and(change { object.public_send(k) }.to(v))
    end
  end
end

RSpec.shared_context 'destroy context' do
  let!(:instance) { resource_class.find(id: object.id) }
end

######## Resource specific

RSpec.shared_context 'paper context' do
  let(:update_params) { { version: 'v4' } }
end

RSpec.shared_context 'category context' do
  let(:update_params) { { title: 'foobar' } }
end

RSpec.shared_context 'categorisation context' do
  let(:update_params) { {} }
end

RSpec.shared_context 'author context' do
  let(:update_params) { { name: 'Andre Weil' } }
end

RSpec.shared_context 'authorship context' do
  let(:update_params) { {} }
end

RSpec.shared_context 'subject context' do
  let(:update_params) { {} }
end

RSpec.shared_context 'user context' do
  let(:build_params) {
    res = attributes_for(type)
    res.delete(:encrypted_password)
    res[:password] = 'foobar'
    res[:password_confirmation] = 'foobar'
    res
  }
  let(:update_params) { {} }
end

RSpec.shared_context 'bookmark context' do
  let(:update_params) { {} }
end
RSpec.shared_context 'recommendation context' do
  let(:update_params) { {} }
end
RSpec.shared_context 'followship context' do
  let(:update_params) { {} }
end
RSpec.shared_context 'usercat context' do
  let(:update_params) { {} }
end
