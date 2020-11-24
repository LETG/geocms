module Geocms
  class Api::V1::CategoriesController < Api::V1::BaseController

    respond_to :json

    def index
      @categories = Category.roots.ordered
      render json: @categories, each_serializer: CategoryShortSerializer
    end

    def show
      #.where("geocms_categories.id = ?",params[:id]) 
     # @category = Category.includes(layers: [:data_source]).find params[:id]
      @category = Category.where("geocms_categories.id = ? ",params[:id])
      respond_with @category.first, serializer: CategorySerializer
    end

    def ordered
      @categories = Category.arrange_as_array(order: :name)
      respond_with(@categories, each_serializer: CategoryShortSerializer)
    end

    private
    def default_serializer_options
      {
        root: false
      }
    end

  end
end
