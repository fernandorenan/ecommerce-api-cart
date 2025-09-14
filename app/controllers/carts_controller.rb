class CartsController < ApplicationController
  before_action :set_cart, only: %i[list_cart add_item remove_product]

  def create 
    cart = Cart.find_or_create_by(id: session[:id]) do |c|
      c.total_price = 0
    end

    session[:id] = cart.id

    product = product_exists?
    return unless product

    if quantity = params[:quantity].to_i <= 0
      return render json: { error: 'A quantidade deve ser maior que zero' }, status: :unprocessable_entity 
    end
    add_or_update_cart_item(cart,product) if params[:quantity]
  end

  def list_cart
    return render_cart_not_found unless @cart
    render json: cart_serializer(@cart)
  end

  def add_item
    return render_cart_not_found unless @cart

    product = product_exists?
    return unless product

    add_or_update_cart_item(@cart,product)
  end

  def remove_product
    return render_cart_not_found unless @cart

    product = Product.find_by(id: params[:product_id])
    return render json: { error: 'O produto não foi encontrado' }, status: :not_found unless product

    cart_item = @cart.cart_items.find_by(product_id: product.id)
    return render json: { error: 'Item não encontrado no carrinho' }, status: :not_found unless cart_item

    cart_item.destroy
    @cart.update_total_price!
    @cart.touch_activity!

    render json: cart_serializer(@cart)
  end

  private

  def set_cart
    @cart = Cart.find_by(id: session[:id])
  end

  def cart_serializer(cart)
    if cart.cart_items.empty?
      return { message: 'Carrinho vazio' }
    end
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

  def product_exists?
    product = Product.find_by(id: params[:product_id])
    return product if product

    render json: { error: 'O produto não foi encontrado' }, status: :not_found
    return nil
  end

  def add_or_update_cart_item(cart,product)
    cart_item = cart.cart_items.find_by(product_id: product.id)

    if cart_item
      new_quantity = cart_item.quantity + params[:quantity].to_i

      if new_quantity <= 0
        cart_item.destroy
      else
        cart_item.update(quantity: new_quantity)
      end
    else
      quantity = params[:quantity].to_i
      return render json: { error: 'A quantidade deve ser maior que zero' }, status: :unprocessable_entity if quantity <= 0

      cart.cart_items.create!(product: product, quantity: params[:quantity], unit_price: product.price)
    end

    render json: cart_serializer(cart)
  end

  def render_cart_not_found
    render json: { error: 'Carrinho não encontrado' }, status: :not_found
  end
end
