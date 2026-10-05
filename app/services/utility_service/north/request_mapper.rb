module UtilityService
  module North
    class RequestMapper < UtilityService::RequestMapper
      def retrieve_books(params)
        {
          autor: params['author']
        }
      end

      def retrieve_notes(params)
        {
          autor: params['author']
        }
      end
    end
  end
end
