FactoryGirl.define do
  factory :entry, :class => Amiba::Source::Entry do
    title "Title"
    description "Description"
  end
end

Factory.sequence :entry_name do |n|
  "entry-#{n}"
end
