class Image < ActiveRecord::Base
  attr_accessible :url, :caption, :lat, :long, :kind
  belongs_to :imageable, polymorphic: true
  belongs_to :user

  # commented out to run rake db:seed
  mount_uploader :url, ImageUploader

  after_create :extract_exif_info


  # Define what in a picture is searchable. For the time being,
  # only caption is searchable. Future versions may want to include
  # a range of some sort.

  # commented this out because it was giving me an error message
  # searchable do
  #   text :caption
  # end

  # This methods allows to search for other photos with a similar caption.
  def self.caption_search(query)
    #self.search do
    #  fulltext query
    #end
    #Image.where("caption @@ :q",  :q => "%#{query}%" )

    sql = "SELECT * FROM Images WHERE"

    condition = []
    query.split(" ").to_a.each do |word|
      if (word != "The") && (word != "the") && (word != "for") && (word != "For") && (word != "of") && (word != "and") && (word != "And") && (word != "Of") && (word != "Or") && (word != "or") && (word != "because") && (word != "Because") && (word != "a") && (word != "A") && (word != "He") && (word != "he") && (word != "she") && (word != "She") && (word != "That") && (word != "that") && (word != "those") && (word != "Those") && (word != "either") && (word != "Either") && (word != "Your") && (word != "your")
        #if sql === "SELECT * FROM Images WHERE"
        #  sql += " caption ILIKE '%#{word}%'"
        #else 
        #  sql += " OR caption ILIKE '%#{word}%'"
        #end
        if condition.length == 0
          condition << "caption ~* ?"
          condition << word
        else 
          condition[0] += " OR caption ~* ?"
          condition << word
        end
      end
    end

    Image.find(:all, :conditions => condition)
  end


  # The following method gets the GPS data from the picture if any and stores it alongside
  # the picture for any furter usage. This happens only after the picture saved as not
  # all pictures contain the information.

  # commented out to run rake db:seed
   def extract_exif_info

     #commented this out to run the seed file
     img = Magick::Image.read(File.join(Rails.root, "public", self.url.url))[0]

     return unless img

     img_lat = img.get_exif_by_entry('GPSLatitude')[0][1].split(', ') rescue nil
     img_lng = img.get_exif_by_entry('GPSLongitude')[0][1].split(', ') rescue nil

     lat_ref = img.get_exif_by_entry('GPSLatitudeRef')[0][1] rescue nil
     lng_ref = img.get_exif_by_entry('GPSLongitudeRef')[0][1] rescue nil

     return unless img_lat && img_lng && lat_ref && lng_ref

     latitude = to_frac(img_lat[0]) + (to_frac(img_lat[1])/60) + (to_frac(img_lat[2])/3600)
     longitude = to_frac(img_lng[0]) + (to_frac(img_lng[1])/60) + (to_frac(img_lng[2])/3600)

     latitude = latitude * -1 if lat_ref == 'S'  # (N is +, S is -)
     longitude = longitude * -1 if lng_ref == 'W'   # (W is -, E is +)


     self.lat = latitude
     self.long = longitude

     self.save
   end

  def to_frac(strng)
    numerator, denominator = strng.split('/').map(&:to_f)
    denominator ||= 1
    numerator/denominator
  end


  def self.near(latitude, longitude)
    constant = 2
    Image.where("lat < ? AND lat > ? AND long < ? AND long > ?", latitude + constant, latitude - constant, longitude + constant, longitude - constant);
  end

end
