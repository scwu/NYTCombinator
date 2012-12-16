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
        console.log(url);
        items.push('<ul id="' + count +'"><a href="' + url + '">' + '<li id = "photo">' + 
                     '</li>'+ '<li id = "name">'+ title + '</li>' + '</a>'  + '<li id ="date">' + date + '</li>' 
                    + '<li id="activity">' + abstract + '</li>' + '</ul>');

      });
       $('<ul/>', {
         'class': 'items',
         html : items.join('')
      }).appendTo('div#page');
    }
  });
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
});
