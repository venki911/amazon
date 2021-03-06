FactoryGirl.define do
  factory :rating do
    review {Faker::Lorem.paragraph}
    rating_number {rand(1..10)}
    book_id {rand(1..5)}
    approved false
    customer
    book
  end
end
