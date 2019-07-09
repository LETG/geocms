module Geocms
  module Backend
    class LayersController < Geocms::Backend::ApplicationController
      #before_filter :require_category, :only => [:destroy]
      load_and_authorize_resource class: "Geocms::Layer"

      rescue_from CanCan::AccessDenied do |exception|
        controle_access(exception)
      end

      def index
        @layers = current_tenant.layers.page(params[:page]).per(params[:per_page])
        respond_with(:backend, @layers)
      end

      def show
        @layer = @category.layers.find(params[:id])

        respond_with(:backend, @category, @layer)
      end

      def getfeatures
        layer = Layer.find(params[:id])
        @features = OGC::DescribeFeatureType.new(layer.data_source_wms, layer.name).properties
        respond_to do |format|
          format.json { render json: @features }
        end
      end

      def new
        @layer = Layer.new
        respond_with(:backend, @layer)
      end

      def edit
        @layer = Layer.find(params[:id])
        @categories = Category.for_select
        
        datasource = @layer.data_source
        @synchro = false
        if !(datasource.nil? )
          @synchro = datasource.synchro
        end

        respond_with(:backend, @category, @layer, @synchro)
      end

      def create
        dimension_values = params.delete(:dimension_values)
        bbox = params.delete(:bbox)

        @layer = Layer.new(layer_params.reject{ |p| p == "category_id" })
        @layer.crs = params.delete(:srs).first.to_s if params[:srs].present?

        if @layer.save
          if dimension_values && dimension_values.any?
            Dimension.create_dimension_values(@layer, dimension_values)
          end
          if bbox && bbox.any?
            BoundingBox.create_bounding_boxes(@layer, bbox)
          end

          begin
            @layer.do_thumbnail
          rescue
            print "\nERROR LAYER CONTROLLER.RB ; LINE 89 ; @layer.do_thumbnail\n"
          end 
        end

        respond_with(@layer) do |format|
          format.json if request.xhr?
          format.html { redirect_to [:edit, :backend, @layer] }
        end
      end

      def update
        @layer = Layer.find(params[:id])
        @layer.update_attributes(layer_params)
        update_layer(@layer)
        respond_with(:edit, :backend, @layer)
      end

      def destroy
        if params[:category_id].present?
          @category = Category.find(params[:category_id])
          @layer = @category.layers.find(params[:id])
          @layer.categories.delete(@category)
          # Destroy the relationship between category and layer, if layer doesn't have any categories left, destroy the layer
          if @layer.categories.empty?
            @layer.destroy
          else
            @layer.save
          end
          respond_with(:backend, @category)
        else
          @layer = Layer.find(params[:id])
          @layer.destroy
          redirect_to :backend_layers
        end
      end

      private
        def update_layer(layer)
          if layer.type_import == 'Automatic' 
            begin
              d = layer.data_source
              # requette describeCoverage to get BBOX, CRS and offset vector
              request = d.wms + "?REQUEST=describeCoverage&service=WCS&coverage=#{layer.name}&version=1.0.0"
              xmlDoc  = Nokogiri::XML(open(request),nil, Encoding::UTF_8.to_s)
              # var to final request
              bboxStr = ""
              srsStr = ""
              bboxTab = Array.new
              resx = ""
              resy = ""
              if !xmlDoc.nil?
                # Get bbox and convert to request
                bbox = xmlDoc.xpath("//wcs:lonLatEnvelope")

                if !bbox.nil?
                  bbox = bbox.first
                  bbox = bbox.xpath("//gml:Envelope//gml:pos")
                end

                if !bbox.nil?
                  bbox.each do |b|
                    if !b.nil? && !b.children.nil?
                      bboxTab << "#{b.children.to_s.gsub(" ",",")}"
                    end
                  end

                  bboxStr = bboxTab.join(",")
                end

                # Get CRS
                crs = xmlDoc.xpath("//wcs:spatialDomain//gml:Envelope")
                if !crs.nil? 
                  crs = crs.first
                  crsStr = crs.attr("srsName")
                end
  
                # Get offset vector
                vectors = xmlDoc.xpath("//gml:RectifiedGrid//gml:offsetVector")
                if !vectors.nil? && vectors.count() === 2 
                  tab = Array.new
                  [0, 1].each do |index|
                    tab[index] = vectors[0].content.split(" ");
                    if tab[index].count === 2
                      val1 = (tab[index][0].to_f - tab[index][1].to_f ).abs
                      tab[index] = val1.to_s
                    end
                  end 

                  resx = tab[0]
                  resy = tab[1]
                end
              end

              # save request
              request = d.wms + "?REQUEST=getCoverage&service=WCS&coverage=#{layer.name}&version=1.0.0&CRS=#{crsStr}&bbox=#{bboxStr}&resx=#{resx}&resy=#{resy}&format=geotiff"
              layer.download_url	= request
              layer.save!
            rescue
              layer.type_import = 'Vector'
              layer.save!
              print "ERROR_lAYER_CONTROLLER.RB"
            end
          end
        end
        def require_category
          if params[:category_id].present?
            @category = Category.find(params[:category_id])
          else
            @category = Category.find(layer_params[:category_id])
          end
        end

        def layer_params
          params.require(:layer).permit(PermittedAttributes.layer_attributes,:queryable, :synchro)
        end
    end
  end
end
