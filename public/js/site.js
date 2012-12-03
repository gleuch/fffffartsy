jQuery(document).ready(function() {
  Fartsy.Preview.initialize();

  jQuery('a#piece_info, #placard a.close').click(function() {
    if (jQuery('#placard').hasClass('show')) {
      jQuery('#placard').removeClass('show');
      setTimeout(function() {jQuery('#placard').hide();}, 2000);
    } else {
      jQuery('#placard').show();
      setTimeout(function() {jQuery('#placard').addClass('show');}, 100);
    }
  });

});


var Fartsy = {
  Preview : {
    formats : [],
    frames : [],
    audiences : [],
    galleries : [],


    initialize : function() {
      if (jQuery('#art_piece_form')) {
        Fartsy.Preview.step_to();

        jQuery('.step select, .step input#art_piece_url, .step .piece_dimension input[type=text], .step .range_length input[type=range]').on('change', function() {Fartsy.Preview.preview();});
        jQuery('#art_piece_scale').on('change', function() { jQuery('#scale_output').html( Math.round(jQuery(this).val() * 100) +'%'); })

        jQuery('#selection_view').click(function() {
          jQuery('#selection').removeClass('preview_mode');
        })

        /* Step 1 actions */
        jQuery('.step[data-step=1] button').on('click', function() {
          var f = jQuery(this).val();
          jQuery('#art_piece_format').val(f);
          jQuery('#art_piece_form').attr('data-format', Fartsy.Preview.formats[f]);
          Fartsy.Preview.step_to(2);
          setTimeout(function() {jQuery('#art_piece_url').focus();}, 100);
          return false;
        });

        /* Step 2 actions */
        jQuery('.step[data-step=2] button.art_piece_continue').on('click', function() {
          var u = jQuery('#art_piece_url').val();

          if (u && u != '' && u.match(/^http/i)) {
            Fartsy.Preview.step_to(3);
          } else {
            alert('Please enter a valid url.');
          }

          return false;
        });

        jQuery('.step[data-step=2] button.art_piece_back').on('click', function() {
          Fartsy.Preview.step_to(1);
          return false;
        });

        /* Step 3 actions */
        jQuery('.step[data-step=3] button.art_piece_back').on('click', function() {
          Fartsy.Preview.step_to(2);
          return false;
        });

        jQuery('.step[data-step=3] button.art_piece_continue').on('click', function() {
          Fartsy.Preview.step_to(4);
          return false;
        });

        jQuery('.step[data-step=3] button.art_piece_continue').on('click', function() {
          Fartsy.Preview.step_to(4);
          return false;
        });

        /* Step 4 actions */
        jQuery('.step[data-step=4] button.art_piece_back').on('click', function() {
          Fartsy.Preview.step_to(3);
          return false;
        });

        /* Preview button */
        jQuery('.step button.art_piece_preview').on('click', function() {
          Fartsy.Preview.preview(true);
          return false;
        });

      }
    },

    step_to : function(si) {
      if (!si || si === undefined) {
        var si = jQuery('#art_piece_form').data('step-index');
        if (!si || si === undefined) si = 1;
      }

      if (si > jQuery('#art_piece_form .step[data-step]').size()) si = 1;

      jQuery('#art_piece_form .step[data-step]').each(function() {
        var s = jQuery(this).data('step');
        if (s == si) {
          jQuery(this).show();
        } else {
          jQuery(this).hide();
        }
      });
    },


    preview : function(alr) {
      var f = jQuery('#art_piece_format').val(),
          u = jQuery('#art_piece_url').val(),
          w = jQuery('#art_piece_width').val(),
          h = jQuery('#art_piece_height').val(),
          r = jQuery('#art_piece_frame').val(),
          a = jQuery('#artwork'), x = jQuery('#artwork iframe'), g = jQuery('#gallery'),
          err = false;

      if (!err && !(f && f != '' && Fartsy.Preview.formats[f])) err = 'Please select the proper format.';
      if (!err && !(u && u != '' && u.match(/^http/i))) err = 'Please enter a valid url.';
      if (!err && Fartsy.Preview.formats[f] == 'video' && !(u && u != '' && (u.match(/youtube\.com|youtu\.be|vimeo\.com/i) || u.match(/\.(flv|mp4|mov)$/i) ))) err = 'Please enter a YouTube, Vimeo, or raw (flv, mov, mp4) video url.';

      if (!err || err == '') {
        g.attr('data-format', Fartsy.Preview.formats[f]);
        if (r && r != '' && Fartsy.Preview.frames[r]) g.attr('data-frame', Fartsy.Preview.frames[r]);

        if (Fartsy.Preview.formats[f] == 'image') {
          var i = new Image();
          i.src = u;
          i.onload = function() {
            Fartsy.Preview.set_url('/pieces/preview/image?url='+ encodeURI(u));
            jQuery('#art_piece_width').val(i.width);
            jQuery('#art_piece_height').val(i.height);
            Fartsy.Preview.set_dimensions(i.width, i.height);
          };

        } else if (Fartsy.Preview.formats[f] == 'video') {
          Fartsy.Preview.set_url('/pieces/preview/video?url='+ encodeURI(u));
          Fartsy.Preview.set_dimensions(640,360); // 16:9

        } else {
          Fartsy.Preview.set_url(u);
          if ((w && w != '') && (h && h != '')) Fartsy.Preview.set_dimensions(w,h);
        }

        if (alr) {
          jQuery('#selection').addClass('preview_mode');
        }
      } else if (!!alr) {
        alert(err)
      }
    },

    set_url : function(u) {
      var x = jQuery('#artwork iframe'), s = x.attr('src');
      if (s != u) x.attr('src', u);
    },

    set_dimensions : function(w,h,sw,i) {
      if (!(w && w != '') || !(h && h != '')) return false;

      var scale = jQuery('#art_piece_scale').val(), 
          ratio = 1, // if calc mobile ratio resizing
          f = jQuery('#art_piece_format').val(),
          orig_screen_width = (sw || 375), 
          orig_screen_height = 281,
          screen_width = Math.round(orig_screen_width * scale),
          screen_height = Math.round(orig_screen_height * scale),
          screen_zoom_ratio = (screen_width / w),
          screen_zoom_pct = (100 / screen_zoom_ratio);

      // Set default screen dimensions to 16:9 if tv mode
      if (Fartsy.Preview.formats[f] == 'video') {
        screen_height = Math.round((9 * screen_width) / 16)
      } else {
        screen_height = Math.round(screen_zoom_ratio * h)
      }

      if (screen_height <= (300 * scale)) {
        var bg_width = Math.round(6578 * scale),
            bg_pos_y = Math.round(475 * scale),
            adjusted_height_scale_diff = Math.round( (2 - scale) * (1 - ratio) * (((orig_screen_width / w) * h) / 2) )
            pos_y = Math.round((80 * (2 - scale)) - adjusted_height_scale_diff);

        jQuery('#artwork').css({'width' : screen_width +'px', 'height' : screen_height +'px', 'top' : pos_y+'px'});
        jQuery('#artwork iframe').css({'width' : screen_zoom_pct.toFixed(2)+'%', 'height' : screen_zoom_pct.toFixed(2)+'%', 'zoom' : screen_zoom_ratio.toFixed(2), 'transform' : 'scale('+ screen_zoom_ratio.toFixed(2) +')', '-moz-transform' : 'scale('+ screen_zoom_ratio.toFixed(2) +')', '-o-transform' : 'scale('+ screen_zoom_ratio.toFixed(2) +')', '-webkit-transform' : 'scale('+ screen_zoom_ratio.toFixed(2) +')'});
        // jQuery('#gallery').css({'background-size' : bg_width +'px auto', 'background-position' : 'center '+ bg_pos_y +'px'});

      } else {
        screen_width = Math.round(screen_width * (280 / screen_height));
        if (i < 1) Fartsy.Preview.set_dimensions(w,h,screen_width,1);
      }
    }
  }

};
