jQuery(document).ready(function() {
  Fartsy.Preview.initialize();
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
        if (r && r == 'frame') var t = 0.5625;

        if (Fartsy.Preview.formats[f] == 'image') {
          var i = new Image();
          i.src = u;
          i.onload = function() {
            Fartsy.Preview.set_url('/pieces/preview/image?url='+ encodeURI(u));
            jQuery('#art_piece_width').val(i.width);
            jQuery('#art_piece_height').val(i.height);
            Fartsy.Preview.set_dimensions(i.width, i.height, t);
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

    set_dimensions : function(w,h,r,sw) {
      if (!(w && w != '') || !(h && h != '')) return false;
      if (!sw || sw == '') sw = 375;
      var x = (sw / w), p = (100 / x), sh = Math.round(h * (r && r != '' ? r : x));
      if (sh <= 300) {
        jQuery('#artwork').css({'width' : sw +'px', 'height' : sh +'px'});
        jQuery('#artwork iframe').css({'width' : p.toFixed(2)+'%', 'height' : p.toFixed(2)+'%', 'zoom' : x.toFixed(2), 'transform' : 'scale('+ x.toFixed(2) +')', '-moz-transform' : 'scale('+ x.toFixed(2) +')', '-o-transform' : 'scale('+ x.toFixed(2) +')', '-webkit-transform' : 'scale('+ x.toFixed(2) +')'});
      } else {
        sw = Math.round(sw * (280 / sh));
        Fartsy.Preview.set_dimensions(w,h,null,sw);
      }
    }
  }

};
