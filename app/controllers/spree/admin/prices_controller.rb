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
            
            price_value = prices[currency.iso_code]
            if price_value.blank? || price_value.to_f.zero?
              price.amount = nil
            else
              price.amount = BigDecimal(price_value)
            end
            
            price.save! if price.new_record? || price.changed?
          end
        end
        flash[:success] = Spree.t('notice.prices_saved')
        redirect_to admin_product_path(parent)
      end
    end
  end
end
