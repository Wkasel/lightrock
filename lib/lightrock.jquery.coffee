###
# Plugin LightRock
# By William Kasel 2013
# 
#
# This is a lightweight alternative to LaunchRocks UI. For those
# who just want a simple way to leverage their service while designing
# their own site. I highly implore you to attribute LaunchRock on your site
# somewhere. Also, this is very much a work in progress.
#
#
# In JQuery Instantiate as follows:
# $('#launchrock-signup').LightRock(site_id:'XXXXXXX');
# or
# $('#launchrock-signup').LightRock({
# password: 'xxx',
# parent_id: 'xxx',
# site_id: 'xxx',
# source: 'xxx',
# description_id: 'xxx',
# form_id: 'xxx',
# email_input_id: 'xxx',
# register_btn_id: 'xxx',
# content-inner_wrap_id: 'xxx',
# share_content_id: 'xxx',
# lr_share_link_id: 'xxx',
# });
#
# License: MIT
###

(($, window, document) ->
  $this = undefined

  _settings =
    password: 'lrsu'
    parent_id: 0
    site_id: '0'
    source: null
    api_base: 'https://platform.launchrock.com/v1'
    description_id: '#launchrock-signup-description'
    form_id: '#signup_form'
    email_input_id: '#email_form'
    register_btn_id: '#email_btn'
    content_inner_wrap_id: 'launchrock-signup-innercontent'
    share_content_id: 'launchrock-share-content'
    lr_share_link_id: 'lr_share_link'
 
  
  methods =
    init: (options) ->
      $this = $(@)
      $.extend _settings, (options or {})
      $this.each (index, el) ->
        _api.addListeners(el)
      return $this
 
  _api =
    
    ###
    # -
    # Controller functions
    # -
    
    # =========================
    # = Sets up our listeners =
    # =========================
    ###
    addListeners: (el)->
      @el = el
      # Clears the form on when they click the input
      $($this).on 'click',_settings.email_input_id, (e) ->
        $(this).val ''
      
      # Registers the user when they click register
      $($this).on 'click',_settings.register_btn_id, (e) ->
        _api.registerUser (data)->
          that.transitionToShare data
          
      return $this    
    
    ###
    # -
    # View functions
    # -
    ###
    transitionToShare: (data)->      
      # Prep the canvas
      $(@el).wrapInner('<div id="'+_settings.content_inner_wrap_id+'" />')
      $('#'+_settings.content_inner_wrap_id).fadeOut().remove()
      $(@el).wrapInner('<div id="'+_settings.content_inner_wrap_id+'_share" />')
      $('#'+_settings.content_inner_wrap_id+'_share').hide()
      
      
      ###
      #generate share link
      # that.generateShareLink data.site_user.UID, 'facebook', (data) ->
      #         console.log('share: ', data)
      ###
      
      
      # Make the magic happen
      $('#'+_settings.content_inner_wrap_id+'_share').html(
        $('#'+_settings.share_content_id).html()
        # $('#'+_settings.lr_share_link_id).text()
        console.log(data)
      ).fadeIn()
      
      
      return $this
      
      
    ###
    # -
    # Model functions
    # -
    
    # =============================================
    # = Prep's the data to pass to createSiteUser =
    # =============================================
    ###
    registerUser: (callback) ->
      that = @
      @getIp (_ip) ->
        _user = 
          email: $(_settings.email_input_id).val()
          password: ''
          parent_id: ''
          site_id: _settings.site_id
          source: ''
          ip: _ip
        
        that.createSiteUser _user, (data) ->
          callback data
          
          
      return $this  
    ###
    # =====================================
    # = Creates a site user on LaunchRock =
    # =====================================
    ###
    createSiteUser: (user, callback) ->
      $.ajax 
        url: _settings.api_base+'/createSiteUser'
        data: user
        success: (data) ->
          if !data[0].response.error
            callback data[0].response
          else
            alert ('Error: ' + data[0].response.error.error_message)
            console.error 'LightRock[ERROR]: ' + data[0].response.error.error_message
        error: (error) ->
          alert 'Well this is embarrasing, we couldn\'t register you, would you please try again?'
          console.error 'LightRock[ERROR]: Could not create LaunchRock user, please try again.'  
      return $this      
    ###  
    # ===============================================================
    # = Generates a share link to share current page (document.URL) =
    # ===============================================================
    # requires: 
    #   uid -> launchrock user id
    #   channel -> facebook, twitter, etc..
    ###
    generateShareLink: (uid, channel, callback) ->
      _data = 
        user_id: uid
        site_id: _settings.site_id
        channel: channel
        url: document.URL
      
      $.ajax
        url: _settings.api_base+'/createSiteUserChannelLink'
        data: _data
        success: (data) ->
          callback(data[0].response.channel_link)
        error: (error) ->
            console.error 'LightRock[ERROR]: Could not generate Share URL.'  
    ###  
    # =======================
    # = Get's the client IP =
    # =======================
    ###
    getIp: (callback) ->
      $.get _settings.api_base+'/getClientIP', (data) ->
        callback(data[0].response.client_ip.ip)
      return $this
      
      
  $.fn.LightRock = (method) ->
    if methods[method]
      methods[method].apply this, Array::slice.call(arguments, 1)
    else if typeof method is "object" or not method
      methods.init.apply this, arguments
    else
      $.error "Method " + method + " does not exist on jquery.LightRock"
) jQuery, window, document


