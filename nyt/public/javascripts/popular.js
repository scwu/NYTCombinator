function getPopular(type) {
  var length = type || 1;
  var count = 0;
  $.getJSON('/getshared', { type : length }, function(response) {
    if (count != 31) {
      var items = [];
      $.each(response.results, function(k,v) {
        var url = v.url;
        var title = v.title;
        var abstract = v.abstract;
        var date = v.published_date;
        items.push('<ul id="' + count +'">' 
                     + '<li id = "name"><a href="' + url + '" class="link" id="' + count + '">' + title + '</a>' + '</li>'  + '<li id ="date">' + date + '</li>' 
                    + '<li id="activity">' + abstract + '</li><li class="read"><input type="button" id="' +count + '" class="read" value="Read more"></input></li>' + '</ul>');

        count++;
      });
       $('<ul/>', {
         'class': 'items',
         html : items.join('')
      }).appendTo('div#page');
    }
  });
}

  // display the lightbox
function lightbox(insertContent, link){

  // add lightbox/shadow <div/>'s if not previously added
  if($('#lightbox').size() == 0){
    var theLightbox = $('<div id="lightbox"/>');
    var theShadow = $('<div id="lightbox-shadow"/>');
    $(theShadow).click(function(e){
      closeLightbox();
    });
    $('body').append(theShadow);
    $('#lightbox-shadow').height($(document).height());
    $('body').append(theLightbox);
  }

  // remove any previously added content
  $('#lightbox').empty();

  // insert HTML content
  if(insertContent != null){
    $('#lightbox').append(insertContent);
  }

  // insert AJAX content
  if(link != null){
    // temporarily add a "Loading..." message in the lightbox
    $('#lightbox').append('<p class="loading">Loading...</p>');

    // request AJAX content
    $.getJSON('/getbody', { link : link }, function(response) {
            var body = response.content;
            $('#lightbox').empty();
            $('#lightbox').append(body);
    });
  }

  // move the lightbox to the current window top + 100px
  $('#lightbox').css('top', $(window).scrollTop() + 100 + 'px');

  // display the lightbox
  $('#lightbox').show();
  $('#lightbox-shadow').show();

}

// close the lightbox
function closeLightbox(){

  // hide lightbox and shadow <div/>'s
  $('#lightbox').hide();
  $('#lightbox-shadow').hide();

  // remove contents of lightbox in case a video or other content is actively playing
  $('#lightbox').empty();
}

$(document).ready(function() {
  getPopular();
  $('.length').click (function(event) {
    event.preventDefault();
    $('#page').empty();
    var id = $(this).attr('id')
    getPopular(parseInt(id));
    var url = $('.link').filter('#' + id).attr('href');
  });
    $(document).on("click", ".read", function(){
    console.log("hi i clicked");
    var id = $(this).attr('id');
    var url = $('.link').filter('#' + id).attr('href');
    console.log(id);
    console.log(url);
    lightbox(null, url);
    return false;
  });
});



