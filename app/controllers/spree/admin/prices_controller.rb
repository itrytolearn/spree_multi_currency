module Spree
  module Admin
    class PricesController < ResourceController
      belongs_to 'spree/product', find_by: :slug

      def create
        params[:vp].each do |variant_id, prices|
          variant = Spree::Variant.find(variant_id)
          next unless variant
          supported_currencies.each do |currency|
            price = variant.price_in(currency.iso_code)
            
            if prices[currency.iso_code].blank?
              price.money = nil
            else
              cents = (BigDecimal(prices[currency.iso_code]) * 100).to_i
              price.money = Spree::Money.new(cents, currency: currency.iso_code)
            end

            price.save! if price.changed?
          end
        end
        flash[:success] = Spree.t('notice.prices_saved')
        redirect_to admin_product_path(parent)
      end
    end
  end
end
