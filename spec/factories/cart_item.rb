FactoryBot.define do
  factory :cart_item do
    cart
    product
    quantity { 1 }
    unit_price { product.price }

    trait :with_quantity do
      quantity { 5 }
    end
  end
end
