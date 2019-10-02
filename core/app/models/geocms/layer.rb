module Geocms
  class Layer < ActiveRecord::Base
    extend FriendlyId
    include ::PgSearch

    belongs_to :data_source
    has_many :contexts_layers,  -> { uniq.order(:position) },  dependent: :destroy
    has_many :contexts,         through: :contexts_layers
    has_many :dimensions#,       order: 'dimensions.value ASC'
    has_many :bounding_boxes,   dependent: :destroy

    has_many :categorizations
    has_many :categories, through: :categorizations

    accepts_nested_attributes_for :bounding_boxes
    accepts_nested_attributes_for :dimensions

    delegate :wms, :wms_version, :not_internal, :ogc, :name, to: :data_source, prefix: true

    friendly_id :title, use: [:slugged, :finders]
    mount_uploader :thumbnail, Geocms::LayerUploader
    validates_presence_of :data_source_id, :name, :title

    after_commit :get_thumbnail, on: :create

    default_scope -> { order(:title) }
    pg_search_scope :search, against: [:name, :title]

    # Finds the relevant bbox among all the bboxes stored
    # First check if there is a bounding box in EPSG:3857 (leaflet default)
    def boundingbox
      bbox = bounding_boxes.leafletable.first
      bbox.nil? ? [] : bbox.to_bbox
    end

    def bboxCrs
      bbox = bounding_boxes.leafletable.first
      #return bbox.crs
      bbox.nil? ? 'EPSG:4326' : bbox.crs
    end
    
    def self.bulk_import(layers)
      ActiveRecord::Base.transaction do
        layers.each do |l| 
          layer = self.create!(l)
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
              print "ERROR_lAYER.RB"
            end
          end
        end
      end
    end

    private

    def get_thumbnail 
      box = bounding_boxes.leafletable.first
      LayerThumbnailWorker.perform_async(id, data_source_wms, box.crs, box.to_bbox) unless box.nil?
    end
  end
end
