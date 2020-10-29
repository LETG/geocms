module Geocms
  class Api::V1::FoldersController < Api::V1::BaseController
    load_and_authorize_resource class: "Geocms::Folder", except: :writable
=begin
    rescue_from CanCan::AccessDenied do |exception|
      respond_with "not authorized"
    end
=end
    def index
      render json: @folders.ordered, each_serializer: FolderShortSerializer
    end

    def show
      @folder = Geocms::Folder.find(params[:id])
      respond_with @folder, serializer: FolderShortSerializer
    end

    def writable
      @folders = Geocms::Folder.accessible_by(current_ability, :write)
      render json: @folders, each_serializer: FolderShortSerializer
    end

    private
    def default_serializer_options
      {
        root: false
      }
    end
  end
end