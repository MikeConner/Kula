# Be sure to restart your server when you modify this file.

# Version of your assets, change this if you want to expire all your assets.
Rails.application.config.assets.version = '1.0'

# Precompile additional assets.
# application.js, application.css, and all non-JS/CSS in app/assets folder are already added.
Rails.application.config.assets.paths << Rails.root.join("app", "assets", "files")
Rails.application.config.assets.precompile += %w( libs/custom.modernizr.js autocomplete.js payment_status_options.js causes.js date_processing.js)
