FactoryBot.define do
  factory :cart do
    total_price { 0 }
    status { :active }
    last_interaction_at { Time.current }

    trait :active_cart_to_abandon do
      status { :active }
      last_interaction_at { 4.hours.ago }
    end

    trait :abandoned_cart_to_destroy do
      status { :abandoned }
      last_interaction_at { 8.days.ago }
    end
  end
end
