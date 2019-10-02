require "geocms/backend"
require 'net/http'
require 'open-uri'
require 'fileutils'
require 'rake'
require 'geocms/core'
require 'geocms/core'
# integer for count news or/and updates layers
$cpt_new = 0
$cpt_update = 0
$time_cpt = 0

# search layer info
# @param node <Nokogiri::XML::NodeSet>
# @param search <string>
# @param source_id <integer> id of data_source
# @parm category_id <integer> id of category synchronize
def getLayerInfo(node,search,source_id,category_id,source)
  if !node.nil?
    layers = node.search(search)
    if !layers.empty?
      # for each layer in node_set

      layers.each do |layer|
        # search name, description, title and metadata_url
        name = layer.search("> Name").first
        if !name.nil?
          description = layer.search("> Abstract").first;
          title = layer.search("> Title").first;
          metadataUrl = layer.search("> MetadataURL > OnlineResource").first

          if source.wms_version == "1.1.1"
            dimension = layer.search("> Extent").first
          elsif source.wms_version == "1.3.0"
            dimension = layer.search("> Dimension").first
          end

          timeArray = !dimension.nil? && !dimension["name"].nil? && dimension["name"] === "time" ?  dimension.content.split(",") : nil

          bbox = nil

          layer.search("> BoundingBox").each do |bboxFromXml|
            if source.wms_version == "1.1.1"
              #if bboxFromXml["SRS"] === 'CRS:84' 
              #  bbox = bboxFromXml;
              #end
              if bboxFromXml["SRS"] === 'EPSG:4326' 
                bbox = bboxFromXml;
              end
            elsif source.wms_version == "1.3.0"
              #if bboxFromXml["CRS"] === 'CRS:84'
              #  bbox = bboxFromXml;
              #end
              if bboxFromXml["CRS"] === 'EPSG:4326'
                bbox = bboxFromXml;
              end
            end
          end

          description = !description.nil? ? description.content : nil
          title = !title.nil? ? title.content : nil
          
          metadataUrl = !metadataUrl.nil? ? metadataUrl["xlink:href"] : nil
          isQueryable = layer["queryable"].nil? ? 0 : layer["queryable"].to_i
          isQueryable = isQueryable == 0 ? false : true

          crs  = nil
          bboxArray  = Array.new 

          layer_id =  nil

          # get bounding box 
          if !bbox.nil? 
            if source.wms_version == "1.1.1"
              crs = !bbox["SRS"].nil? ?  bbox["SRS"] : nil
              bboxArray.insert(0,( bbox["minx"].nil? ? nil : bbox["minx"].to_f  ))
              bboxArray.insert(1,( bbox["miny"].nil? ? nil : bbox["miny"].to_f  ))
              bboxArray.insert(2,( bbox["maxx"].nil? ? nil : bbox["maxx"].to_f  ))
              bboxArray.insert(3,( bbox["maxy"].nil? ? nil : bbox["maxy"].to_f  ))
            elsif source.wms_version == "1.3.0"
              crs = !bbox["CRS"].nil? ?  bbox["CRS"] : nil
              bboxArray.insert(0,( bbox["miny"].nil? ? nil : bbox["miny"].to_f  ))
              bboxArray.insert(1,( bbox["minx"].nil? ? nil : bbox["minx"].to_f  ))
              bboxArray.insert(2,( bbox["maxy"].nil? ? nil : bbox["maxy"].to_f  ))
              bboxArray.insert(3,( bbox["maxx"].nil? ? nil : bbox["maxx"].to_f  ))
            end
          end
        
          # searche layer if exist  
          
          layerFromDb = Geocms::Layer.joins(:categorizations).where("
            geocms_layers.name =  :name and 
            geocms_layers.data_source_id = :source_id and 
            geocms_categorizations.category_id = :category_id ",{
            name: name.content,
            source_id: source_id,
            category_id: category_id
            }
          ).first

         
          # if layer exist
          if !layerFromDb.nil?
            bboxFromLayer = layerFromDb.boundingbox
            update = false;
            layer_id = layerFromDb.id
            # Update layers values
            if title != layerFromDb.title
              layerFromDb.title = title;
              update = true
            end
            if description != layerFromDb.description
              layerFromDb.description = description;
              update = true
            end
            if metadataUrl != layerFromDb.metadata_url
              layerFromDb.metadata_url = metadataUrl;
              update = true
            end
            
            if isQueryable != layerFromDb.queryable
              layerFromDb.queryable = isQueryable;
              update = true
            end 
            
            # create or update bouding box 
            if !bboxArray.empty?
              bboxFromDb = Geocms::BoundingBox.where("layer_id = ?",layerFromDb.id).first; 
              date = DateTime.now.strftime("%F %T UTC")

              # New Bbox
              if bboxFromDb.nil? 

                newBbox = Geocms::BoundingBox.create(
                  crs: crs,
                  minx: bboxArray[0],
                  miny: bboxArray[1],
                  maxx: bboxArray[2],
                  maxy: bboxArray[3],
                  layer_id: layerFromDb.id,
                  created_at: date,
                  updated_at: date
                )
                newBbox.save!
              # Update bbox
              elsif bboxFromLayer != bboxArray
                bboxFromDb.minx = bboxArray[0]
                bboxFromDb.miny = bboxArray[1]
                bboxFromDb.maxx = bboxArray[2]
                bboxFromDb.maxy = bboxArray[3]
                updateBbox = true
                bboxFromDb.crs = crs
                bboxFromDb.updated_at = date
                bboxFromDb.save!
              end 

            end

            # update dimension
            Geocms::Dimension.where(layer_id: layerFromDb.id).all.each do |d|
              d.destroy
            end

            if update
              $cpt_update = $cpt_update+1
            end
            
            img = ROGC::WMSClient.get_map(source.wms, layerFromDb.name,  layerFromDb.boundingbox, 64, 64, layerFromDb.bboxCrs);
         #   puts "--------------------------------------"
         #   puts "#{img}"
            img = img .gsub('styles=&', '');
            img = img .gsub('1.3.0', '1.1.1');
         #   puts "#{img}"
            layerFromDb.remote_thumbnail_url = img;
            
            # update date for not delete
            date = DateTime.now.strftime("%F %T UTC")
            layerFromDb.updated_at = date
            layerFromDb.save!

          elsif !title.nil? && title!=""
            date=DateTime.now.strftime("%F %T UTC")
            newLayer = Geocms::Layer.create(
              name: name.content,
              title: title,
              description: description,
              metadata_url: metadataUrl,
              updated_at: date,
              created_at: date,
              data_source_id: source_id,
              queryable: isQueryable.nil? ? false : isQueryable
            )

             # add / delete layer for synchro categorie
            categorie = Geocms::Category.find(category_id)
          
            if !categorie.nil?
              categorization = Geocms::Categorization.find_or_create_by(
                layer_id: newLayer.id,
                category_id: categorie.id
              )
              categorization.save!
            end
            img = ROGC::WMSClient.get_map(source.wms, newLayer.name,  newLayer.boundingbox, 64, 64, crs);
            #   puts "--------------------------------------"
            #   puts "#{img}"
            img = img .gsub('styles=&', '');
            img = img .gsub('1.3.0', '1.1.1');
            newLayer.remote_thumbnail_url = img;
           
            #create layer
            newLayer.save!

            layer_id = newLayer.id

            if !bboxArray.empty?
               newBbox = Geocms::BoundingBox.create(
                crs: crs,
                minx: bboxArray[0],
                miny: bboxArray[1],
                maxx: bboxArray[2],
                maxy: bboxArray[3],
                layer_id: newLayer.id,
                created_at: date,
                updated_at: date
              )  
              newBbox.save
            end
          

            $cpt_new = $cpt_new+1
          end
        end
        date = DateTime.now.strftime("%F %T UTC")
       
        if !timeArray.nil? && !timeArray.empty?
          timeArray.each do |time|
            newTime = Geocms::Dimension.create(
              value: time,
              created_at: date,
              updated_at: date,
              layer_id: layer_id
            )
            newTime.save!
            $time_cpt = $time_cpt + 1
          end
        end
        # for other layer in layer
        getLayerInfo(layer," > Layer",source_id,category_id,source)
      end
    end
  end
end

################################
##            TASK            ##
################################
namespace :geocms do
  namespace :synchro_dev do
    desc "Donwnload a wms file for test devloppement"
    task :download_wms => :environment do
      puts "File donwnload"
      content = Net::HTTP.get(URI("https://portail.indigeo.fr/geoserver/CBNB/wms"+"?SERVICE=WMS&VERSION=1.1.1&REQUEST=GetCapabilities"))
      puts "write xml file"
      File.open("content.xml","w+") do |f|
        f << content.force_encoding('utf-8');
      end
      puts "END"
    end
    desc "Parse wms/xml file "
    task :parse_wms => :environment do
      puts "Parse wms/xml file "
      xml_doc = File.open("content.xml") { |f| Nokogiri::XML(f) }
      date=DateTime.now.strftime("%F %T UTC");
      
      $cpt_update=0;
      $cpt_new=0;
      
      # update layer
     # getLayerInfo(xml_doc,"Capability > Layer",2,);
      puts "Date de mise à jour : #{ date } "
      puts "Nombre de layer mis à jour :  #{ $cpt_update}"
      puts "Nombre de nouveau layer :  #{ $cpt_new }"

      puts "END"
    end
  end 
  namespace :synchro do
    desc "Synchronization source"
    task :wms => :environment  do
      # init date for log, mail and database
      date=DateTime.now
      date_file=date.strftime("%Y%m%d_%H%M");
      date_email=date.strftime("%d/%m/%Y à %H:%M:%S ");

      #init directory and log files
      if !File.directory?("log/update")
        FileUtils::mkdir_p 'log/update'
      end

      path="log/update/"
      filename="data_update_"+date_file
      logFile=filename+".log"

      #Open log file
      File.open(path+logFile, "w+") do |f|
        # for each datas sources
        Geocms::DataSource.where("synchro = true and geocms_category_id is not null").all.each do |source|
          categorie = Geocms::Category.find(source.geocms_category_id)
          date = DateTime.now.in_time_zone
          f << "-------------------------------------------------------------------------------\n"
          f << "Nom de la source : " << source.name << "\n"
          f << "Nom de la categorie : " <<  categorie.name  << "\n"
          print( "Nom de la source : ",source.name,"\n")
          begin
            # get and parse xml from wms server
            xml_doc  = Nokogiri::XML(open(source.wms+"?SERVICE=WMS&VERSION="+source.wms_version+"&REQUEST=GetCapabilities"),nil, Encoding::UTF_8.to_s)

           
            
            $cpt_update=0
            $cpt_new=0
            time_cpt = 0

            # Compteur de categorie
            categorizationCountNew = 0
            
            print ("Categorization : #{Geocms::Categorization.count}\n");
            categorizationCountBefore = Geocms::Categorization.count;

            # update layer
            getLayerInfo(xml_doc,"Capability > Layer",source.id, source.geocms_category_id,source);
            f << "Date de mise à jour : " << date << "\n"
            f << "Nombre de layer mis à jour : " << $cpt_update <<  "\n"
            
            puts "new dimensions : #{$time_cpt}"

            # search and delete layer not update and 
            compteur_delete=0
            
            Geocms::Layer.joins(:categorizations).where("geocms_layers.updated_at < :updated_date and geocms_layers.data_source_id = :data_source_id and geocms_categorizations.category_id = :category_id ",{
              updated_date: date,
              data_source_id: source.id,
              category_id: source.geocms_category_id
            }).all.each  do |layer|
              Geocms::Categorization.delete_all(layer_id: layer.id)
              layer.destroy
              compteur_delete = compteur_delete + 1
            end

            f << "Nombre de layer suprimmé : "  << compteur_delete << "\n"
            puts  "Nombre de layer suprimmé : #{ compteur_delete } "
           
            categorizationCountAfter = Geocms::Categorization.count;
            categorizationCountNew = categorizationCountAfter - categorizationCountBefore;
            print ("Categorization new : #{categorizationCountNew}\n");
            categorizationCountNew = categorizationCountNew < 0 ? 0 : categorizationCountNew

            f << "Nombre de layer ajouté " << " : " << categorizationCountNew  << "\n"


          rescue => e
           f  << "Error : "  << e  << "\n"
           print("Error :  #{e}")
          end
        end
        begin
          puts "clear database"
          # clear layer categorie 
          compteur_clear = 0
          Geocms::Layer.joins("left join geocms_categorizations as cat on geocms_layers.id = cat.layer_id")
          .joins("left join geocms_categories as cat2 on cat.category_id = cat2.id")
          .where("cat2 is null").all.each do |layer|
            Geocms::Categorization.delete_all(layer_id: layer.id)
            layer.destroy
            compteur_clear = compteur_clear + 1
          end 

          # clear bbox
          Geocms::BoundingBox.joins("left join geocms_layers as l on geocms_bounding_boxes.layer_id = l.id")
          .where("l.id is null").all.each do |bbox|
            Geocms::BoundingBox.delete_all(id: bbox.id)
            bbox.destroy
            compteur_clear = compteur_clear + 1
          end 
          puts "compteur_clear #{compteur_clear}"

          # clear dimension
          Geocms::Dimension.joins("left join geocms_layers as l on geocms_dimensions.layer_id = l.id")
          .where("l.id is null").all.each do |d|
            Geocms::Dimension.delete_all(id: d.id)
            d.destroy
            compteur_clear = compteur_clear + 1
          end 
          puts "compteur_clear #{compteur_clear}"
        rescue => e
         puts  "Error :  #{e}"
        end
      end

      # send email to admins_data users
      puts "search admin user : " 
      Geocms::User.joins(:roles).where(geocms_roles: { name: 'admin_instance' }).all.each do |user|;
        puts "Send mail to : #{ user.username } "
        begin
          UserMailer.sendUpdateLog(filename,date_email,user).deliver_now
        rescue => e
          puts  "Error :  #{e}"
        end
      end
    end
  end
end

