FactoryBot.define do
  factory :employee do
    full_name { Faker::Name.name }
    job_title { Faker::Job.title }
    country { %w[India United\ States Germany].sample }
    salary { Faker::Number.decimal(l_digits: 5, r_digits: 2) }
  end
end
