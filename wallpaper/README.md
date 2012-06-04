# Wallpaper Ads

## Creation

In the [templates](wallpapers/templates) directory, you will find three templates.  Each of these templates give pixel-for-pixel information about where your ad will display, defined by the following colors:

* Black - page content that your ad will not display in
* Gray - space that might or might not be available, depending on the size of the ad in the sidebar, if the wallpaper ad scrolls or is fixed, etc.
* Red - your pushdown will display in this area
* Greens, yellow, light red - how much of the page (approximately) will be available at the specified screen resolution

## Template Notes

* The top player is not included in the template: the top of your ad will always display immediately below the player.
* To maximize image compression, leave a single, solid color in place of the black content area.  This will never be displayed.
	* If you are going to include a 300x250/600 ad with the wallpaper, and the wallpaper has background-attachment:fixed and no-repeat, then include the relevant sidebar ad area in the solid color area.