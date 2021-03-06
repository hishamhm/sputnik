module(..., package.seeall)

local util = require"sputnik.util"

SLASH = "/"
actions = {}

actions.show_photo = function(node, request, sputnik)
   node.inner_html = cosmo.f(node.templates.SINGLE_PHOTO){
                        photo_url = node.album_config.image_base.."/"..request.params.id..".sized.jpg",
                        album_link = sputnik:make_link(node.id)
                     }
   return node.wrappers.default(node, request, sputnik)
end

actions.mixed_album = function(node, request, sputnik)
 
   local total_height = 0
   for i, row in ipairs(node.content.rows) do
      total_height = total_height + 8 + (#row==6 and 150 or 100)
   end

   local function pixify(value) 
      return string.format("%dpx", value)
   end

   node.inner_html = cosmo.f(node.templates.MIXED_ALBUM){
                        before     = node.markup.transform(node.description or ""),
                        do_photos  = function() 
                                        local width, dwidth, height
                                        local y = 2
                                        for i, row in ipairs(node.content.rows) do
                                           if #row == 6 then
                                              width, dwidth, height = 100, 6, 150
                                           else
                                              width, dwidth, height = 150, 10, 100
                                           end
                                           local x = 2
                                           for i = 1,#row do 
                                              photo = row[i]
                                              if photo then
                                                 local album, image = util.split(photo.id, SLASH)
                                                 photo.size = photo.size or 1
 
                                                 cosmo.yield {
                                                    width      = pixify(width*photo.size + dwidth*(photo.size-1)),
                                                    height     = pixify(height*photo.size + 8*(photo.size-1)),
                                                    left       = pixify(2 + (width + dwidth) * (i-1)),
                                                    top        = pixify(y),
                                                    image_base = node.album_config.image_base,
                                                    suffix     = photo.size>1 and string.format("%dx", photo.size) or "",
                                                    thumb_dir  = photo.size==1 and album or "oddsize",
                                                    album      = album,
                                                    image      = image,
                                                    url        = sputnik:make_url(node.id, "photo", {id=photo.id}),
                                                 }
                                              end
                                           end
                                           y = y + height + 8
                                        end
                                     end,
                            height = total_height
   }

   return node.wrappers.default(node, request, sputnik)
end

