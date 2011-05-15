module Paypal
  module Express
    class Response < NVP::Response
      attr_accessor :pay_on_paypal
      attr_accessor :detailed_items
      
      def initialize(response, options = {})
        super response
        @pay_on_paypal = options[:pay_on_paypal]
        @detailed_items = {} 
        options[:items].is_a?(Array) && options[:items].each_with_index do |entry, index|
          @detailed_items["L_PAYMENTREQUEST_0_NAME#{index}"]    = entry[:name]
          @detailed_items["L_PAYMENTREQUEST_0_NUMBER#{index}"]  = entry[:qty]
          @detailed_items["L_PAYMENTREQUEST_0_DESC#{index}"]    = entry[:desc]
        end
      end

      def redirect_uri
        endpoint = URI.parse Paypal.endpoint
        endpoint.query = query(:with_cmd).to_query
        endpoint.to_s
      end

      def popup_uri
        endpoint = URI.parse Paypal.popup_endpoint
        endpoint.query = query.to_query
        endpoint.to_s
      end

      private

      def query(with_cmd = false)
        _query_ = {:token => self.token}
        _query_.merge!(:cmd => '_express-checkout') if with_cmd
        _query_.merge!(:useraction => 'commit')     if pay_on_paypal
        _query_.merge!(detailed_items)              unless detailed_items.blank?
        _query_
      end
    end
  end
end