FactoryGirl.define do
  factory :entry, :class => Amiba::Source::Entry do
    title "Title"
    description "Description"
    state "draft"
  end
end

Factory.sequence :entry_name do |n|
  "entry-#{n}"
end
