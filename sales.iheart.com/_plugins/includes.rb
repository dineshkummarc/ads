module Jekyll
  class AssetTag < Liquid::Tag
    def initialize(tag_name, name, prod_name, tokens)
      super tag_name, name, tokens
      @type = name.to_s.strip
      @prod_type = prod_name.to_s.strip
    end

    def render(context)
      @config = context.registers[:site].config
      
      #only include the assets if they exist
      if !@config.include?(@type)
        return
      end
      
      if !@config["auto"]
        markup_prod Asset.relify("/assets/#{prod_name_with_ext}", context['page']['url'], false)
      else
        (assets_for_name.map do |asset|
          markup "/assets/#{@type}/#{asset}"
        end).join("\n")
      end
    end
    
    def name_with_ext
      "all.#{@type}"
    end
    
    def prod_name_with_ext
      "all.#{@prod_type}"
    end
    
    def assets_for_name
      if @config.include?(@type)
        @config[@type].map do |asset|
          asset.gsub(/_site\/(css|js)\//, '')
        end
      else
        name_with_ext
      end
    end
  end

  class IncludeJsTag < AssetTag
    def initialize(tag_name, name, tokens)
      super tag_name, 'js', 'js', tokens
    end
    
    def markup_prod(src)
      self.markup(src)
    end
    
    def markup(src)
      %{<script src="#{src}"></script>}.to_s
    end
  end

  class IncludeLessTag < AssetTag
    def initialize(tag_name, name, tokens)
      super tag_name, 'less', 'css', tokens
    end
    
    def markup_prod(src)
      %{<link href="#{src}" media="screen" rel="stylesheet" type="text/css" />}.to_s
    end

    def markup(src)
      %{<link href="#{src}" media="screen" rel="stylesheet/less" type="text/css" />}.to_s
    end
  end

  Liquid::Template.register_tag('include_js', IncludeJsTag)
  Liquid::Template.register_tag('include_less', IncludeLessTag)
end