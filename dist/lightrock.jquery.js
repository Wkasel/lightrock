/*
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
*/

(function($, window, document) {
  var $this, methods, _api, _settings;
  $this = void 0;
  _settings = {
    password: 'lrsu',
    parent_id: 0,
    site_id: '0',
    source: null,
    api_base: 'https://platform.launchrock.com/v1',
    description_id: '#launchrock-signup-description',
    form_id: '#signup_form',
    email_input_id: '#email_form',
    register_btn_id: '#email_btn',
    content_inner_wrap_id: 'launchrock-signup-innercontent',
    share_content_id: 'launchrock-share-content',
    lr_share_link_id: 'lr_share_link'
  };
  methods = {
    init: function(options) {
      $this = $(this);
      $.extend(_settings, options || {});
      $this.each(function(index, el) {
        return _api.addListeners(el);
      });
      return $this;
    }
  };
  _api = {
    /*
    # -
    # Controller functions
    # -
    
    # =========================
    # = Sets up our listeners =
    # =========================
    */

    addListeners: function(el) {
      this.el = el;
      $($this).on('click', _settings.email_input_id, function(e) {
        return $(this).val('');
      });
      $($this).on('click', _settings.register_btn_id, function(e) {
        return _api.registerUser(function(data) {
          return that.transitionToShare(data);
        });
      });
      return $this;
    },
    /*
    # -
    # View functions
    # -
    */

    transitionToShare: function(data) {
      $(this.el).wrapInner('<div id="' + _settings.content_inner_wrap_id + '" />');
      $('#' + _settings.content_inner_wrap_id).fadeOut().remove();
      $(this.el).wrapInner('<div id="' + _settings.content_inner_wrap_id + '_share" />');
      $('#' + _settings.content_inner_wrap_id + '_share').hide();
      /*
      #generate share link
      # that.generateShareLink data.site_user.UID, 'facebook', (data) ->
      #         console.log('share: ', data)
      */

      $('#' + _settings.content_inner_wrap_id + '_share').html($('#' + _settings.share_content_id).html(), console.log(data)).fadeIn();
      return $this;
    },
    /*
    # -
    # Model functions
    # -
    
    # =============================================
    # = Prep's the data to pass to createSiteUser =
    # =============================================
    */

    registerUser: function(callback) {
      var that;
      that = this;
      this.getIp(function(_ip) {
        var _user;
        _user = {
          email: $(_settings.email_input_id).val(),
          password: '',
          parent_id: '',
          site_id: _settings.site_id,
          source: '',
          ip: _ip
        };
        return that.createSiteUser(_user, function(data) {
          return callback(data);
        });
      });
      return $this;
    },
    /*
    # =====================================
    # = Creates a site user on LaunchRock =
    # =====================================
    */

    createSiteUser: function(user, callback) {
      $.ajax({
        url: _settings.api_base + '/createSiteUser',
        data: user,
        success: function(data) {
          if (!data[0].response.error) {
            return callback(data[0].response);
          } else {
            alert('Error: ' + data[0].response.error.error_message);
            return console.error('LightRock[ERROR]: ' + data[0].response.error.error_message);
          }
        },
        error: function(error) {
          alert('Well this is embarrasing, we couldn\'t register you, would you please try again?');
          return console.error('LightRock[ERROR]: Could not create LaunchRock user, please try again.');
        }
      });
      return $this;
    },
    /*  
    # ===============================================================
    # = Generates a share link to share current page (document.URL) =
    # ===============================================================
    # requires: 
    #   uid -> launchrock user id
    #   channel -> facebook, twitter, etc..
    */

    generateShareLink: function(uid, channel, callback) {
      var _data;
      _data = {
        user_id: uid,
        site_id: _settings.site_id,
        channel: channel,
        url: document.URL
      };
      return $.ajax({
        url: _settings.api_base + '/createSiteUserChannelLink',
        data: _data,
        success: function(data) {
          return callback(data[0].response.channel_link);
        },
        error: function(error) {
          return console.error('LightRock[ERROR]: Could not generate Share URL.');
        }
      });
    },
    /*  
    # =======================
    # = Get's the client IP =
    # =======================
    */

    getIp: function(callback) {
      $.get(_settings.api_base + '/getClientIP', function(data) {
        return callback(data[0].response.client_ip.ip);
      });
      return $this;
    }
  };
  return $.fn.LightRock = function(method) {
    if (methods[method]) {
      return methods[method].apply(this, Array.prototype.slice.call(arguments, 1));
    } else if (typeof method === "object" || !method) {
      return methods.init.apply(this, arguments);
    } else {
      return $.error("Method " + method + " does not exist on jquery.LightRock");
    }
  };
})(jQuery, window, document);
