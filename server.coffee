###
server.coffee
MDPrez
- 2014-03-21: cloned Constitution skeleton.
###

# Imports.
express=require 'express.io'
stylus=require 'stylus'

# Initialize.
app=express()
app.http().io() # Create HTTP and WebSockets servers.

# Configuration for all environments.
PORT=process.env.PORT ? 3000 # Fallback to Node's default unless specified in environment.
ASSET_BUILD_PATH='client'
app.configure ->
	app
	.use express.compress()
	.use express.favicon()
	.use express.logger 'dev'

	app.io
	.set 'log level',2 # Shut up!
	.enable 'browser client minification' # Send minified asset.
	.enable 'browser client etag' # Apply etag caching logic based on version number.
	.enable 'browser client gzip' # gzip the asset.

# State (single session???)
glass_readiness=dash_readiness=false

# Routes???
app.all '/glass',(req,res)->
	res.sendfile __dirname+'/'+ASSET_BUILD_PATH+'/glass.html'
app.all '/',(req,res)->
	res.sendfile __dirname+'/'+ASSET_BUILD_PATH+'/mockup.html' #??? Should actually generate content for search engines (SEO), but with JS that'll run the full app from it.

app.io.route 'glass_ready',(req)->
	glass_readiness=true #??? And no disconnections?! Just a crude debug hack.
	req.io.broadcast 'glass_ready'
	if dash_readiness then req.io.emit 'dash_ready'
app.io.route 'dash_ready',(req)->
	dash_readiness=true
	req.io.broadcast 'dash_ready'
	if glass_readiness then req.io.emit 'glass_ready'
	#??? Risk of race condition?
app.io.route 'player_step',(req)->
	req.io.broadcast 'player_step',req.data
app.io.route 'scroll_down',(req)->
	req.io.broadcast 'scroll_down'
app.io.route 'scroll_up',(req)->
	req.io.broadcast 'scroll_up'
app.io.route 'play',(req)->
	req.io.broadcast 'play'
app.io.route 'pause',(req)->
	req.io.broadcast 'pause'
app.io.route 'rewind',(req)->
	req.io.broadcast 'rewind',req.data
app.io.route 'glazing',(req)->
	req.io.broadcast 'glazing',req.data

# Start server.
app.listen PORT,->
	console.log "Listening on port #{PORT}."
