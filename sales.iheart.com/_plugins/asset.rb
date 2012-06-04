module Jekyll
	class Asset < Liquid::Tag
		def initialize(tag_name, link, tokens)
			super
			@link = link.strip!
		end

		def render(context)
			Asset.relify(@link, context['page']['url'], context['site']['auto'])
		end
		
		def self.relify(asset, pageUrl, auto)
			if !auto
				if !asset.start_with?('/')
					asset = '/' + asset
				end

				parts = pageUrl.split('/')
				if parts.length > 2
					asset = (('../' * (parts.length - 2)) + asset).sub('//', '/')
				end

				if asset.start_with?('/')
					asset = asset[1,asset.length]
				end
			end
			
			asset
		end
	end
end

Liquid::Template.register_tag('asset', Jekyll::Asset)