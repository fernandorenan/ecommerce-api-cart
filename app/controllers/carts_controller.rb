class CartsController < ApplicationController
  ## TODO Escreva a lógica dos carrinhos aqui
  def create 

    cart = Cart.find_or_create_by(id: session[:id]) do  |c|
      c.total_price = 0
    end

    session[:id] = cart.id

    product = product_exists

    add_or_update_cart_item(cart,product)
  end

  def product_exists
    product = Product.find_by(id: params[:product_id])
    return product if product

    render json: { error: 'O produto não foi encontrado' }, status: :not_found and return
  end

  def add_or_update_cart_item(cart,product)
    cart_item = cart.cart_items.find_by(product_id: product.id)

    if cart_item
      cart_item.update(quantity: cart_item.quantity + params[:quantity].to_i)
    else
      cart.cart_items.create!(product: product, quantity: params[:quantity], unit_price: product.price)
    end

    cart.update_total_price!

    render json: cart_response(cart)
  end

  private

  def cart_params
    params.require(:cart).permit(:user_id)
  end

  def cart_response(cart)
    {
      id: cart.id,
      products: cart.cart_items.map do |item|
        {
          id: item.product.id,
          name: item.product.name,
          quantity: item.quantity,
          unit_price: item.unit_price.to_f,
          total_price: item.total_price.to_f
        }
      end,
      total_price: cart.total_price.to_f
    }
  end
end
