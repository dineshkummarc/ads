JEKYLL=jekyll

all:
	$(JEKYLL) --server

production: clean
	$(JEKYLL) --no-auto
	
	java -jar _lib/rhino-js.jar _lib/less-rhino-1.1.6.js _site/common/less/main.less > _site/assets/all.css
	ruby _lib/dump.rb js | java -jar _lib/yuicompressor-2.4.7.jar --type js -o _site/assets/all.js
	
	rm -rf _site/assets/js
	rm -rf _site/assets/less

clean:
	rm -rf _site/
