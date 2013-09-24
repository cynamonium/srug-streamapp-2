
//= require jquery
//= require jquery_ujs
//= require_tree .

$(document).ready(function(){
	  var source = new EventSource('/streaming');
	  source.addEventListener('update', function(e) {
	      alert(e.data);
	  });
});
